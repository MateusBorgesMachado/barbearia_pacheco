ALTER TABLE public.appointments
  ADD COLUMN IF NOT EXISTS walk_in_name text;

CREATE OR REPLACE FUNCTION public.book_walk_in_appointment(
  p_barber_id uuid,
  p_date date,
  p_time time,
  p_service_ids uuid[],
  p_client_name text
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  new_id uuid;
  total_duration integer;
  client_name text := btrim(p_client_name);
BEGIN
  IF auth.uid() IS DISTINCT FROM p_barber_id THEN
    RAISE EXCEPTION 'Não autorizado';
  END IF;

  IF private.current_user_role() IS DISTINCT FROM 'barber' THEN
    RAISE EXCEPTION 'Não autorizado';
  END IF;

  IF client_name IS NULL OR client_name = '' THEN
    RAISE EXCEPTION 'Informe o nome do cliente';
  END IF;

  PERFORM pg_advisory_xact_lock(
    hashtext(p_barber_id::text),
    extract(epoch FROM p_date)::integer
  );

  SELECT COALESCE(SUM(duration_minutes), 0)
    INTO total_duration
  FROM public.services
  WHERE id = ANY (p_service_ids);

  IF total_duration <= 0 THEN
    RAISE EXCEPTION 'Selecione ao menos um serviço';
  END IF;

  IF private.has_overlap(p_barber_id, p_date, p_time, total_duration, NULL) THEN
    RAISE EXCEPTION 'Horário indisponível'
      USING ERRCODE = 'unique_violation';
  END IF;

  INSERT INTO public.appointments (
    client_id,
    barber_id,
    appointment_date,
    appointment_time,
    status,
    walk_in_name
  )
  VALUES (
    NULL,
    p_barber_id,
    p_date,
    p_time,
    'scheduled',
    client_name
  )
  RETURNING id INTO new_id;

  INSERT INTO public.appointment_services (appointment_id, service_id)
  SELECT new_id, service_id
  FROM unnest(p_service_ids) AS service_id;

  RETURN new_id;
END;
$$;

REVOKE ALL ON FUNCTION public.book_walk_in_appointment(uuid, date, time, uuid[], text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.book_walk_in_appointment(uuid, date, time, uuid[], text) TO authenticated;
