/*
=========================================================
 SQL Server DBA Lab
 Módulo 04: Backup & Restore
 Etapa: FULL Backup
=========================================================

Objetivo:
Criar um backup completo do banco DB_Laboratorio
e verificar o arquivo de backup gerado.
*/

USE master;
GO

-- FULL Backup
BACKUP DATABASE DB_Laboratorio
TO DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_FULL.bak'
WITH
    INIT,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 Verificação do backup
=========================================================

RESTORE VERIFYONLY verifica se o conjunto de backup
pode ser lido e se está estruturalmente completo.

IMPORTANTE:
VERIFYONLY não substitui um teste real de restauração.
*/

RESTORE VERIFYONLY
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_FULL.bak'
WITH CHECKSUM;
GO
