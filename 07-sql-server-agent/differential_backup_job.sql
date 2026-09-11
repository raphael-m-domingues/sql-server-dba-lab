/*
=========================================================
 SQL Server DBA Lab
 Módulo 07: SQL Server Agent
 Script: Differential Backup Job
=========================================================

Objetivo:
Documentar o comando T-SQL utilizado pelo SQL Server
Agent para executar backups diferenciais automatizados
do banco DB_Laboratorio.

Schedule utilizado no laboratório:
- Frequência: semanal
- Dias: segunda a sábado
- Horário: 02:00

O Differential Backup registra as extensões modificadas
desde a base diferencial correspondente.
=========================================================
*/

USE master;
GO

DECLARE @BackupPath NVARCHAR(500);
DECLARE @Timestamp VARCHAR(20);


/*
---------------------------------------------------------
 Gerar timestamp no formato YYYYMMDD_HHMMSS
---------------------------------------------------------
*/

SET @Timestamp =
    CONVERT(CHAR(8), GETDATE(), 112) + '_' +
    REPLACE(CONVERT(CHAR(8), GETDATE(), 108), ':', '');


/*
---------------------------------------------------------
 Construir dinamicamente o caminho do arquivo
---------------------------------------------------------
*/

SET @BackupPath =
    'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DIFF_'
    + @Timestamp + '.bak';


/*
---------------------------------------------------------
 Executar Differential Backup
---------------------------------------------------------
*/

BACKUP DATABASE DB_Laboratorio
TO DISK = @BackupPath
WITH
    DIFFERENTIAL,
    CHECKSUM,
    STATS = 10;
GO
