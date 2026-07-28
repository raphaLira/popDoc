# DocFlow AI

Plataforma de gestão de POPs e conformidade regulatória para farmácias.

Mesma stack do FeedbackJá: **HTML + CSS + JavaScript puro** num único
`index.html`, sem framework e sem build. Supabase (Postgres) no back,
Vercel na hospedagem, PWA instalável.

## Rodar

Não precisa instalar nada. Duas formas:

- **Mais simples:** abra o `index.html` direto no navegador (duplo clique).
- **Com servidor local** (recomendado p/ PWA): rode `npx serve` na pasta
  e abra o endereço mostrado.

O app inicia em **MODO MOCK** — dados de exemplo embutidos, sem precisar
de Supabase.

**Login de teste:** demo@docflow.ai / demo (ou botão do Google, simulado).

## Conectar ao Supabase real

1. Crie um projeto em https://supabase.com
2. SQL Editor → cole todo o `migration.sql` → Run
3. Authentication → Providers → ative Google
4. No topo do `<script>` em `index.html`, preencha:
   ```js
   const SUPABASE_URL = "https://xxxx.supabase.co";
   const SUPABASE_ANON_KEY = "eyJ...";
   ```
5. Pronto — o app passa a usar o banco real automaticamente.

## Deploy no Vercel

Suba a pasta no GitHub e conecte no Vercel. Como é site estático,
o deploy é imediato, sem configuração de build.
