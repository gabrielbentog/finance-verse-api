# Subscriptions API

Endpoints para gerenciar assinaturas (Subscriptions). A API segue o mesmo padrão de autenticação do projeto (Devise Token Auth).

## Endpoints

### List Subscriptions
GET /api/subscriptions

Query params (opcionais):
- `page[number]` - página
- `page[size]` - tamanho por página
- `filter[status]` - filtrar por status (active, paused, cancelled)
- `filter[frequency]` - filtrar por frequência (monthly, yearly, weekly, once)

Resposta: lista paginada de assinaturas com meta de paginação.

### Show Subscription
GET /api/subscriptions/:id

### Create Subscription
POST /api/subscriptions

Body (JSON):
```json
{
  "subscription": {
    "name": "Plano Premium",
    "category": 0,
    "amount": 29.9,
    "is_variable_amount": false,
    "payment_method": "credit_card",
    "frequency": 0,
    "next_billing_date": "2025-09-01",
    "status": 0,
    "started_at": "2025-08-01",
    "ended_at": "2026-08-01",
    "total_spent": 0.0,
    "last_used": "2025-08-01"
  }
}
```

Campos do schema (migration):

- `name` (string) - nome da assinatura (obrigatório)
- `category` (integer) - enum (ex.: service, product, membership, other)
- `amount` (float) - valor da assinatura
- `is_variable_amount` (boolean) - se o valor é variável
- `payment_method` (string) - método de pagamento (ex.: credit_card)
- `frequency` (integer) - enum (monthly, yearly, weekly, once)
- `next_billing_date` (string) - próxima data de cobrança (string conforme migration)
- `status` (integer) - enum (active, paused, cancelled)
- `started_at` / `ended_at` (date)
- `total_spent` (float) - total gasto até agora
- `last_used` (string) - último uso/registro

### Update Subscription
PUT /api/subscriptions/:id

Mesmo corpo que create — envie apenas os campos que deseja atualizar.

### Delete Subscription
DELETE /api/subscriptions/:id

## Autenticação
Todos os endpoints requerem os headers do Devise Token Auth:
```
access-token
client
uid
```

## Exemplo de resposta (single)
```json
{
  "id": "uuid-1234",
  "name": "Plano Premium",
  "category": 0,
  "amount": 29.9,
  "is_variable_amount": false,
  "payment_method": "credit_card",
  "frequency": 0,
  "next_billing_date": "2025-09-01",
  "status": 0,
  "started_at": "2025-08-01",
  "ended_at": "2026-08-01",
  "total_spent": 0.0,
  "last_used": "2025-08-01",
  "user": {
    "id": "user-uuid",
    "name": "João"
  }
}
```

## Observações
- `next_billing_date` no schema atual é `string`; se preferir manipulação de datas no backend recomendo migrar para campo `date`.
- Os valores de `category`, `frequency` e `status` são enums — internamente são inteiros; na API você pode enviar tanto o inteiro quanto a string do enum dependendo do cliente, mas sugerimos usar os valores inteiros ou as strings previstas no frontend.
- O `Filterable` do projeto já suporta filtros simples via `filter[...]`. Podemos adicionar filtros específicos (por exemplo `filter[status]`) se desejar.

Se quiser, atualizo o README com exemplos em curl/postman ou adiciono testes para esse controller.
