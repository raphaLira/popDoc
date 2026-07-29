# DocFlow AI — O que falta (Checklist)

Levantamento completo do que resta para o app estar pronto para clientes reais.
Dividido em **Desenvolvimento** (código a construir) e **Configuração**
(você executa em Supabase, Vercel, etc.).

Legenda de prioridade: 🔴 essencial · 🟡 importante · 🟢 desejável

---

## PARTE A — DESENVOLVIMENTO (código)

### A1. POPs — criação e edição 🔴
O botão "Novo POP" hoje é só um aviso. Falta o fluxo real.

- [ ] Tela "Novo POP" com os 3 caminhos: usar modelo / importar / criar com IA
- [ ] Editor de POP editável (hoje o conteúdo é fixo de exemplo)
- [ ] Salvar gera nova versão automaticamente
- [ ] Importar arquivo Word/PDF (extrair texto)
- [ ] Geração de rascunho com IA (integração com a API)

### A2. Fluxo de aprovação e versões 🔴
- [ ] Botão "Enviar para aprovação" funcional (muda status)
- [ ] Só o RT pode aprovar/publicar (aplicar `pode('aprovar')` nos botões)
- [ ] Tela de histórico de versões (existe no mock visual, falta no app real)
- [ ] Comparar/visualizar versões antigas

### A3. Permissões aplicadas na interface 🔴
A lógica de papéis existe (`pode()`), mas falta aplicar nos botões.

- [ ] Esconder/desabilitar "Novo POP" e "editar" para quem é Leitor
- [ ] Esconder "aprovar/publicar" para Editor
- [ ] Testar entrando como cada papel (RT / Editor / Leitor)

### A4. Distribuição e leitura pelo colaborador 🔴
O coração da evidência de fiscalização. Ainda não existe no código real.

- [ ] Tela "Distribuir POP" com link + QR Code
- [ ] Geração real de QR Code (biblioteca JS)
- [ ] Página pública de leitura (colaborador abre o link, sem login)
- [ ] Colaborador se identifica (seleciona nome / informa CPF)
- [ ] Confirmação grava registro com CPF, data e hora do servidor
- [ ] Registro amarra ao funcionário cadastrado

### A5. Confirmação de leitura real 🟡
Hoje o "Confirmar leitura" é só visual (não persiste).

- [ ] Persistir a confirmação no banco
- [ ] Reabrir o POP mostra que já foi lido
- [ ] Nova versão volta a exigir leitura de todos

### A6. Exportar PDF 🟡
- [ ] Botão "Exportar PDF" gera o documento de verdade
- [ ] PDF com cabeçalho, versão, data e assinatura do RT

### A7. Alertas regulatórios — painel admin 🟡
Hoje os alertas são fixos. Falta você poder cadastrá-los.

- [ ] Painel (só seu) para cadastrar alertas de RDC manualmente
- [ ] Vincular alerta a um POP → sinaliza "revisar"

### A8. Onboarding / primeiro acesso 🟢
- [ ] Ao criar conta, guiar: dados do estabelecimento → equipe → primeiros POPs
- [ ] Popular biblioteca inicial a partir dos modelos-semente

### A9. Pagamentos 🔴 (para cobrar)
- [ ] Integração com gateway (Mercado Pago / Asaas / Stripe)
- [ ] Cobrar setup (R$ 47) + mensalidade (R$ 39,90 / R$ 69,90)
- [ ] Liberar/bloquear acesso conforme `status_assinatura`
- [ ] Tela "minha assinatura" (status, trocar plano, faturas)

---

## PARTE B — CONFIGURAÇÃO (você executa)

### B1. Supabase — banco 🔴
- [ ] Rodar `migration.sql` no SQL Editor (schema + RLS)
- [ ] Conferir se as 8 tabelas foram criadas
- [ ] Pegar Project URL e anon key (Settings → API)

### B2. Trocar mock por banco real 🔴
- [ ] Preencher `SUPABASE_URL` e `SUPABASE_ANON_KEY` no topo do `index.html`
- [ ] Confirmar que o aviso "MODO MOCK" sumiu do console
- [ ] Migrar a lógica de dados (hoje o app lê do MOCK em memória;
      as funções `DB.*` precisam consultar o Supabase quando conectado)

> **Atenção — este é o maior salto técnico:** hoje as telas leem do objeto
> `MOCK`. Ligar ao Supabase de verdade exige reescrever as funções `DB.*`
> para consultar as tabelas. É desenvolvimento, não só colar as chaves.
> (Item A também depende disso.)

### B3. Autenticação 🔴
- [x] Login com Google já funcionando (resolvido)
- [ ] Confirmar login por e-mail/senha no banco real
- [ ] Ajustar Site URL e Redirect URLs para o domínio final
- [ ] (Quando tiver domínio) atualizar URLs no Supabase e Google Cloud

### B4. Deploy 🔴
- [x] Já integrado ao Vercel
- [ ] Configurar variáveis / re-deploy após ligar o Supabase
- [ ] (Opcional) Domínio próprio (ex: docflow.com.br)

### B5. PWA 🟡
- [ ] Criar os ícones `icon-192.png` e `icon-512.png` (pasta /icons)
- [ ] Testar instalação no Android e iPhone

### B6. Jurídico / conformidade 🟡
- [ ] Termos de uso e política de privacidade (LGPD — vocês guardam CPF)
- [ ] Aviso de consentimento no cadastro de funcionários

---

## ORDEM SUGERIDA DE EXECUÇÃO

**Etapa 1 — Fechar o produto em modo mock** (validar tudo sem banco)
1. A3 (permissões na interface) — rápido, já temos a lógica
2. A1 + A2 (criar/editar POP + versões)
3. A4 (distribuição + leitura do colaborador) — a evidência principal
4. A5 (confirmação real de leitura)
5. A6 (exportar PDF)

**Etapa 2 — Ligar ao banco real**
6. B1 (Supabase + schema)
7. B2 (reescrever DB.* para o Supabase) ← maior esforço técnico
8. B3 (auth no banco real)

**Etapa 3 — Comercializar**
9. A9 (pagamentos)
10. B6 (jurídico/LGPD)
11. B4/B5 (domínio + ícones PWA)

---

## JÁ PRONTO (não precisa fazer)

- Login (e-mail + Google) ✓
- Multi-tenant com RLS no schema ✓
- Cadastro de funcionários com validação de CPF ✓
- Papéis e lógica de permissões (RT / Editor / Leitor) ✓
- Biblioteca de POPs (visual + navegação) ✓
- Registro de leitura (visual) ✓
- Alertas regulatórios (visual) ✓
- Planos e preços ✓
- Tema visual + responsividade (desktop/tablet/celular) ✓
- Base de PWA ✓
