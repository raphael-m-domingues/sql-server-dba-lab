/*
    SQL Server DBA Lab
    Module 12 - Disaster Recovery Challenge

    File: recovery_validation.sql

    Objective:
    Validate the Point-in-Time Recovery result using
    data comparison, backup history, LSN information
    and database integrity checks.
*/

USE master;
GO


/* =========================================================
   1. Compare original and recovered databases

   At this point in the laboratory:

   DB_Laboratorio
       → Contains the simulated incident
       → dbo.Clientes has 0 rows

   DB_Laboratorio_DR
       → Restored to the point before the incident
       → dbo.Clientes has 10 rows
   ========================================================= */

SELECT
    'ORIGINAL - AFTER INCIDENT' AS DatabaseState,
    COUNT(*) AS TotalClients
FROM DB_Laboratorio.dbo.Clientes

UNION ALL

SELECT
    'RECOVERED - BEFORE INCIDENT' AS DatabaseState,
    COUNT(*) AS TotalClients
FROM DB_Laboratorio_DR.dbo.Clientes;
GO


/* =========================================================
   2. Validate transactions created after the FULL backup

   These rows did not exist in the initial FULL backup.

   Their presence demonstrates that transaction log
   backups were successfully applied during recovery.
   ========================================================= */

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


/* =========================================================
   3. Inspect the backup chain

   msdb stores backup history.

   first_lsn and last_lsn help demonstrate the logical
   relationship between the transaction log backups.
   ========================================================= */

USE msdb;
GO

SELECT
    bs.database_name AS DatabaseName,

    CASE bs.type
        WHEN 'D' THEN 'FULL'
        WHEN 'I' THEN 'DIFFERENTIAL'
        WHEN 'L' THEN 'LOG'
        ELSE bs.type
    END AS BackupType,

    bs.backup_start_date AS BackupStart,
    bs.backup_finish_date AS BackupFinish,

    bs.first_lsn AS FirstLSN,
    bs.last_lsn AS LastLSN,
    bs.database_backup_lsn AS DatabaseBackupLSN,

    bmf.physical_device_name AS BackupFile

FROM dbo.backupset AS bs

INNER JOIN dbo.backupmediafamily AS bmf
    ON bs.media_set_id = bmf.media_set_id

WHERE bs.database_name = 'DB_Laboratorio'
  AND
  (
      bmf.physical_device_name LIKE
          '%DB_Laboratorio_DR_FULL.bak'

      OR bmf.physical_device_name LIKE
          '%DB_Laboratorio_DR_LOG_01.trn'

      OR bmf.physical_device_name LIKE
          '%DB_Laboratorio_DR_LOG_02.trn'
  )

ORDER BY bs.backup_start_date;
GO


/* =========================================================
   4. Validate recovered database state
   ========================================================= */

USE master;
GO

SELECT
    name AS DatabaseName,
    state_desc AS DatabaseState,
    recovery_model_desc AS RecoveryModel
FROM sys.databases
WHERE name = 'DB_Laboratorio_DR';
GO


/* =========================================================
   5. Validate recovered database integrity

   CHECKDB performs consistency checks against the
   recovered database and its internal structures.
   ========================================================= */

DBCC CHECKDB ('DB_Laboratorio_DR');
GO


/* =========================================================
   6. Final recovered-data validation
   ========================================================= */

SELECT
    COUNT(*) AS TotalRecoveredClients
FROM DB_Laboratorio_DR.dbo.Clientes;
GO

SELECT
    ClienteID,
    Nome,
    Email,
    DataCadastro
FROM DB_Laboratorio_DR.dbo.Clientes
WHERE ClienteID IN (1010, 1011)
ORDER BY ClienteID;
GO
