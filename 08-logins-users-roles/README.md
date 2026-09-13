# 08 — Logins, Users & Roles

## 🎯 Objetivo

Este módulo demonstra o gerenciamento de segurança no SQL Server utilizando:

- Logins;
- Users;
- `GRANT`;
- `DENY`;
- `REVOKE`;
- Database Roles;
- Roles fixas;
- Roles customizadas;
- princípio do menor privilégio.

O objetivo foi entender como o acesso é controlado em diferentes níveis e como estruturar permissões de forma mais segura para uma aplicação.

---

## 🔐 Login x User

No SQL Server, **Login** e **User** representam níveis diferentes de segurança.

```text
SQL Server Instance
│
└── LOGIN
     │
     └── Database
          │
          └── USER
```

O Login existe no nível da instância e permite autenticação.

O User existe dentro de um banco específico e representa aquele Login naquele banco.

No laboratório foi criado:

```text
Login: app_laboratorio
        │
        └── User: app_laboratorio
             └── DB_Laboratorio
```

---

## 🧪 Teste inicial de acesso

Após criar apenas o Login, foi possível autenticar na instância utilizando:

```text
app_laboratorio
```

Porém, o acesso ao `DB_Laboratorio` foi negado.

Isso demonstrou que:

```text
Login criado
     │
     ├── conexão na instância      ✅
     └── acesso ao banco           ❌
```

Após a criação do User:

```sql
CREATE USER app_laboratorio
FOR LOGIN app_laboratorio;
```

o usuário passou a conseguir acessar o banco.

---

## 🚫 User sem permissão no objeto

Mesmo após criar o User no banco, o acesso à tabela `dbo.Clientes` ainda foi negado.

Isso demonstrou uma nova camada:

```text
Login
  ✅

User no banco
  ✅

Permissão na tabela
  ❌
```

Ter acesso ao banco não significa possuir automaticamente permissões sobre seus objetos.

---

## ✅ GRANT

Foi concedida inicialmente apenas permissão de leitura:

```sql
GRANT SELECT
ON dbo.Clientes
TO app_laboratorio;
```

Resultado:

```text
SELECT   ✅
INSERT   ❌
```

Depois, foi concedido:

```sql
GRANT INSERT
ON dbo.Clientes
TO app_laboratorio;
```

O usuário passou a conseguir inserir registros.

---

## ⛔ DENY

Foi aplicado:

```sql
DENY INSERT
ON dbo.Clientes
TO app_laboratorio;
```

A operação de `INSERT` passou a ser explicitamente negada.

O `DENY` representa uma negação explícita de permissão.

---

## 🔄 REVOKE

Para retirar a configuração explícita foi utilizado:

```sql
REVOKE INSERT
ON dbo.Clientes
FROM app_laboratorio;
```

O `REVOKE` não significa automaticamente permitir ou negar.

Ele remove a permissão explícita definida naquele nível.

```text
GRANT
  │
  └── REVOKE
        ↓
      neutro

DENY
  │
  └── REVOKE
        ↓
      neutro
```

Depois do `REVOKE`, outras permissões e memberships podem determinar o acesso efetivo.

---

## 👥 Database Roles

Administrar permissões usuário por usuário não escala bem.

Por isso, foi criada uma Role customizada:

```sql
CREATE ROLE role_leitura;
```

E atribuída a ela:

```sql
GRANT SELECT
ON dbo.Clientes
TO role_leitura;
```

Depois, o usuário foi adicionado:

```sql
ALTER ROLE role_leitura
ADD MEMBER app_laboratorio;
```

A permissão direta do usuário foi removida com:

```sql
REVOKE SELECT
ON dbo.Clientes
FROM app_laboratorio;
```

Mesmo assim, o `SELECT` continuou funcionando.

Isso confirmou que a permissão estava sendo herdada pela Role.

```text
app_laboratorio
       │
       ▼
 role_leitura
       │
       └── GRANT SELECT
              │
              ▼
         dbo.Clientes
```

