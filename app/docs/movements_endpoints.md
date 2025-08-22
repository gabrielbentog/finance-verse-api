# Documentação da API de Movimentações Financeiras

## Endpoints de Movimentações (Movements)

### Autenticação
Todas as requisições precisam incluir os seguintes headers de autenticação:
```
access-token: seu-token-de-acesso
client: seu-client-id
uid: seu-email
```

### Listar Movimentações
```http
GET /api/movements
```

#### Parâmetros de Filtro (Query Params)
- `user_id`: Filtrar por usuário
- `movement_type`: Filtrar por tipo (income/expense)
- `category`: Filtrar por categoria
- `date_range`: Filtrar por período (formato: YYYY-MM-DD,YYYY-MM-DD)

#### Exemplo de Resposta
```json
{
  "data": [
    {
      "id": 1,
      "title": "Salário",
      "description": "Salário mensal",
      "amount": 5000.00,
      "movement_type": "income",
      "category": "Salário",
      "date": "2025-08-21",
      "created_at": "2025-08-21T10:00:00.000Z",
      "updated_at": "2025-08-21T10:00:00.000Z",
      "user": {
        "id": 1,
        "name": "João Silva"
      }
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 1,
    "total_count": 1
  }
}
```

### Obter uma Movimentação Específica
```http
GET /api/movements/:id
```

#### Exemplo de Resposta
```json
{
  "data": {
    "id": 1,
    "title": "Salário",
    "description": "Salário mensal",
    "amount": 5000.00,
    "movement_type": "income",
    "category": "Salário",
    "date": "2025-08-21",
    "created_at": "2025-08-21T10:00:00.000Z",
    "updated_at": "2025-08-21T10:00:00.000Z",
    "user": {
      "id": 1,
      "name": "João Silva"
    }
  }
}
```

### Criar uma Nova Movimentação
```http
POST /api/movements
```

#### Corpo da Requisição
```json
{
  "movement": {
    "title": "Salário",
    "description": "Salário mensal",
    "amount": 5000.00,
    "movement_type": "income",
    "category": "Salário",
    "date": "2025-08-21"
  }
}
```

#### Campos Obrigatórios
- `title`: Título da movimentação
- `amount`: Valor (deve ser maior que 0)
- `movement_type`: Tipo da movimentação ("income" ou "expense")
- `date`: Data da movimentação

### Atualizar uma Movimentação
```http
PUT /api/movements/:id
```

#### Corpo da Requisição
```json
{
  "movement": {
    "title": "Novo título",
    "description": "Nova descrição",
    "amount": 6000.00,
    "movement_type": "income",
    "category": "Salário",
    "date": "2025-08-21"
  }
}
```

### Excluir uma Movimentação
```http
DELETE /api/movements/:id
```

## Códigos de Status

- `200`: Sucesso
- `201`: Criado com sucesso
- `204`: Sem conteúdo (após exclusão)
- `401`: Não autorizado
- `404`: Não encontrado
- `422`: Erro de validação

## Observações

1. O campo `movement_type` aceita apenas dois valores:
   - `income`: Para receitas
   - `expense`: Para despesas

2. O campo `amount` deve ser sempre positivo, independente do tipo de movimentação

3. O campo `category` é livre para categorização personalizada das movimentações

4. A data (`date`) deve estar no formato "YYYY-MM-DD"
