/*
=========================================================
 SQL Server DBA Lab
 Módulo 04: Backup & Restore
 Etapa: Transaction Log Backup
=========================================================

Objetivo:
Demonstrar a criação sequencial de backups do
Transaction Log do banco DB_Laboratorio.

Pré-requisito:
O banco deve utilizar um Recovery Model compatível
com backups de log e possuir uma cadeia de log válida.
*/

USE master;
GO


-- Verificar o Recovery Model
SELECT
    name AS DatabaseName,
    recovery_model_desc AS RecoveryModel
FROM sys.databases
WHERE name = 'DB_Laboratorio';
GO


/*
=========================================================
 LOG Backup 01
=========================================================
*/

BACKUP LOG DB_Laboratorio
TO DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_LOG_01.trn'
WITH
    INIT,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 LOG Backup 02
=========================================================
*/

BACKUP LOG DB_Laboratorio
TO DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_LOG_02.trn'
WITH
    INIT,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 Histórico de backups
=========================================================
*/

SELECT
    bs.database_name,
    bs.type AS BackupType,
    bs.backup_start_date,
    bs.backup_finish_date,
    CAST(bs.backup_size / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS BackupSizeMB
FROM msdb.dbo.backupset AS bs
WHERE bs.database_name = 'DB_Laboratorio'
ORDER BY bs.backup_finish_date DESC;
GO
