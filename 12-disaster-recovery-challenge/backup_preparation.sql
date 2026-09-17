/*
    SQL Server DBA Lab
    Module 12 - Disaster Recovery Challenge

    File: backup_preparation.sql

    Objective:
    Prepare the backup chain required for a simulated
    Point-in-Time Recovery scenario.

    Recovery chain:

    FULL
      ↓
    Valid transaction #1
      ↓
    LOG_01
      ↓
    Valid transaction #2
      ↓
    Incident
      ↓
    LOG_02
*/

USE master;
GO


/* =========================================================
   1. Validate database state and recovery model

   Transaction log backups require an appropriate
   recovery model and an established log backup chain.
   ========================================================= */

SELECT
    name AS DatabaseName,
    recovery_model_desc AS RecoveryModel,
    state_desc AS DatabaseState,
    user_access_desc AS UserAccess
FROM sys.databases
WHERE name = 'DB_Laboratorio';
GO


/* =========================================================
   2. Create the FULL backup

   This FULL backup is the starting point of the
   Disaster Recovery scenario.
   ========================================================= */

BACKUP DATABASE DB_Laboratorio
TO DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DR_FULL.bak'
WITH
    INIT,
    CHECKSUM,
    STATS = 10;
GO


/* =========================================================
   3. Validate the FULL backup

   VERIFYONLY checks whether SQL Server can read and
   interpret the backup set as a restorable backup.

   It does not replace an actual restore test.
   ========================================================= */

RESTORE VERIFYONLY
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DR_FULL.bak'
WITH CHECKSUM;
GO


/* =========================================================
   4. Valid transaction #1

   This row is created after the FULL backup and must
   therefore be recovered through the transaction logs.
   ========================================================= */

USE DB_Laboratorio;
GO

INSERT INTO dbo.Clientes
(
    Nome,
    Email
)
VALUES
(
    'Cliente DR Valido',
    'dr.valido@laboratorio.local'
);
GO


/* =========================================================
   5. First transaction log backup
   ========================================================= */

USE master;
GO

BACKUP LOG DB_Laboratorio
TO DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DR_LOG_01.trn'
WITH
    INIT,
    CHECKSUM,
    STATS = 10;
GO

RESTORE VERIFYONLY
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DR_LOG_01.trn'
WITH CHECKSUM;
GO


/* =========================================================
   6. Valid transaction #2

   This transaction occurs after LOG_01 and must be
   recovered from the next transaction log backup.
   ========================================================= */

USE DB_Laboratorio;
GO

INSERT INTO dbo.Clientes
(
    Nome,
    Email
)
VALUES
(
    'Cliente DR Valido 2',
    'dr.valido2@laboratorio.local'
);
GO


/* Record a safe reference point before the incident */

SELECT
    SYSDATETIME() AS SafePoint;
GO


/* =========================================================
   IMPORTANT

   The simulated incident and LOG_02 are documented in
   the next script.

   Do not use the timestamps from the original lab run
   as universal restore values. A new execution generates
   a new recovery timeline.
   ========================================================= */
