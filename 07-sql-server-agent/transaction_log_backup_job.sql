/*
=========================================================
 SQL Server DBA Lab
 Módulo 07: SQL Server Agent
 Script: Transaction Log Backup Job
=========================================================

Objetivo:
Documentar o comando T-SQL utilizado pelo SQL Server
Agent para executar backups automatizados do Transaction
Log do banco DB_Laboratorio.

Schedule utilizado no laboratório:
- Frequência: diária
- Intervalo: a cada 30 minutos
- Período: 00:00 até 23:59

Cada execução gera um arquivo .trn independente,
identificado por data e hora.
=========================================================
*/

USE master;
GO

DECLARE @BackupPath NVARCHAR(500);
DECLARE @Timestamp VARCHAR(20);


/*
---------------------------------------------------------
 Gerar timestamp no formato YYYYMMDD_HHMMSS
 Exemplo: 20260910_215607
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
    'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_LOG_'
    + @Timestamp + '.trn';


/*
---------------------------------------------------------
 Executar Transaction Log Backup
---------------------------------------------------------
*/

BACKUP LOG DB_Laboratorio
TO DISK = @BackupPath
WITH
    CHECKSUM,
    STATS = 10;
GO
