-- Corrigir as funções com search_path mutable
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.authenticate_member(p_username text, p_password text)
RETURNS TABLE(member_id uuid, member_name text, session_token text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  -- Por enquanto, retorna dados simulados para teste
  -- Em produção, implementar verificação real de credenciais
  IF p_username = 'admin' AND p_password = 'admin123' THEN
    RETURN QUERY SELECT 
      gen_random_uuid() as member_id,
      'Administrador' as member_name,
      encode(gen_random_bytes(32), 'base64') as session_token;
  ELSE
    RETURN;
  END IF;
END;
$$;