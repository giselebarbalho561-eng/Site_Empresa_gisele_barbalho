-- =============================================================
-- CoreCorp Enterprise - Gestão de Colaboradores
-- Script de configuração do Supabase
-- Cole este conteúdo inteiro no SQL Editor do Supabase e execute
-- =============================================================

-- -------------------------------------------------------------
-- 1. TABELA: funcionarios
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.funcionarios (
    id           bigserial PRIMARY KEY,
    nome         text        NOT NULL,
    email        text        NOT NULL,
    cargo        text        NOT NULL,
    departamento text,
    foto_url     text,
    created_at   timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE  public.funcionarios            IS 'Colaboradores cadastrados no site CoreCorp Enterprise';
COMMENT ON COLUMN public.funcionarios.id         IS 'Identificador único do colaborador';
COMMENT ON COLUMN public.funcionarios.nome       IS 'Nome completo do colaborador';
COMMENT ON COLUMN public.funcionarios.email      IS 'E-mail corporativo';
COMMENT ON COLUMN public.funcionarios.cargo      IS 'Cargo / função exercida';
COMMENT ON COLUMN public.funcionarios.departamento IS 'Departamento ou setor';
COMMENT ON COLUMN public.funcionarios.foto_url   IS 'URL pública da foto no Storage (bucket fotos-funcionarios). Vazio = usar avatar padrão';
COMMENT ON COLUMN public.funcionarios.created_at IS 'Data e hora do cadastro';

-- E-mail corporativo deve ser único
CREATE UNIQUE INDEX IF NOT EXISTS funcionarios_email_unq
    ON public.funcionarios (lower(email));

-- Índice para ordenar por id com Efficiency (usado pelo .order('id'))
CREATE INDEX IF NOT EXISTS funcionarios_id_idx
    ON public.funcionarios (id DESC);

-- -------------------------------------------------------------
-- 2. ROW LEVEL SECURITY (RLS)
-- -------------------------------------------------------------
ALTER TABLE public.funcionarios ENABLE ROW LEVEL SECURITY;

-- Leitura pública: o quadro de colaboradores é exibido para todos
DROP POLICY IF EXISTS "permitir_leitura_funcionarios" ON public.funcionarios;
CREATE POLICY "permitir_leitura_funcionarios"
    ON public.funcionarios
    FOR SELECT
    TO anon, authenticated
    USING (true);

-- Inserção pública: o formulário de cadastro é aberto no site
DROP POLICY IF EXISTS "permitir_insercao_funcionarios" ON public.funcionarios;
CREATE POLICY "permitir_insercao_funcionarios"
    ON public.funcionarios
    FOR INSERT
    TO anon, authenticated
    WITH CHECK (true);

-- Atualização e remoção bloqueadas para o anon key
-- (só o painel do Supabase / service_role altera registros)

-- -------------------------------------------------------------
-- 3. STORAGE: bucket público para as fotos
-- -------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public)
VALUES ('fotos-funcionarios', 'fotos-funcionarios', true)
ON CONFLICT (id) DO UPDATE
    SET public = true;

-- Leitura pública das imagens
DROP POLICY IF EXISTS "permitir_leitura_fotos" ON storage.objects;
CREATE POLICY "permitir_leitura_fotos"
    ON storage.objects
    FOR SELECT
    TO anon, authenticated
    USING (bucket_id = 'fotos-funcionarios');

-- Upload público das imagens (limitado ao bucket de fotos)
DROP POLICY IF EXISTS "permitir_upload_fotos" ON storage.objects;
CREATE POLICY "permitir_upload_fotos"
    ON storage.objects
    FOR INSERT
    TO anon, authenticated
    WITH CHECK (bucket_id = 'fotos-funcionarios');

-- Atualização e remoção de fotos bloqueadas para o anon key

-- -------------------------------------------------------------
-- 4. (OPCIONAL) DADOS DE EXEMPLO PARA TESTE
--    Comente o bloco abaixo se não quiser dados fictícios.
-- -------------------------------------------------------------
INSERT INTO public.funcionarios (nome, email, cargo, departamento)
VALUES
    ('Samuel Nascimento', 'samuel.nascimento@empresa.com', 'Engenheiro de Software', 'Tecnologia da Informação'),
    ('Ana Beatriz Souza', 'ana.souza@empresa.com',            'Gerente de Recursos Humanos', 'Pessoal'),
    ('Carlos Eduardo Lima', 'carlos.lima@empresa.com',        'Analista de Segurança da Informação', 'Tecnologia da Informação'),
    ('Mariana Alves Rocha', 'mariana.rocha@empresa.com',      'Designer de Interface', 'Design'),
    ('Rafael Monteiro', 'rafael.monteiro@empresa.com',        'Desenvolvedor Back-end', 'Tecnologia da Informação')
ON CONFLICT DO NOTHING;

-- =============================================================
-- Fim. Para conferir, rode:
--   SELECT * FROM public.funcionarios ORDER BY id DESC;
-- =============================================================
