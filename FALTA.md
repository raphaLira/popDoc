# DocFlow AI — O que falta (Checklist atualizado)

Situação após implementar: criação de POP (modelo/do zero), editor,
versionamento, aprovação, permissões, modelos da SESA-PR 590/2014 +
genéricos, e seletor de estado.

Prioridade: essencial (ALTA) · importante (MEDIA) · desejável (BAIXA)

---

## DESENVOLVIMENTO (código)

### Fluxo de POP — o que ainda falta
- [ ] [ALTA] A4 — Distribuicao + leitura do colaborador: tela "Distribuir"
      com link e QR Code; pagina publica onde o funcionario abre, se
      identifica (CPF) e confirma leitura. E a evidencia principal de
      fiscalizacao e o maior valor pendente.
- [ ] [ALTA] A5 — Confirmacao de leitura real: hoje o "Confirmar leitura"
      e visual. Precisa persistir, amarrar ao CPF do funcionario e voltar
      a exigir leitura quando sai nova versao.
- [ ] [MEDIA] A6 — Exportar PDF: gerar o documento com cabecalho, versao,
      data e assinatura do RT (hoje o botao e um aviso).
- [ ] [MEDIA] Importar Word/PDF: o caminho "importar arquivo" esta como
      "em breve" na tela de novo POP.
- [ ] [BAIXA] Criar com IA: idem, marcado como "em breve".

### Modelos e conteudo
- [ ] [MEDIA] Revisar os 8 modelos do Parana com um RT antes de producao
      (checar retificacoes: Res. 592/2014 e 781/2020).
- [ ] [MEDIA] Adicionar modelos de outros estados conforme conseguir a
      base legal (SP, SC, RS, MG... um a um).
- [ ] [BAIXA] Modelos para farmacia com manipulacao (RDC 67/2007) e
      vacinacao (Res. SESA 473/2016), que tem exigencias extras.

### Gestao e permissoes
- [ ] [MEDIA] A3 (resto): testar entrando como Editor e Leitor de verdade
      (a logica existe; falta validar cada papel na pratica).
- [ ] [MEDIA] Painel admin (so seu) para cadastrar os alertas
      regulatorios manualmente — hoje sao fixos no codigo.
- [ ] [BAIXA] Onboarding do primeiro acesso (guiar: estabelecimento ->
      equipe -> primeiros POPs a partir dos modelos).

### Comercial
- [ ] [ALTA] A9 — Pagamentos: gateway (Mercado Pago / Asaas / Stripe),
      cobrar setup (R$ 47) + mensalidade, liberar acesso conforme o
      status da assinatura. E um mini-projeto a parte.
- [ ] [MEDIA] Tela "minha assinatura" (status, trocar plano, faturas).

---

## PERSISTENCIA — o maior salto tecnico

- [ ] [ALTA] Ligar ao Supabase de verdade. Hoje tudo vive em memoria
      (objeto MOCK) e some ao recarregar. Isso e esperado nesta fase.
      Para persistir, e preciso reescrever as funcoes DB.* para
      consultar as tabelas do Supabase.
- [ ] [ALTA] Ajustar o migration.sql: adicionar as colunas novas que
      criamos depois (conteudo do POP, versoes, uf do estabelecimento,
      base legal do modelo).
- [ ] [ALTA] Migrar os dados mockados (modelos, alertas) para o banco.

> Enquanto o Supabase nao estiver ligado, tudo que voce criar/editar
> no app some ao atualizar a pagina. E normal — a fase atual e de
> montar e validar as telas e os fluxos.

---

## CONFIGURACAO (voce executa)

- [x] Login com Google — funcionando
- [x] Deploy no Vercel — funcionando
- [ ] [ALTA] Supabase: rodar o migration.sql, pegar as chaves
- [ ] [ALTA] Colar as chaves no topo do index.html
- [ ] [MEDIA] Confirmar login por e-mail/senha no banco real
- [ ] [MEDIA] Criar os icones do PWA (icon-192.png, icon-512.png)
- [ ] [MEDIA] Termos de uso + politica de privacidade (LGPD — guarda CPF)
- [ ] [BAIXA] Dominio proprio (ex: docflow.com.br)

---

## JA PRONTO

- Login (e-mail + Google) e multi-tenant com RLS no schema
- Cadastro de funcionarios com validacao de CPF e papeis (RT/Editor/Leitor)
- Biblioteca de POPs, navegacao, tema visual e responsividade
- Criar POP (usar modelo ou do zero) + editor
- Versionamento (cada save = nova versao) + historico
- Fluxo de aprovacao (rascunho -> aprovacao -> vigente) com permissoes
- Modelos da SESA-PR 590/2014 (8, com base legal citada por artigo)
- Modelos genericos (6, para qualquer estado)
- Seletor de estado (27 UFs) com cobertura por curadoria
- Registro de leitura e alertas regulatorios (visual)
- Planos e precos, base de PWA

---

## SUGESTAO DE ORDEM

1. A4 + A5 (distribuicao + leitura real) — completa o ciclo de valor
2. A6 (PDF) — muito pedido em fiscalizacao
3. Supabase (persistencia) — para nada mais sumir
4. Pagamentos — para comecar a cobrar
5. LGPD, icones PWA, dominio — antes de abrir para clientes
