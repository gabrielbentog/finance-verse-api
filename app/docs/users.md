# Users API Guide

Este documento explica como utilizar os endpoints da controller `UsersController` e detalha os campos do modelo `User` com seus tipos.

---

## Campos do Usuário

| Campo                    | Tipo     | Descrição                      |
| ------------------------ | -------- | ------------------------------ |
| `id`                     | integer  | Identificador único do usuário |
| `name`                   | string   | Nome completo                  |
| `email`                  | string   | E-mail do usuário              |
| `password`               | string   | Senha (apenas para criação)    |
| `password_confirmation`  | string   | Confirmação de senha           |
| `avatar`                 | string   | URL da imagem de avatar        |
| `otp_required_for_login` | boolean  | 2FA obrigatório no login       |
| `created_at`             | datetime | Data de criação                |
| `updated_at`             | datetime | Data de atualização            |

---

## Endpoints

### 1. Listar Usuários

**GET** `/api/users`

Retorna todos os usuários (pode aplicar filtros via query params).

**Exemplo de resposta:**

```json
[
  {
    "id": 1,
    "name": "Alice",
    "email": "alice@email.com",
    "avatarUrl": "https://...",
    "otpRequiredForLogin": true
  },
  ...
]
```

---

### 2. Visualizar Usuário

**GET** `/api/users/:id`

Retorna os dados de um usuário específico.

---

### 3. Criar Usuário

**POST** `/api/users`

**Body:**

```json
{
  "user": {
    "name": "Alice",
    "email": "alice@email.com",
    "password": "senha123",
    "password_confirmation": "senha123",
    "avatar": "https://...",
    "otp_required_for_login": false
  }
}
```

**Resposta:**

- Usuário criado e token de autenticação nos headers.

---

### 4. Atualizar Usuário

**PUT/PATCH** `/api/users/:id`

**Body:**

```json
{
  "user": {
    "name": "Novo Nome",
    "avatar": "https://novaurl.com/avatar.png"
  }
}
```

---

### 5. Deletar Usuário

**DELETE** `/api/users/:id`

Remove o usuário do sistema.

---

## Observações

- O campo `otp_required_for_login` ativa a exigência de autenticação em dois fatores no login.
- O campo `avatar` deve ser uma URL válida de imagem.
- O token de autenticação é retornado nos headers após o cadastro.
- Para ações protegidas, envie o header `Authorization: Bearer <token>`.

---
