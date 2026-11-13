-- Booking integrity, role protection, and tighter RLS.
-- Additive: does not rename existing statuses. Adds `completed` as a value.

CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC;
REVOKE ALL ON SCHEMA private FROM anon;
GRANT USAGE ON SCHEMA private TO authenticated, postgres, service_role;

CREATE OR REPLACE FUNCTION private.current_user_role()
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.users WHERE id = auth.uid();
$$;

REVOKE ALL ON FUNCTION private.current_user_role() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION private.current_user_role() TO authenticated;

-- Force new signups to client. Barbers are promoted in the dashboard.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (id, name, email, role)
  VALUES (
    NEW.id,
    coalesce(NEW.raw_user_meta_data->>'name', 'Usuário'),
    NEW.email,
    'client'
  );
  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.protect_user_role()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.role() IN ('authenticated', 'anon') AND NEW.role IS DISTINCT FROM OLD.role THEN
    NEW.role := OLD.role;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protect_user_role ON public.users;
CREATE TRIGGER protect_user_role
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.protect_user_role();

REVOKE ALL ON FUNCTION public.protect_user_role() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.protect_user_role() FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  id_usuario uuid := auth.uid();
BEGIN
  IF id_usuario IS NULL THEN
    RAISE EXCEPTION 'Não autorizado';
  END IF;

  DELETE FROM public.appointments WHERE client_id = id_usuario;
  DELETE FROM public.users WHERE id = id_usuario;
  DELETE FROM auth.users WHERE id = id_usuario;
END;
$$;

REVOKE ALL ON FUNCTION public.delete_user_account() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.delete_user_account() FROM anon;
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated;

ALTER TABLE public.appointment_services
  DROP CONSTRAINT IF EXISTS appointment_services_appointment_id_fkey;

ALTER TABLE public.appointment_services
  ADD CONSTRAINT appointment_services_appointment_id_fkey
  FOREIGN KEY (appointment_id)
  REFERENCES public.appointments(id)
  ON DELETE CASCADE;

CREATE OR REPLACE FUNCTION private.has_overlap(
  p_barber_id uuid,
  p_date date,
  p_time time,
  p_duration_minutes integer,
  p_exclude_id uuid DEFAULT NULL
)
RETURNS boolean
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.appointments a
    LEFT JOIN LATERAL (
      SELECT COALESCE(SUM(s.duration_minutes), 15)::integer AS duration
      FROM public.appointment_services aps
      JOIN public.services s ON s.id = aps.service_id
      WHERE aps.appointment_id = a.id
    ) d ON true
    WHERE a.barber_id = p_barber_id
      AND a.appointment_date = p_date
      AND a.status IS DISTINCT FROM 'canceled'
      AND (p_exclude_id IS NULL OR a.id <> p_exclude_id)
      AND tsrange(
            (a.appointment_date + a.appointment_time),
            (a.appointment_date + a.appointment_time)
              + make_interval(mins => COALESCE(NULLIF(d.duration, 0), 15)),
            '[)'
          ) && tsrange(
            (p_date + p_time),
            (p_date + p_time)
              + make_interval(mins => GREATEST(COALESCE(p_duration_minutes, 15), 15)),
            '[)'
          )
  );
$$;

CREATE OR REPLACE FUNCTION public.prevent_appointment_overlap()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF NEW.status = 'canceled' THEN
    RETURN NEW;
  END IF;

  IF private.has_overlap(
    NEW.barber_id,
    NEW.appointment_date,
    NEW.appointment_time,
    15,
    NEW.id
  ) THEN
    RAISE EXCEPTION 'Horário indisponível'
      USING ERRCODE = 'unique_violation';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS prevent_appointment_overlap ON public.appointments;
CREATE TRIGGER prevent_appointment_overlap
BEFORE INSERT ON public.appointments
FOR EACH ROW
EXECUTE FUNCTION public.prevent_appointment_overlap();

-- Historical duplicates exist; only protect current/future slots.
CREATE UNIQUE INDEX IF NOT EXISTS appointments_unique_active_slot
ON public.appointments (barber_id, appointment_date, appointment_time)
WHERE status IS DISTINCT FROM 'canceled'
  AND appointment_date >= DATE '2026-11-09';

CREATE OR REPLACE FUNCTION public.enforce_cancel_policy()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  user_role text;
  appointment_at timestamptz;
