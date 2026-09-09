/*
=========================================================
 SQL Server DBA Lab
 Módulo: Configuração da Instância
=========================================================

Objetivo:
Consultar configurações importantes da instância SQL Server
utilizadas durante o laboratório.

Observação:
Os valores apresentados devem ser avaliados de acordo com
o ambiente. Não devem ser tratados como recomendações
universais para ambientes de produção.
*/

-- Informações da instância
SELECT
    SERVERPROPERTY('ProductVersion') AS ProductVersion,
    SERVERPROPERTY('ProductLevel') AS ProductLevel,
    SERVERPROPERTY('Edition') AS Edition,
    SERVERPROPERTY('InstanceName') AS InstanceName;
GO


-- Configuração de memória
EXEC sp_configure 'max server memory (MB)';
GO


-- Configuração de paralelismo
EXEC sp_configure 'max degree of parallelism (MAXDOP)';
GO


-- Cost Threshold for Parallelism
EXEC sp_configure 'cost threshold for parallelism';
GO


-- Caminhos padrão da instância
SELECT
    SERVERPROPERTY('InstanceDefaultDataPath') AS DefaultDataPath,
    SERVERPROPERTY('InstanceDefaultLogPath') AS DefaultLogPath,
    SERVERPROPERTY('InstanceDefaultBackupPath') AS DefaultBackupPath;
GO
