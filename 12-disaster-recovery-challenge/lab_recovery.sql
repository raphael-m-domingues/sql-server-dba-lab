/*
    SQL Server DBA Lab
    Module 12 - Disaster Recovery Challenge

    File: lab_recovery.sql

    Objective:
    Restore the laboratory database to a usable state
    after completing and validating the Disaster Recovery
    experiment.

    Important:
    This is a laboratory cleanup/recovery procedure.

    The actual Point-in-Time Recovery was performed in
    DB_Laboratorio_DR and is documented separately.
*/

USE master;
GO


/* =========================================================
   1. Compare databases before restoring laboratory data

   Expected state after the Disaster Recovery test:

   DB_Laboratorio
       → 0 clients after the simulated incident

   DB_Laboratorio_DR
       → 10 clients recovered before the incident
   ========================================================= */

SELECT
    (SELECT COUNT(*)
     FROM DB_Laboratorio.dbo.Clientes)
        AS OriginalClients,

    (SELECT COUNT(*)
     FROM DB_Laboratorio_DR.dbo.Clientes)
        AS RecoveredClients;
GO


/* =========================================================
   2. Restore validated rows to DB_Laboratorio

   A transaction is used so the operation can be
   validated before being permanently committed.

   IDENTITY_INSERT allows the original ClienteID values
   to be preserved.
   ========================================================= */

USE DB_Laboratorio;
GO

BEGIN TRANSACTION;
GO

SET IDENTITY_INSERT dbo.Clientes ON;
GO

INSERT INTO dbo.Clientes
(
    ClienteID,
    Nome,
    Email,
    DataCadastro
)
SELECT
    ClienteID,
    Nome,
    Email,
    DataCadastro
FROM DB_Laboratorio_DR.dbo.Clientes;
GO

SET IDENTITY_INSERT dbo.Clientes OFF;
GO


/* =========================================================
   3. Validate data before COMMIT
   ========================================================= */

SELECT
    COUNT(*) AS RestoredClients
FROM dbo.Clientes;
GO

SELECT
    ClienteID,
    Nome,
    Email,
    DataCadastro
FROM dbo.Clientes
ORDER BY ClienteID;
GO


/* =========================================================
   4. Commit only after validation

   During the laboratory this command was executed only
   after confirming that all 10 rows and their original
   identifiers had been restored correctly.

   If validation fails, use ROLLBACK instead.
   ========================================================= */

COMMIT;
GO


/* =========================================================
   5. Validate IDENTITY state

   NORESEED only reports the current identity information.
   It does not modify the identity value.
   ========================================================= */

DBCC CHECKIDENT ('dbo.Clientes', NORESEED);
GO

SELECT
    COUNT(*) AS TotalClients,
    MAX(ClienteID) AS HighestClienteID
FROM dbo.Clientes;
GO


/* =========================================================
   6. Final integrity validation
   ========================================================= */

USE master;
GO

DBCC CHECKDB ('DB_Laboratorio');
GO


/* =========================================================
   7. Final database state
   ========================================================= */

SELECT
    name AS DatabaseName,
    state_desc AS DatabaseState,
    recovery_model_desc AS RecoveryModel
FROM sys.databases
WHERE name IN
(
    'DB_Laboratorio',
    'DB_Laboratorio_DR'
);
GO
