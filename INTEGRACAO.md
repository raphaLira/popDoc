# DocFlow AI — Ligar o banco (Supabase)

Passo a passo para tirar o app do modo demonstração e ligar no banco real.
Enquanto SUPABASE_URL e SUPABASE_ANON_KEY estiverem vazios no index.html,
o app roda em MOCK (dados na memoria, somem ao recarregar).

## 1. Criar o projeto no Supabase
1. Acesse supabase.com e crie um projeto novo.
2. Guarde a senha do banco (voce escolhe na criacao).
3. Aguarde o provisionamento (~2 min).

## 2. Criar as tabelas
1. No painel do Supabase: SQL Editor > New query.
2. Cole TODO o conteudo de `migration.sql` e clique em Run.
3. Deve aparecer: "DocFlow AI — schema criado com sucesso".
   Isso cria as 8 tabelas, o RLS (isolamento por farmacia),
   as policies e os triggers.

## 3. Popular os modelos (14 POPs)
1. Ainda no SQL Editor: New query.
2. Cole TODO o conteudo de `seed_modelos.sql` e Run.
3. Isso insere os 8 modelos do Parana + 6 genericos.
   (Rode UMA vez so; rodar de novo duplica.)

## 4. Pegar as chaves
1. No Supabase: Settings > API.
2. Copie:
   - Project URL  (ex: https://xxxx.supabase.co)
   - anon public key  (a chave longa que comeca com eyJ...)
3. NUNCA use a service_role key no front-end. So a anon.

## 5. Colar as chaves no app
Abra o `index.html` e, logo no inicio do <script>, preencha:

    const SUPABASE_URL = "https://xxxx.supabase.co";
    const SUPABASE_ANON_KEY = "eyJ...";

Assim que preenchidas, o app sai do modo MOCK sozinho
(o aviso "MODO MOCK" some do console).

## 6. Configurar o login
No Supabase: Authentication > Providers.
- E-mail/senha: ja vem ligado.
- Google (opcional): ligue o provider Google e cole as credenciais
  do Google Cloud. Em Authentication > URL Configuration, ponha:
    Site URL:      https://SEU-APP.vercel.app
    Redirect URLs: https://SEU-APP.vercel.app
  E no Google Cloud Console, em "Origens JavaScript autorizadas"
  e "URIs de redirecionamento", use o mesmo endereco.
  (Sem isso, o login Google quebra — foi o problema do localhost antes.)

## 7. Subir no Vercel
1. Suba a pasta docflow-vanilla como um projeto novo (nome != docflow).
2. Sem build: e HTML estatico, so Deploy.
3. Atualize as URLs do passo 6 com o endereco final.

## Primeiro acesso
- Ao logar com Google pela 1a vez, o app cria automaticamente
  um estabelecimento "Minha Farmacia" e o perfil de Responsavel Tecnico
  (trigger handle_novo_usuario no banco).
- Entre em Configuracoes (engrenagem) e ajuste nome, cidade e ESTADO.
  O estado define quais modelos aparecem (hoje: Parana curado).
- Cadastre a equipe em "Equipe" e comece a criar POPs.

## Como o link de leitura funciona no banco
- O colaborador abre  https://SEU-APP.vercel.app/#/ler/{estab}/{pop}
- As policies "..._leitura_publica" permitem que um visitante SEM login
  leia o POP e valide o proprio CPF, e a "leitura_publica_insert"
  registra a confirmacao.
- Se quiser mais seguranca, de para trocar essas policies por uma
  versao com token no link (posso implementar depois).

## O que ainda NAO esta no banco
- Pagamentos (gateway) — proximo grande item.
- Cadastro de alertas regulatorios pelo admin — hoje os alertas
  entram direto por SQL/painel do Supabase (curadoria sua).
