/*
=========================================================
 SQL Server DBA Lab
 Módulo 05: Point-in-Time Recovery
 Etapa: Restore com STOPAT
=========================================================

Objetivo:
Restaurar o banco para um ponto no tempo anterior
à exclusão acidental de um registro.
*/

USE master;
GO


/*
=========================================================
 1. Restaurar FULL Backup
=========================================================
*/

RESTORE DATABASE DB_Laboratorio_PointInTime
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_FULL.bak'
WITH
    MOVE 'DB_Laboratorio'
        TO 'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\DATA\DB_Laboratorio_PointInTime.mdf',

    MOVE 'DB_Laboratorio_log'
        TO 'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\DATA\DB_Laboratorio_PointInTime_log.ldf',

    NORECOVERY,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 2. Aplicar LOG Backup 01
=========================================================
*/

RESTORE LOG DB_Laboratorio_PointInTime
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
*/

RESTORE LOG DB_Laboratorio_PointInTime
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_LOG_02.trn'
WITH
    NORECOVERY,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 4. Aplicar LOG Backup 03 até o ponto desejado
=========================================================

O STOPAT deve apontar para um horário anterior
ao incidente que se deseja desfazer.
*/

RESTORE LOG DB_Laboratorio_PointInTime
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_LOG_03.trn'
WITH
    STOPAT = '2026-09-08T23:57:51',
    RECOVERY,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 5. Validar recuperação
=========================================================
*/

SELECT *
FROM DB_Laboratorio_PointInTime.dbo.Clientes
WHERE Email = 'eduardo@email.com';
GO
