/*
=========================================================
 SQL Server DBA Lab
 Módulo 08: Logins, Users & Roles
 Script: Security Lab
=========================================================

Objetivo:
Documentar os principais testes de segurança realizados
no banco DB_Laboratorio:

- criação de Login;
- criação de User;
- GRANT, DENY e REVOKE;
- criação de Database Roles;
- comparação com roles fixas;
- aplicação do princípio do menor privilégio.
=========================================================
*/


/*
---------------------------------------------------------
 1. Criar Login no nível da instância
---------------------------------------------------------
*/

USE master;
GO

CREATE LOGIN app_laboratorio
WITH PASSWORD = 'Lab_SQL_2026!Seguranca#84',
     CHECK_POLICY = ON,
     CHECK_EXPIRATION = OFF;
GO


/*
---------------------------------------------------------
 2. Criar User no banco
---------------------------------------------------------
*/

USE DB_Laboratorio;
GO

CREATE USER app_laboratorio
FOR LOGIN app_laboratorio;
GO


/*
---------------------------------------------------------
 3. Conceder SELECT diretamente ao usuário
---------------------------------------------------------
*/

GRANT SELECT
ON dbo.Clientes
TO app_laboratorio;
GO


/*
---------------------------------------------------------
 4. Conceder INSERT diretamente
---------------------------------------------------------
*/

GRANT INSERT
ON dbo.Clientes
TO app_laboratorio;
GO


/*
---------------------------------------------------------
 5. Aplicar DENY
---------------------------------------------------------
*/

DENY INSERT
ON dbo.Clientes
TO app_laboratorio;
GO


/*
---------------------------------------------------------
 6. Remover permissão explícita com REVOKE
---------------------------------------------------------
*/

REVOKE INSERT
ON dbo.Clientes
FROM app_laboratorio;
GO


/*
---------------------------------------------------------
 7. Criar role customizada de leitura
---------------------------------------------------------
*/

CREATE ROLE role_leitura;
GO

GRANT SELECT
ON dbo.Clientes
TO role_leitura;
GO

ALTER ROLE role_leitura
ADD MEMBER app_laboratorio;
GO


/*
---------------------------------------------------------
 8. Remover GRANT direto para testar herança pela Role
---------------------------------------------------------
*/

REVOKE SELECT
ON dbo.Clientes
FROM app_laboratorio;
GO


/*
---------------------------------------------------------
 9. Criar role customizada de escrita
---------------------------------------------------------
*/

CREATE ROLE role_clientes_writer;
GO

GRANT INSERT, UPDATE
ON dbo.Clientes
TO role_clientes_writer;
GO

ALTER ROLE role_clientes_writer
ADD MEMBER app_laboratorio;
GO


/*
---------------------------------------------------------
 10. Modelo final de menor privilégio
---------------------------------------------------------

 app_laboratorio

    role_leitura
        SELECT → dbo.Clientes

    role_clientes_writer
        INSERT → dbo.Clientes
        UPDATE → dbo.Clientes

 Resultado esperado:

 dbo.Clientes
    SELECT  ✅
    INSERT  ✅
    UPDATE  ✅
    DELETE  ❌

 dbo.Produtos
    SELECT  ❌
---------------------------------------------------------
*/
