---
# Definir master.key

## 1. Fazer backup do que existe

```bash
mkdir -p tmp/credentials_backup
cp -a config/credentials.yml.enc tmp/credentials_backup/

# Se tiver a chave atual, exporte o conteúdo em texto legível:
EDITOR="nano" bin/rails credentials:show > tmp/credentials_backup/global.plain.yml
```

- O arquivo `global.plain.yml` conterá as credenciais atuais em formato YAML.
- Guarde-o em local seguro (não commit no Git).

---

## 2. Remover o par antigo e gerar um novo

```bash
rm -f config/credentials.yml.enc config/master.key
EDITOR="nano" bin/rails credentials:edit
```

- Será criado um novo **`credentials.yml.enc`** (pode commitar) e **`master.key`** (NÃO commitar).
- Se tiver o backup `global.plain.yml`, cole o conteúdo no editor e salve.

---

## 3. Testar localmente

```bash
bin/rails credentials:show
```

Se imprimir o YAML sem erro, está tudo certo.

---

## 4. Commit e push

```bash
git add config/credentials.yml.enc
git commit -m "Rotate global credentials"
git push
```

---

## 5. Guardar a nova chave com segurança

- Salve o **conteúdo de `config/master.key`** em:
  - Um Password Manager seguro (1Password, Bitwarden, etc.).
  - O Secret Manager da sua infraestrutura (AWS Secrets Manager, GCP Secret Manager, Kubernetes Secret, etc.).
- Em **produção**, defina:
  ```bash
  RAILS_MASTER_KEY=<conteúdo de config/master.key>
  ```

> Em desenvolvimento, **não** exporte `RAILS_MASTER_KEY` no shell; o Rails lerá automaticamente o `config/master.key`.

---

## 6. Garantir exigência da chave em produção

Verifique se `config/environments/production.rb` tem:

```ruby
config.require_master_key = true
```

Isso impede que o app suba sem a chave correta.

---

## 7. Resumo do fluxo

1. **Backup** do `.enc` e (se possível) do conteúdo descriptografado.
2. **Remover** `credentials.yml.enc` e `master.key` antigos.
3. **Gerar** novos com `rails credentials:edit`.
4. **Commitar** o novo `.enc`.
5. **Guardar** o novo `master.key` em local seguro.
6. **Definir** `RAILS_MASTER_KEY` no ambiente de produção.
7. **Testar** o acesso com `rails credentials:show` antes de subir o app.

---
