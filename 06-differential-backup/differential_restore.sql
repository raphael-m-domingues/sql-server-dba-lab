/*
=========================================================
 SQL Server DBA Lab
 Módulo 06: Differential Backup
 Etapa: Restore com FULL + DIFF 02
=========================================================

Objetivo:
Demonstrar que um Differential Backup pode ser
restaurado diretamente sobre sua base FULL, sem
necessidade de restaurar diferenciais anteriores.
*/

USE master;
GO


/*
=========================================================
 1. Restaurar o FULL Backup base
=========================================================
*/

RESTORE DATABASE DB_Laboratorio_DiffRestore
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DIFF_BASE_FULL.bak'
WITH
    MOVE 'DB_Laboratorio'
        TO 'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\DATA\DB_Laboratorio_DiffRestore.mdf',

    MOVE 'DB_Laboratorio_log'
        TO 'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\DATA\DB_Laboratorio_DiffRestore_log.ldf',

    NORECOVERY,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 2. Aplicar diretamente o DIFF 02
=========================================================

O DIFF 01 não é restaurado.

O Differential Backup 02 contém as extensões
modificadas desde a base FULL até o momento em que
o DIFF 02 foi criado.
*/

RESTORE DATABASE DB_Laboratorio_DiffRestore
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DIFF_02.bak'
WITH
    RECOVERY,
    CHECKSUM,
    STATS = 10;
GO


/*
=========================================================
 3. Validar os dados recuperados
=========================================================
*/

SELECT
    ProdutoID,
    Nome,
    Preco,
    DataCadastro
FROM DB_Laboratorio_DiffRestore.dbo.Produtos
ORDER BY ProdutoID;
GO
