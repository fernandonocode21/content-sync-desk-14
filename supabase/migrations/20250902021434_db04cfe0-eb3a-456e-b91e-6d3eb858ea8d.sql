-- Primeiro, vamos verificar se existe um trigger para criar perfis automaticamente
-- e corrigir as políticas RLS para incluir super admin

-- Atualizar a função handle_new_user para garantir que cria perfil corretamente
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
  INSERT INTO public.profiles (id, nome, email, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'nome', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    NEW.email,
    CASE 
      WHEN NEW.id = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid THEN 'super_admin'
      ELSE 'user'
    END
  );
  RETURN NEW;
END;
$$;

-- Criar o trigger se não existir
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Atualizar políticas RLS para incluir super admin em todas as tabelas

-- Tabela canais
DROP POLICY IF EXISTS "Super admin can view all canais" ON public.canais;
CREATE POLICY "Super admin can view all canais" 
ON public.canais 
FOR SELECT 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

DROP POLICY IF EXISTS "Super admin can update all canais" ON public.canais;
CREATE POLICY "Super admin can update all canais" 
ON public.canais 
FOR UPDATE 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

DROP POLICY IF EXISTS "Super admin can delete all canais" ON public.canais;
CREATE POLICY "Super admin can delete all canais" 
ON public.canais 
FOR DELETE 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

-- Tabela ideias
DROP POLICY IF EXISTS "Super admin can view all ideias" ON public.ideias;
CREATE POLICY "Super admin can view all ideias" 
ON public.ideias 
FOR SELECT 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

DROP POLICY IF EXISTS "Super admin can update all ideias" ON public.ideias;
CREATE POLICY "Super admin can update all ideias" 
ON public.ideias 
FOR UPDATE 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

DROP POLICY IF EXISTS "Super admin can delete all ideias" ON public.ideias;
CREATE POLICY "Super admin can delete all ideias" 
ON public.ideias 
FOR DELETE 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

-- Tabela competitor_channels
DROP POLICY IF EXISTS "Super admin can view all competitor channels" ON public.competitor_channels;
CREATE POLICY "Super admin can view all competitor channels" 
ON public.competitor_channels 
FOR SELECT 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

DROP POLICY IF EXISTS "Super admin can update all competitor channels" ON public.competitor_channels;
CREATE POLICY "Super admin can update all competitor channels" 
ON public.competitor_channels 
FOR UPDATE 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

DROP POLICY IF EXISTS "Super admin can delete all competitor channels" ON public.competitor_channels;
CREATE POLICY "Super admin can delete all competitor channels" 
ON public.competitor_channels 
FOR DELETE 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

-- Tabela scheduled_videos
DROP POLICY IF EXISTS "Super admin can view all scheduled videos" ON public.scheduled_videos;
CREATE POLICY "Super admin can view all scheduled videos" 
ON public.scheduled_videos 
FOR SELECT 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

DROP POLICY IF EXISTS "Super admin can update all scheduled videos" ON public.scheduled_videos;
CREATE POLICY "Super admin can update all scheduled videos" 
ON public.scheduled_videos 
FOR UPDATE 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

DROP POLICY IF EXISTS "Super admin can delete all scheduled videos" ON public.scheduled_videos;
CREATE POLICY "Super admin can delete all scheduled videos" 
ON public.scheduled_videos 
FOR DELETE 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

-- Tabela videos
DROP POLICY IF EXISTS "Super admin can view all videos" ON public.videos;
CREATE POLICY "Super admin can view all videos" 
ON public.videos 
FOR SELECT 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

DROP POLICY IF EXISTS "Super admin can update all videos" ON public.videos;
CREATE POLICY "Super admin can update all videos" 
ON public.videos 
FOR UPDATE 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

DROP POLICY IF EXISTS "Super admin can delete all videos" ON public.videos;
CREATE POLICY "Super admin can delete all videos" 
ON public.videos 
FOR DELETE 
USING (auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid);

-- Atualizar política de view dos profiles para super admin
DROP POLICY IF EXISTS "Users can view profiles" ON public.profiles;
CREATE POLICY "Users can view profiles" 
ON public.profiles 
FOR SELECT 
USING (
  auth.uid() = id OR 
  auth.uid() = 'b748d521-8030-459c-bfaf-5632a71600e1'::uuid
);

-- Adicionar coluna avatar_url na tabela profiles se não existir
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS avatar_url TEXT;