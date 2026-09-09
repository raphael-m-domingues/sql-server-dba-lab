/*
=========================================================
 SQL Server DBA Lab
 Módulo 02: Database Files
=========================================================

Objetivo:
Criar um banco de dados de laboratório e analisar/configurar
seus arquivos de dados e transaction log.
*/

-- Criação do banco de dados
CREATE DATABASE DB_Laboratorio;
GO


-- Consultar os arquivos do banco
SELECT
    name AS LogicalName,
    type_desc AS FileType,
    physical_name AS PhysicalPath,
    size * 8.0 / 1024 AS SizeMB,
    growth,
    is_percent_growth
FROM sys.master_files
WHERE database_id = DB_ID('DB_Laboratorio');
GO


-- Configurar o arquivo de dados (MDF)
ALTER DATABASE DB_Laboratorio
MODIFY FILE
(
    NAME = DB_Laboratorio,
    SIZE = 256MB,
    FILEGROWTH = 64MB
);
GO


-- Configurar o arquivo de transaction log (LDF)
ALTER DATABASE DB_Laboratorio
MODIFY FILE
(
    NAME = DB_Laboratorio_log,
    SIZE = 128MB,
    FILEGROWTH = 64MB
);
GO


-- Verificar a configuração após as alterações
SELECT
    name AS LogicalName,
    type_desc AS FileType,
    physical_name AS PhysicalPath,
    size * 8.0 / 1024 AS SizeMB,
    growth * 8.0 / 1024 AS GrowthMB,
    is_percent_growth
FROM sys.master_files
WHERE database_id = DB_ID('DB_Laboratorio');
GO
