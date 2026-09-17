/*
    SQL Server DBA Lab
    Module 12 - Disaster Recovery Challenge

    File: point_in_time_restore.sql

    Objective:
    Restore the database to a specific point in time
    immediately before the simulated destructive incident.

    Recovery sequence:

    FULL
      ↓
    LOG_01
      ↓
    LOG_02 + STOPAT
      ↓
    RECOVERY

    The restore is performed into DB_Laboratorio_DR
    so the original database is preserved for comparison.
*/

USE master;
GO


/* =========================================================
   1. Inspect logical file names

   Logical names are required when restoring the backup
   to different physical database files.
   ========================================================= */

RESTORE FILELISTONLY
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DR_FULL.bak';
GO


/* =========================================================
   2. Restore the FULL backup

   NORECOVERY keeps the database in RESTORING state
   because transaction log backups still need to be
   applied.
   ========================================================= */

RESTORE DATABASE DB_Laboratorio_DR
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DR_FULL.bak'
WITH
    MOVE 'DB_Laboratorio'
        TO 'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\DATA\DB_Laboratorio_DR.mdf',

    MOVE 'DB_Laboratorio_log'
        TO 'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\DATA\DB_Laboratorio_DR_log.ldf',

    NORECOVERY,
    CHECKSUM,
    STATS = 10;
GO


/* Validate intermediate database state */

SELECT
    name AS DatabaseName,
    state_desc AS DatabaseState
FROM sys.databases
WHERE name = 'DB_Laboratorio_DR';
GO


/* =========================================================
   3. Restore LOG_01

   NORECOVERY is used again because another transaction
   log backup must still be applied.
   ========================================================= */

RESTORE LOG DB_Laboratorio_DR
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DR_LOG_01.trn'
WITH
    NORECOVERY,
    CHECKSUM,
    STATS = 10;
GO


/* =========================================================
   4. Restore LOG_02 using STOPAT

   Laboratory execution:

   SafePoint:
   2026-09-17 16:22:30.6207864

   Incident started:
   2026-09-17 16:23:53.6862422

   STOPAT used:
   2026-09-17T16:23:53

   The selected time is after the valid transactions
   and before the destructive DELETE.

   IMPORTANT:
   This timestamp belongs specifically to this laboratory
   execution. Determine a new recovery point when repeating
   the scenario.
   ========================================================= */

RESTORE LOG DB_Laboratorio_DR
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DR_LOG_02.trn'
WITH
    STOPAT = '2026-09-17T16:23:53',
    RECOVERY,
    CHECKSUM,
    STATS = 10;
GO


/* =========================================================
   5. Validate recovered database state

   RECOVERY completes the restore sequence and makes
   the recovered database available for use.
   ========================================================= */

SELECT
    name AS DatabaseName,
    state_desc AS DatabaseState,
    recovery_model_desc AS RecoveryModel
FROM sys.databases
WHERE name = 'DB_Laboratorio_DR';
GO


/* =========================================================
   6. Validate recovered data

   Both valid transactions created after the FULL backup
   should exist in the recovered database.
   ========================================================= */

SELECT
    ClienteID,
    Nome,
    Email,
    DataCadastro
FROM DB_Laboratorio_DR.dbo.Clientes
ORDER BY ClienteID;
GO


SELECT
    ClienteID,
    Nome,
    Email,
    DataCadastro
FROM DB_Laboratorio_DR.dbo.Clientes
WHERE Nome IN
(
    'Cliente DR Valido',
    'Cliente DR Valido 2'
)
ORDER BY ClienteID;
GO
