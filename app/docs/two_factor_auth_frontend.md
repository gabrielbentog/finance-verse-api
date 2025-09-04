# Two Factor Authentication (2FA) - Frontend Integration Guide

Este guia explica como integrar o fluxo de autenticação em dois fatores (2FA) no front-end utilizando a API do Finance Verse.

---

## Fluxo Completo

### 1. Cadastro e Login Inicial

- Usuário se cadastra normalmente.
- Usuário faz login e recebe o token de autenticação.

---

### 2. Configuração do 2FA

**Endpoint:**  
`POST /api/two_factor/setup`  
**Headers:**  
`Authorization: Bearer <token>`

**Resposta:**

```json
{
  "issuer": "FinanceVerse",
  "account": "user@email.com",
  "secret": "ABC123...",
  "provisioning_uri": "otpauth://totp/FinanceVerse:user@email.com?secret=ABC123...",
  "qr_svg": "<svg ...>...</svg>",
  "qr_svg_data_uri": "data:image/svg+xml;base64,PHN2ZyB4bWxucz0i..."
}
```

- O front-end deve gerar e exibir o QR Code usando o `provisioning_uri`.
- O usuário escaneia o QR Code no app autenticador (Google Authenticator, Authy, etc).

Nota: o backend agora tenta gerar o QR em SVG (campo `qr_svg`) e também fornece `qr_svg_data_uri` (base64) para uso direto em uma tag `<img>` quando a gem `rqrcode` está disponível. Se o backend não fornecer `qr_svg*`, siga a seção "Gerar QR no frontend" abaixo.

---

### 3. Ativação do 2FA

**Endpoint:**  
`POST /api/two_factor/enable`  
**Body:**

```json
{ "code": "123456" }
```

**Headers:**  
`Authorization: Bearer <token>`

**Resposta:**

```json
{
  "enabled": true,
  "backup_codes": ["CODE1", "CODE2", ...]
}
```

- O usuário informa o código gerado pelo app autenticador.
- Se o código estiver correto, o 2FA é ativado e os backup codes são exibidos.

---

### 4. Login com 2FA Ativo

- Usuário faz login normalmente.
- Se o usuário tiver 2FA ativo, o backend retorna um `temp_auth_token` ao invés do token de sessão.

**Exemplo de resposta do login:**

```json
{
  "two_factor_required": true,
  "temp_auth_token": "<token>"
}
```

- O front-end solicita o código 2FA ao usuário.

**Endpoint:**  
`POST /api/two_factor_verification`  
**Body:**

```json
{
  "temp_auth_token": "<token recebido>",
  "code": "123456"
}
```

**Resposta:**

```json
{
  "message": "2FA verified",
  "user": { ...dados do usuário... }
}
```

- Se o código estiver correto, o usuário recebe o token de autenticação nos headers.

---

### 5. Backup Codes

**Regenerar Backup Codes:**  
`POST /api/two_factor/regenerate_backup_codes`  
**Headers:**  
`Authorization: Bearer <token>`

**Resposta:**

```json
{
  "backup_codes": ["NEWCODE1", "NEWCODE2", ...]
}
```

---

### 6. Desativar 2FA

**Endpoint:**  
`POST /api/two_factor/disable`  
**Headers:**  
`Authorization: Bearer <token>`

**Resposta:**

```json
{ "enabled": false }
```

---

## Observações

- O QR Code pode ser exibido usando uma tag `<img>` se vier em base64, ou usando uma lib de QR Code com o `provisioning_uri`.
- Sempre informe ao usuário para guardar os backup codes em local seguro.
- Trate erros de código inválido e token expirado no front-end.
- O fluxo correto é: setup → enable → login (com 2FA) → verification.

Gerar/Renderizar o QR no frontend (opções)

1. Usando `qr_svg_data_uri` (mais simples)

```jsx
// React example
function QRImage({ dataUri }) {
  if (!dataUri) return null;
  return <img src={dataUri} alt="2FA QR Code" />;
}
```

2. Usando `qr_svg` (inserir SVG cru)

```jsx
// React example (careful with innerHTML)
function QRSvg({ svg }) {
  if (!svg) return null;
  return <div dangerouslySetInnerHTML={{ __html: svg }} />;
}
```

3. Gerar o QR no frontend a partir do `provisioning_uri` (sem depender do backend gerar o SVG)

```js
// npm install qrcode
import QRCode from "qrcode";

async function renderQrFromUri(container, provisioningUri) {
  const svg = await QRCode.toString(provisioningUri, { type: "svg" });
  container.innerHTML = svg; // container is a DOM element
}
```

Segurança e recomendações

- Prefira usar `qr_svg_data_uri` com `<img>` quando disponível — é simples e evita innerHTML.
- Se usar `dangerouslySetInnerHTML`, garanta que o conteúdo vem do seu backend confiável.
- Se optar por gerar no frontend, o `provisioning_uri` é suficiente e evita depender da gem `rqrcode` no servidor.

Backend: instalar gem para geração automática do QR (opcional)

1. No `Gemfile` adicione:

```ruby
gem 'rqrcode'
```

2. Rode:

```bash
bundle install
```

Isso permitirá que o backend retorne `qr_svg` e `qr_svg_data_uri` automaticamente.

---

Qualquer dúvida, consulte a equipe de backend ou o README da