BEGIN
  IF NEW.status = 'canceled' AND OLD.status IS DISTINCT FROM 'canceled' THEN
    SELECT role INTO user_role FROM public.users WHERE id = auth.uid();

    IF user_role = 'barber' AND auth.uid() = OLD.barber_id THEN
      RETURN NEW;
    END IF;

    appointment_at := (OLD.appointment_date + OLD.appointment_time) AT TIME ZONE 'America/Sao_Paulo';

    IF appointment_at < now() + interval '5 hours' THEN
      RAISE EXCEPTION 'Cancelamento só é permitido com 5 horas de antecedência';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS enforce_cancel_policy ON public.appointments;
CREATE TRIGGER enforce_cancel_policy
BEFORE UPDATE ON public.appointments
FOR EACH ROW
EXECUTE FUNCTION public.enforce_cancel_policy();

CREATE OR REPLACE FUNCTION public.book_appointment(
  p_client_id uuid,
  p_barber_id uuid,
  p_date date,
  p_time time,
  p_service_ids uuid[]
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  new_id uuid;
  total_duration integer;
BEGIN
  IF auth.uid() IS DISTINCT FROM p_client_id THEN
    RAISE EXCEPTION 'Não autorizado';
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
    status
  )
  VALUES (
    p_client_id,
    p_barber_id,
    p_date,
    p_time,
    'scheduled'
  )
  RETURNING id INTO new_id;

  INSERT INTO public.appointment_services (appointment_id, service_id)
  SELECT new_id, service_id
  FROM unnest(p_service_ids) AS service_id;

  RETURN new_id;
END;
$$;

REVOKE ALL ON FUNCTION public.book_appointment(uuid, uuid, date, time, uuid[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.book_appointment(uuid, uuid, date, time, uuid[]) TO authenticated;

CREATE OR REPLACE FUNCTION public.block_time_slot(
  p_barber_id uuid,
  p_date date,
  p_time time
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  new_id uuid;
BEGIN
  IF auth.uid() IS DISTINCT FROM p_barber_id THEN
    RAISE EXCEPTION 'Não autorizado';
  END IF;

  IF private.current_user_role() IS DISTINCT FROM 'barber' THEN
    RAISE EXCEPTION 'Não autorizado';
  END IF;

  PERFORM pg_advisory_xact_lock(
    hashtext(p_barber_id::text),
    extract(epoch FROM p_date)::integer
  );

  INSERT INTO public.appointments (
    barber_id,
    client_id,
    appointment_date,
    appointment_time,
    status
  )
  VALUES (
    p_barber_id,
    p_barber_id,
    p_date,
    p_time,
    'blocked'
  )
  RETURNING id INTO new_id;

  RETURN new_id;
END;
$$;

REVOKE ALL ON FUNCTION public.block_time_slot(uuid, date, time) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.block_time_slot(uuid, date, time) TO authenticated;

-- Guests need to list barbers before login.
DROP POLICY IF EXISTS "Visitantes veem barbeiros" ON public.users;
CREATE POLICY "Visitantes veem barbeiros"
ON public.users
FOR SELECT
TO anon
USING (role = 'barber');

DROP POLICY IF EXISTS "Permitir inserção e edição apenas para autenticados" ON public.services;
DROP POLICY IF EXISTS "Barbeiros gerenciam servicos" ON public.services;

CREATE POLICY "Barbeiros gerenciam servicos"
ON public.services
FOR ALL
TO authenticated
USING (private.current_user_role() = 'barber')
WITH CHECK (private.current_user_role() = 'barber');

DROP POLICY IF EXISTS "Permitir inserção em appointment_services" ON public.appointment_services;
DROP POLICY IF EXISTS "Inserir servicos do proprio agendamento" ON public.appointment_services;

CREATE POLICY "Inserir servicos do proprio agendamento"
ON public.appointment_services
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.appointments a
    WHERE a.id = appointment_id
      AND (a.client_id = auth.uid() OR a.barber_id = auth.uid())
  )
);

-- Past scheduled appointments become completed so reports stay honest.
UPDATE public.appointments
SET status = 'completed'
WHERE status = 'scheduled'
  AND ((appointment_date + appointment_time) AT TIME ZONE 'America/Sao_Paulo') < now();
