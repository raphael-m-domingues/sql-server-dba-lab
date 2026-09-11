/*
=========================================================
 SQL Server DBA Lab
 Módulo 07: SQL Server Agent
 Script: FULL Backup Job
=========================================================

Objetivo:
Documentar o comando T-SQL utilizado pelo SQL Server
Agent para executar backups FULL automatizados do banco
DB_Laboratorio.

Schedule utilizado no laboratório:
- Frequência: semanal
- Dia: domingo
- Horário: 02:00
=========================================================
*/

USE master;
GO

DECLARE @BackupPath NVARCHAR(500);
DECLARE @Timestamp VARCHAR(20);


/*
---------------------------------------------------------
 Gerar timestamp no formato YYYYMMDD_HHMMSS
 Exemplo: 20260910_220024
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
    'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_FULL_'
    + @Timestamp + '.bak';


/*
---------------------------------------------------------
 Executar FULL Backup
---------------------------------------------------------
*/

BACKUP DATABASE DB_Laboratorio
TO DISK = @BackupPath
WITH
    CHECKSUM,
    STATS = 10;
GO
