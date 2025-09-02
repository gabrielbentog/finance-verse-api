# Two Factor Authentication (2FA) Integration Guide

Este guia explica como integrar o fluxo de autenticação em dois fatores (2FA) no front-end utilizando a API do Finance Verse.

## 1. Cadastro do Usuário

O usuário realiza o cadastro normalmente via endpoint `/api/users` enviando nome, e-mail e senha.

## 2. Login Inicial

O usuário faz login via endpoint `/api/authenticate` e recebe um token de sessão.

## 3. Ativação do 2FA

Para ativar o 2FA, o front-end deve chamar o endpoint:

```
POST /api/users/:id/two_factor/enable
Headers: Authorization: Bearer <token>
```

A resposta trará um QR Code (base64 ou URL) para ser escaneado no app autenticador (Google Authenticator, Authy, etc).

## 4. Validação do Código 2FA

Após escanear o QR Code, o usuário deve informar o código gerado pelo app autenticador:

```
POST /api/users/:id/two_factor/verify
Body: { code: "123456" }
Headers: Authorization: Bearer <token>
```

Se o código estiver correto, o 2FA será ativado para o usuário.

## 5. Login com 2FA

Após ativar o 2FA, o login terá dois passos:

1. Usuário faz login normalmente e recebe resposta informando que o 2FA está habilitado.
2. Front-end solicita o código 2FA ao usuário e envia para:

```
POST /api/auth/two_factor
Body: { code: "123456" }
Headers: Authorization: Bearer <token>
```

Se o código estiver correto, o usuário terá acesso completo.

## 6. Desativar 2FA

Para desativar o 2FA:

```
POST /api/users/:id/two_factor/disable
Headers: Authorization: Bearer <token>
```

---

## Exemplos de Fluxo

1. **Ativar 2FA:**

   - Usuário acessa configurações de segurança
   - Front-end chama `/enable` e exibe QR Code
   - Usuário escaneia e informa código
   - Front-end chama `/verify` para ativar

2. **Login com 2FA:**
   - Usuário faz login
   - Se 2FA ativo, front-end exibe campo para código
   - Front-end chama `/two_factor` para validar

---

## Observações

- O front-end deve tratar erros de código inválido e informar o usuário.
- O QR Code pode ser exibido usando uma tag `<img>` se vier em base64.
- Recomenda-se informar ao usuário para salvar códigos de backup.

---

Qualquer dúvida, consulte a equipe de backend ou o README da API.
