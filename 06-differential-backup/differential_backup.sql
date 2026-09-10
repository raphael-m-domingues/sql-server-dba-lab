/*
=========================================================
 SQL Server DBA Lab
 Módulo 06: Differential Backup
 Etapa: Criação da base FULL e backups diferenciais
=========================================================

Objetivo:
Demonstrar como um Differential Backup registra as
extensões modificadas desde o FULL Backup utilizado
como base diferencial.
*/

USE master;
GO


/*
=========================================================
 1. Criar FULL Backup base
=========================================================
*/

BACKUP DATABASE DB_Laboratorio
TO DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DIFF_BASE_FULL.bak'
WITH
    INIT,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 2. Criar alterações após o FULL
=========================================================
*/

USE DB_Laboratorio;
GO

CREATE TABLE dbo.Produtos
(
    ProdutoID INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Preco DECIMAL(10,2) NOT NULL,
    DataCadastro DATETIME2 NOT NULL
        DEFAULT SYSDATETIME()
);
GO

INSERT INTO dbo.Produtos (Nome, Preco)
VALUES
    ('Teclado', 150.00),
    ('Mouse', 80.00),
    ('Headset', 220.00);
GO


/*
=========================================================
 3. Criar Differential Backup 01
=========================================================
*/

USE master;
GO

BACKUP DATABASE DB_Laboratorio
TO DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DIFF_01.bak'
WITH
    DIFFERENTIAL,
    INIT,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 4. Criar novas alterações
=========================================================
*/

USE DB_Laboratorio;
GO

INSERT INTO dbo.Produtos (Nome, Preco)
VALUES
    ('Monitor', 1200.00),
    ('Webcam', 350.00);
GO


/*
=========================================================
 5. Criar Differential Backup 02
=========================================================
*/

USE master;
GO

BACKUP DATABASE DB_Laboratorio
TO DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DIFF_02.bak'
WITH
    DIFFERENTIAL,
    INIT,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 6. Consultar histórico
=========================================================
*/

SELECT
    database_name,
    CASE type
        WHEN 'D' THEN 'FULL'
        WHEN 'I' THEN 'DIFFERENTIAL'
    END AS BackupType,
    backup_start_date,
    backup_finish_date,
    CAST(backup_size / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS BackupSizeMB
FROM msdb.dbo.backupset
WHERE database_name = 'DB_Laboratorio'
  AND type IN ('D', 'I')
ORDER BY backup_finish_date DESC;
GO
