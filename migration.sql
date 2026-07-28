-- ================================================================
--  DocFlow AI — Migração do Banco de Dados
--  Execute no SQL Editor do seu projeto Supabase.
--
--  Modelo multi-tenant: cada estabelecimento (farmácia) é um
--  tenant isolado por Row Level Security (RLS). Um usuário só
--  enxerga dados do próprio estabelecimento.
-- ================================================================

create extension if not exists "uuid-ossp";

-- ── ESTABELECIMENTOS (tenants) ──────────────────────────────────
create table if not exists public.estabelecimentos (
  id                 uuid primary key default uuid_generate_v4(),
  user_id            uuid references auth.users(id) on delete cascade,
  nome               text not null default 'Minha Farmácia',
  segmento           text not null default 'farmacia',
  cnpj               text default '',
  cidade             text default '',
  plano              text not null default 'essencial',   -- essencial | premium
  status_assinatura  text not null default 'trial',        -- ativa | pendente | cancelada | trial
  setup_pago         boolean not null default false,
  criado_em          timestamptz not null default now()
);

-- ── PERFIS (RT / gestor) — estende auth.users ───────────────────
create table if not exists public.perfis (
  id                 uuid primary key default uuid_generate_v4(),
  user_id            uuid references auth.users(id) on delete cascade unique,
  estabelecimento_id uuid references public.estabelecimentos(id) on delete cascade,
  nome               text not null default '',
  email              text not null default '',
  papel              text not null default 'responsavel_tecnico',
  iniciais           text default '',
  criado_em          timestamptz not null default now()
);

-- ── COLABORADORES (equipe que lê os POPs; sem login próprio) ─────
-- papel controla permissões: leitor | editor | responsavel_tecnico
create table if not exists public.colaboradores (
  id                 uuid primary key default uuid_generate_v4(),
  estabelecimento_id uuid references public.estabelecimentos(id) on delete cascade,
  nome               text not null,
  cpf                text not null,               -- identifica quem leu (peso jurídico)
  cargo              text default '',
  papel              text not null default 'leitor',
  crf                text default '',              -- registro no conselho (farmacêuticos)
  email              text default '',
  telefone           text default '',
  admissao           date,
  ativo              boolean not null default true,
  criado_em          timestamptz not null default now(),
  unique (estabelecimento_id, cpf)                 -- CPF único por estabelecimento
);

-- ── POPs ────────────────────────────────────────────────────────
create table if not exists public.pops (
  id                    text not null,
  estabelecimento_id    uuid references public.estabelecimentos(id) on delete cascade,
  nome                  text not null,
  categoria             text default '',
  status                text not null default 'rascunho',  -- vigente|revisar|rascunho|aprovacao
  origem                text not null default 'ia',         -- modelo|importado|ia
  versao_atual          integer not null default 1,
  leitura_obrigatoria   boolean not null default false,
  criado_em             timestamptz not null default now(),
  atualizado_em         timestamptz not null default now(),
  primary key (id, estabelecimento_id)
);

-- ── VERSÕES (histórico completo e auditável) ────────────────────
create table if not exists public.versoes_pop (
  id                 uuid primary key default uuid_generate_v4(),
  pop_id             text not null,
  estabelecimento_id uuid references public.estabelecimentos(id) on delete cascade,
  numero             integer not null,
  conteudo           text default '',
  autor_nome         text default '',
  nota               text default '',
  vigente            boolean not null default false,
  criado_em          timestamptz not null default now()
);

-- ── REGISTROS DE LEITURA (evidência com timestamp do servidor) ──
create table if not exists public.registros_leitura (
  id                 uuid primary key default uuid_generate_v4(),
  pop_id             text not null,
  estabelecimento_id uuid references public.estabelecimentos(id) on delete cascade,
  versao_numero      integer not null,
  colaborador_id     uuid references public.colaboradores(id) on delete set null,
  leitor_nome        text not null,
  leitor_cpf         text not null,               -- peso jurídico da evidência
  leitor_cargo       text default '',
  confirmado_em      timestamptz not null default now()   -- servidor, não o dispositivo
);