---

## ⚔️ DENY direto x GRANT por Role

Foi realizado um teste de conflito:

```text
role_leitura
└── GRANT SELECT

app_laboratorio
└── DENY SELECT
```

Resultado:

```text
SELECT ❌
```

O `DENY` direto bloqueou o acesso, mesmo com o `GRANT` recebido pela Role.

Depois:

```sql
REVOKE SELECT
ON dbo.Clientes
FROM app_laboratorio;
```

removeu a negação explícita e o usuário voltou a herdar o `GRANT SELECT` da Role.

---

## 📚 Roles fixas

Também foram testadas roles fixas do SQL Server.

### db_datareader

Permitiu leitura em diferentes tabelas do banco, como:

```text
dbo.Clientes
dbo.Produtos
```

Isso mostrou que `db_datareader` possui escopo amplo.

### db_datawriter

Permitiu operações de escrita como:

```text
INSERT
UPDATE
```

em tabelas do banco.

Essas roles são práticas, mas podem conceder mais acesso do que uma aplicação realmente necessita.

---

## 🎯 Role customizada de escrita

Foi criada:

```sql
CREATE ROLE role_clientes_writer;
```

Com permissões restritas:

```sql
GRANT INSERT, UPDATE
ON dbo.Clientes
TO role_clientes_writer;
```

O usuário foi então adicionado à Role:

```sql
ALTER ROLE role_clientes_writer
ADD MEMBER app_laboratorio;
```

Resultado:

```text
dbo.Clientes
├── INSERT   ✅
├── UPDATE   ✅
└── DELETE   ❌

dbo.Produtos
└── escrita  ❌
```

Isso demonstrou a vantagem de roles customizadas para aplicação do princípio do menor privilégio.

---

## 👑 db_owner

A role `db_owner` também foi testada temporariamente.

Foi verificado que ela concede permissões muito amplas dentro do banco.

O usuário foi adicionado apenas para validação e depois removido.

Isso reforçou que utilizar `db_owner` para contas de aplicação geralmente concede permissões muito além do necessário.

---

## 🛡️ Modelo final de segurança

O modelo final ficou:

```text
app_laboratorio
│
├── role_leitura
│    └── SELECT → dbo.Clientes
│
└── role_clientes_writer
     ├── INSERT → dbo.Clientes
     └── UPDATE → dbo.Clientes
```

Permissões efetivas:

```text
dbo.Clientes
├── SELECT   ✅
├── INSERT   ✅
├── UPDATE   ✅
└── DELETE   ❌

dbo.Produtos
└── SELECT   ❌
```

Esse modelo oferece somente as permissões necessárias para a aplicação.

---

## 🔎 Diagnóstico

As permissões foram analisadas utilizando views de catálogo como:

```text
sys.server_principals
sys.database_principals
sys.database_role_members
sys.database_permissions
```

Também foram utilizados:

```sql
SUSER_SNAME()
USER_NAME()
HAS_PERMS_BY_NAME()
```

para validar identidade e permissões efetivas.

---

## 📂 Scripts

```text
08-logins-users-roles/
├── security_lab.sql
├── security_diagnostics.sql
└── README.md
```

---

## 📌 Aprendizados

Neste módulo foram praticados:

- diferença entre Login e User;
- autenticação SQL Server;
- permissões no nível do banco;
- permissões no nível de objeto;
- `GRANT`;
- `DENY`;
- `REVOKE`;
- memberships em Roles;
- Roles fixas;
- Roles customizadas;
- permissões herdadas;
- permissões conflitantes;
- princípio do menor privilégio;
- validação de permissões por catálogo;
- modelagem de segurança para contas de aplicação.

---

## ⚠️ Observação

O Login criado neste laboratório foi utilizado exclusivamente para fins didáticos.

Em ambientes reais, credenciais de aplicações devem ser protegidas adequadamente e nunca armazenadas diretamente em código-fonte ou repositórios públicos.
