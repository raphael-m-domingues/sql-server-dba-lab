/*
=========================================================
 SQL Server DBA Lab
 Módulo 08: Logins, Users & Roles
 Script: Security Diagnostics
=========================================================

Objetivo:
Consultar e validar os principais componentes de
segurança utilizados no laboratório.

Inclui:
- Logins da instância;
- Users do banco;
- mapeamento Login -> User;
- memberships em Database Roles;
- permissões explícitas;
- permissões efetivas.
=========================================================
*/


/*
---------------------------------------------------------
 1. Consultar Login da instância
---------------------------------------------------------
*/

USE master;
GO

SELECT
    name,
    type_desc,
    is_disabled,
    create_date
FROM sys.server_principals
WHERE name = 'app_laboratorio';
GO


/*
---------------------------------------------------------
 2. Consultar User no banco
---------------------------------------------------------
*/

USE DB_Laboratorio;
GO

SELECT
    name,
    type_desc,
    authentication_type_desc
FROM sys.database_principals
WHERE name = 'app_laboratorio';
GO


/*
---------------------------------------------------------
 3. Validar mapeamento Login -> User
---------------------------------------------------------
*/

SELECT
    dp.name AS DatabaseUser,
    sp.name AS ServerLogin
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp
    ON dp.sid = sp.sid
WHERE dp.name = 'app_laboratorio';
GO


/*
---------------------------------------------------------
 4. Consultar Database Roles do usuário
---------------------------------------------------------
*/

SELECT
    r.name AS RoleName,
    m.name AS MemberName
FROM sys.database_role_members AS drm
INNER JOIN sys.database_principals AS r
    ON drm.role_principal_id = r.principal_id
INNER JOIN sys.database_principals AS m
    ON drm.member_principal_id = m.principal_id
WHERE m.name = 'app_laboratorio'
ORDER BY r.name;
GO


/*
---------------------------------------------------------
 5. Consultar permissões explícitas
---------------------------------------------------------
*/

SELECT
    dp.name AS Principal,
    p.state_desc AS Estado,
    p.permission_name AS Permissao,
    OBJECT_SCHEMA_NAME(p.major_id) AS Esquema,
    OBJECT_NAME(p.major_id) AS Objeto
FROM sys.database_permissions AS p
INNER JOIN sys.database_principals AS dp
    ON p.grantee_principal_id = dp.principal_id
WHERE dp.name IN
(
    'app_laboratorio',
    'role_leitura',
    'role_clientes_writer'
)
ORDER BY dp.name, p.permission_name;
GO


/*
---------------------------------------------------------
 6. Verificar identidade da sessão atual
---------------------------------------------------------
*/

SELECT
    SUSER_SNAME() AS LoginAtual,
    USER_NAME() AS UsuarioAtual;
GO


/*
---------------------------------------------------------
 7. Verificar permissões efetivas
---------------------------------------------------------
*/

SELECT
    HAS_PERMS_BY_NAME(
        'dbo.Clientes',
        'OBJECT',
        'SELECT'
    ) AS PodeSelectClientes,

    HAS_PERMS_BY_NAME(
        'dbo.Clientes',
        'OBJECT',
        'INSERT'
    ) AS PodeInsertClientes,

    HAS_PERMS_BY_NAME(
        'dbo.Clientes',
        'OBJECT',
        'UPDATE'
    ) AS PodeUpdateClientes,

    HAS_PERMS_BY_NAME(
        'dbo.Clientes',
        'OBJECT',
        'DELETE'
    ) AS PodeDeleteClientes;
GO


/*
---------------------------------------------------------
 8. Verificar acesso a Produtos
---------------------------------------------------------
*/

SELECT
    HAS_PERMS_BY_NAME(
        'dbo.Produtos',
        'OBJECT',
        'SELECT'
    ) AS PodeSelectProdutos;
GO
