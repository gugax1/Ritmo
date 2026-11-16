# Ritmo — piloto
Landing page e plataforma Next.js com Supabase Auth e banco Postgres com RLS.

## Acesso
- Site: https://ritmo-digital.vercel.app
- Sistema: https://ritmo-digital.vercel.app/app

## Desenvolvimento
`npm install`, `npm run dev`. Build: `npm run build`.
Para os testes: `npm install --no-save playwright`, `npx playwright install --with-deps chromium`, inicie `npm run start` e execute `node tests/flow.cjs`.

## Validação de 16/11/2026
Build com Next 16.4.6 / React 19.3.1 aprovado. Auditoria das dependências de produção sem vulnerabilidades conhecidas.
Playwright: página inicial, largura 390px, cadastro, nome de usuário, senha visível, senhas divergentes, estado de e-mail pendente com resposta simulada, demonstração e navegação.
E2E com conta real isolada no Supabase: login, academia, aluno, pagamento, regra, simulação, confirmação de pagamento e sessão após recarga. A conta e os dados de teste foram removidos.
A entrega de confirmação por e-mail não foi testada ponta a ponta; exige configuração de SMTP e URLs no Supabase.

## Estado do produto
O modo real salva registros no banco, mas as automações são simulações. Sem envios reais, webhooks ou agendamento automático. O nome de usuário é de exibição; login por e-mail.
O vidro web é CSS em barras e botões. expo-glass-effect é destinado ao aplicativo nativo iOS.

## Configuração necessária
Supabase Auth: configure a Site URL e Redirect URLs para https://ritmo-digital.vercel.app/app e SMTP próprio. Não exponha credenciais de servidor.
Banco: database/schema.sql é a migration aplicada no projeto, com isolamento por academia e regras de simulação.