-- ── ALERTAS REGULATÓRIOS (curadoria manual no MVP) ──────────────
create table if not exists public.alertas_regulatorios (
  id             uuid primary key default uuid_generate_v4(),
  norma          text not null,
  tema           text default '',
  descricao      text default '',
  segmento       text not null default 'farmacia',
  grau           text not null default 'medio',   -- alto|medio|baixo
  pop_afetado_id text,
  fonte_url      text default '',
  publicado_em   timestamptz not null default now()
);

-- ── MODELOS-SEMENTE (biblioteca global; fora do tenant) ─────────
create table if not exists public.modelos_pop (
  id        uuid primary key default uuid_generate_v4(),
  nome      text not null,
  categoria text default '',
  segmento  text not null default 'farmacia',
  conteudo  text default ''
);

-- ================================================================
--  ROW LEVEL SECURITY
-- ================================================================
alter table public.estabelecimentos   enable row level security;
alter table public.perfis             enable row level security;
alter table public.colaboradores      enable row level security;
alter table public.pops               enable row level security;
alter table public.versoes_pop        enable row level security;
alter table public.registros_leitura  enable row level security;
alter table public.alertas_regulatorios enable row level security;
alter table public.modelos_pop        enable row level security;

-- Helper: estabelecimento do usuário logado.
create or replace function public.meu_estabelecimento()
returns uuid language sql stable as $$
  select estabelecimento_id from public.perfis where user_id = auth.uid() limit 1;
$$;

-- Estabelecimento: o dono vê o próprio.
create policy "estab_proprio" on public.estabelecimentos
  for all using (id = public.meu_estabelecimento())
  with check (user_id = auth.uid());

-- Perfil: cada um vê o próprio perfil.
create policy "perfil_proprio" on public.perfis
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Tabelas do tenant: filtradas pelo estabelecimento do usuário.
create policy "colab_tenant" on public.colaboradores
  for all using (estabelecimento_id = public.meu_estabelecimento())
  with check (estabelecimento_id = public.meu_estabelecimento());

create policy "pops_tenant" on public.pops
  for all using (estabelecimento_id = public.meu_estabelecimento())
  with check (estabelecimento_id = public.meu_estabelecimento());

create policy "versoes_tenant" on public.versoes_pop
  for all using (estabelecimento_id = public.meu_estabelecimento())
  with check (estabelecimento_id = public.meu_estabelecimento());

create policy "leituras_tenant" on public.registros_leitura
  for all using (estabelecimento_id = public.meu_estabelecimento())
  with check (estabelecimento_id = public.meu_estabelecimento());

-- Leitura pública para o colaborador confirmar via link/QR (sem login).
-- Permite INSERIR uma confirmação sem autenticação, mas não ler tudo.
create policy "leitura_publica_insert" on public.registros_leitura
  for insert to anon with check (true);

-- Alertas e modelos: leitura liberada para usuários autenticados.
create policy "alertas_leitura" on public.alertas_regulatorios
  for select using (true);
create policy "modelos_leitura" on public.modelos_pop
  for select using (true);

-- ================================================================
--  TRIGGERS
-- ================================================================
-- Cria perfil automaticamente no primeiro login (Google/e-mail).
create or replace function public.handle_novo_usuario()
returns trigger language plpgsql security definer as $$
declare novo_estab uuid;
begin
  insert into public.estabelecimentos (user_id, nome)
    values (new.id, 'Minha Farmácia') returning id into novo_estab;
  insert into public.perfis (user_id, estabelecimento_id, nome, email)
    values (new.id, novo_estab, coalesce(new.raw_user_meta_data->>'full_name',''), new.email);
  return new;
end; $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_novo_usuario();

-- Atualiza atualizado_em ao editar um POP.
create or replace function public.touch_pop()
returns trigger language plpgsql as $$
begin new.atualizado_em = now(); return new; end; $$;

drop trigger if exists pop_touch on public.pops;
create trigger pop_touch before update on public.pops
  for each row execute function public.touch_pop();

select 'DocFlow AI — schema criado com sucesso ✓' as status;
