-- Old app INSERTs appointments as authenticated. The overlap trigger and
-- RLS helpers live in schema private, which had no USAGE for that role.
REVOKE ALL ON SCHEMA private FROM PUBLIC;
REVOKE ALL ON SCHEMA private FROM anon;
GRANT USAGE ON SCHEMA private TO authenticated, postgres, service_role;

GRANT EXECUTE ON FUNCTION private.current_user_role() TO authenticated;
GRANT EXECUTE ON FUNCTION private.has_overlap(uuid, date, time, integer, uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.prevent_appointment_overlap()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
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

REVOKE ALL ON FUNCTION public.prevent_appointment_overlap() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.prevent_appointment_overlap() FROM anon, authenticated;
