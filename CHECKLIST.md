# DocFlow AI — Checklist de Configuração

Guia passo a passo para tirar o app do modo mock e colocá-lo no ar com
banco de dados real. Siga na ordem. Cada bloco depende do anterior.

---

## Fase 1 — Supabase (banco de dados)

- [ ] Criar conta em https://supabase.com
- [ ] Criar um novo projeto (escolher região **South America / São Paulo** — mais rápido no Brasil)
- [ ] Guardar a senha do banco que ele pede na criação (anota num lugar seguro)
- [ ] Esperar o projeto terminar de provisionar (~2 min)

### Rodar o schema

- [ ] No painel do Supabase, abrir **SQL Editor**
- [ ] Abrir o arquivo `migration.sql` do projeto
- [ ] Copiar todo o conteúdo, colar no SQL Editor e clicar em **Run**
- [ ] Confirmar que apareceu a mensagem de sucesso no final
- [ ] Conferir em **Table Editor** se as tabelas foram criadas
      (estabelecimentos, perfis, colaboradores, pops, versoes_pop,
      registros_leitura, alertas_regulatorios, modelos_pop)

### Pegar as chaves de conexão

- [ ] Ir em **Settings → API**
- [ ] Copiar a **Project URL** (algo como `https://xxxx.supabase.co`)
- [ ] Copiar a **anon public key** (chave longa começando com `eyJ...`)

---

## Fase 2 — Autenticação

### Login por e-mail/senha

- [ ] Em **Authentication → Providers**, confirmar que **Email** está ativado
- [ ] (Opcional) Desativar "Confirm email" no início, para testar mais rápido
      — reative antes de ter clientes reais

### Login com Google

- [ ] Criar credencial OAuth no Google Cloud Console (https://console.cloud.google.com)
      - [ ] Criar projeto
      - [ ] Configurar tela de consentimento OAuth
      - [ ] Criar credencial "ID do cliente OAuth" tipo **Aplicativo da Web**
      - [ ] Copiar Client ID e Client Secret
- [ ] No Supabase, **Authentication → Providers → Google**: colar Client ID e Secret e ativar
- [ ] No Google Cloud, adicionar a **URL de redirecionamento** que o Supabase mostra
      (algo como `https://xxxx.supabase.co/auth/v1/callback`)

> Se não quiser Google no começo, pode pular — o login por e-mail já basta
> para validar. Adicione o Google depois.

---

## Fase 3 — Conectar o app ao banco

- [ ] Abrir o `index.html` no editor
- [ ] No topo do `<script>`, preencher as duas chaves da Fase 1:
      ```js
      const SUPABASE_URL = "https://xxxx.supabase.co";
      const SUPABASE_ANON_KEY = "eyJ...";
      ```
- [ ] Salvar. Ao abrir o app, o aviso "MODO MOCK" some do console
      → sinal de que está usando o banco real
- [ ] O primeiro login com Google/e-mail cria automaticamente o
      estabelecimento e o perfil (via trigger no banco)

> **Importante:** a `anon key` é pública por natureza (fica no navegador).
> Quem protege os dados é o RLS (Row Level Security), que já está no
> `migration.sql`. Nunca use a `service_role key` no `index.html`.

---

## Fase 4 — Dados iniciais

- [ ] Cadastrar seu estabelecimento real (nome, CNPJ, cidade)
- [ ] Cadastrar a equipe em **Equipe → Novo funcionário**
- [ ] Popular os **modelos-semente** de POP (tabela `modelos_pop`) —
      os POPs de farmácia que você vai oferecer prontos
- [ ] Cadastrar os primeiros **alertas regulatórios** (curadoria manual)

---

## Fase 5 — GitHub

- [ ] Criar repositório novo no GitHub (pode ser privado)
- [ ] Subir a pasta do projeto:
      ```
      git init
      git add .
      git commit -m "DocFlow AI"
      git branch -M main
      git remote add origin https://github.com/SEU-USUARIO/docflow.git
      git push -u origin main
      ```
- [ ] Confirmar que o `.gitignore` está impedindo subir arquivos indevidos

---

## Fase 6 — Deploy no Vercel

- [ ] Entrar em https://vercel.com com a conta do GitHub
- [ ] **Add New → Project** → escolher o repositório `docflow`
- [ ] Como é site estático (HTML puro), não precisa configurar build
- [ ] Clicar em **Deploy**
- [ ] Abrir o link gerado (`docflow.vercel.app`) e testar o login real
- [ ] (Quando for cobrar de clientes) Assinar o **plano Pro** do Vercel

### Domínio próprio (opcional)

- [ ] Comprar um domínio (ex: `docflow.com.br` em registro.br)
- [ ] Em **Vercel → Settings → Domains**, adicionar o domínio e seguir as
      instruções de DNS

---

## Fase 7 — PWA (instalável no celular)

- [ ] Criar os ícones do app e colocar em `/icons/`:
      - [ ] `icon-192.png` (192×192)
      - [ ] `icon-512.png` (512×512)
- [ ] Confirmar que o `manifest.json` está sendo servido
- [ ] Testar no Android: abrir no Chrome → deve oferecer "Instalar"
- [ ] Testar no iPhone: Safari → Compartilhar → "Adicionar à Tela de Início"

---

## Fase 8 — Pagamentos (quando for cobrar)

- [ ] Escolher gateway (Stripe, Mercado Pago, Asaas, Pagar.me…)
- [ ] Integrar cobrança do setup (R$ 47) + mensalidade (R$ 39,90 / R$ 69,90)
- [ ] Ligar o status da assinatura (`status_assinatura` no banco) ao acesso
- [ ] Testar o fluxo: assinar → pagar → liberar acesso

> Esta fase ainda não está no código — é uma etapa de desenvolvimento
> futura, não só configuração.

---

## Ordem mínima para "ver funcionando com dados reais"

Se quiser o caminho mais curto para sair do mock:

1. Fase 1 (Supabase + schema)
2. Fase 2, só o e-mail/senha
3. Fase 3 (colar as chaves)

Isso já te dá o app rodando com banco real na sua máquina. GitHub, Vercel
e o resto vêm depois, quando quiser publicar.

---

## O que já está pronto no código (não precisa fazer)

- Estrutura multi-tenant com isolamento por RLS
- Lógica de login (e-mail e Google)
- Cadastro de funcionários com validação de CPF
- Controle de permissões por papel (RT / Editor / Leitor)
- Biblioteca de POPs, registro de leitura, alertas, planos
- Responsivo (desktop + celular) e base de PWA
