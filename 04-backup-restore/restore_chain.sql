/*
=========================================================
 SQL Server DBA Lab
 Módulo 04: Backup & Restore
 Etapa: Restore Chain
=========================================================

Objetivo:
Demonstrar a restauração de um FULL Backup seguido
por backups do Transaction Log.

O banco é restaurado com outro nome para preservar
o banco original durante o laboratório.
*/

USE master;
GO


/*
=========================================================
 1. Restaurar o FULL Backup
=========================================================

NORECOVERY mantém o banco no estado RESTORING,
permitindo aplicar backups adicionais.
*/

RESTORE DATABASE DB_Laboratorio_Restore
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_FULL.bak'
WITH
    MOVE 'DB_Laboratorio'
        TO 'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\DATA\DB_Laboratorio_Restore.mdf',

    MOVE 'DB_Laboratorio_log'
        TO 'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\DATA\DB_Laboratorio_Restore_log.ldf',

    NORECOVERY,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 2. Aplicar LOG Backup 01
=========================================================
*/

RESTORE LOG DB_Laboratorio_Restore
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_LOG_01.trn'
WITH
    NORECOVERY,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 3. Aplicar LOG Backup 02
=========================================================

RECOVERY finaliza a sequência de restore e coloca
o banco novamente disponível para utilização.
*/

RESTORE LOG DB_Laboratorio_Restore
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_LOG_02.trn'
WITH
    RECOVERY,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 4. Verificar o banco restaurado
=========================================================
*/

SELECT
    name,
    state_desc,
    recovery_model_desc
FROM sys.databases
WHERE name = 'DB_Laboratorio_Restore';
GO
