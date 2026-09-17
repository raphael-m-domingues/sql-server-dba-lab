/*
    SQL Server DBA Lab
    Module 11 - Integrity & Maintenance

    File: index_maintenance.sql

    Objective:
    Analyze index fragmentation and compare the effects
    of REORGANIZE and REBUILD operations.

    Important:
    Fragmentation percentage alone should not determine
    whether index maintenance is required.

    Index size, workload, maintenance cost and expected
    benefit should also be considered.
*/

USE DB_Laboratorio;
GO


/* =========================================================
   1. Index fragmentation analysis

   sys.dm_db_index_physical_stats provides information
   about the physical organization of indexes.

   LIMITED mode provides a lightweight fragmentation
   analysis suitable for an initial investigation.
   ========================================================= */

SELECT
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc AS IndexType,
    ips.page_count AS PageCount,

    CAST(
        ips.avg_fragmentation_in_percent
        AS DECIMAL(10,2)
    ) AS FragmentationPercent

FROM sys.dm_db_index_physical_stats
(
    DB_ID(),
    NULL,
    NULL,
    NULL,
    'LIMITED'
) AS ips

INNER JOIN sys.indexes AS i
    ON ips.object_id = i.object_id
   AND ips.index_id = i.index_id

WHERE ips.index_id > 0
  AND ips.page_count > 0

ORDER BY ips.avg_fragmentation_in_percent DESC;
GO


/* =========================================================
   2. REORGANIZE experiment

   REORGANIZE incrementally reorganizes the leaf-level
   pages of the index.

   In this lab, the operation is executed for educational
   comparison and not because maintenance was required.
   ========================================================= */

ALTER INDEX IX_PedidosPerformance_ClienteID
ON dbo.PedidosPerformance
REORGANIZE;
GO


/* =========================================================
   3. Fragmentation after REORGANIZE
   ========================================================= */

SELECT
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.page_count AS PageCount,

    CAST(
        ips.avg_fragmentation_in_percent
        AS DECIMAL(10,2)
    ) AS FragmentationPercent

FROM sys.dm_db_index_physical_stats
(
    DB_ID(),
    OBJECT_ID('dbo.PedidosPerformance'),
    NULL,
    NULL,
    'LIMITED'
) AS ips

INNER JOIN sys.indexes AS i
    ON ips.object_id = i.object_id
   AND ips.index_id = i.index_id

WHERE i.name = 'IX_PedidosPerformance_ClienteID';
GO


/* =========================================================
   4. REBUILD experiment

   REBUILD reconstructs the index structure.

   It is generally a more resource-intensive operation
   than REORGANIZE.

   Rebuilding an index also updates the statistics
   associated with that index.
   ========================================================= */

ALTER INDEX IX_PedidosPerformance_ClienteID
ON dbo.PedidosPerformance
REBUILD;
GO


/* =========================================================
   5. Fragmentation after REBUILD

   A rebuilt index is not guaranteed to report exactly
   0.00% fragmentation.

   Small indexes can still show residual fragmentation.
   ========================================================= */

SELECT
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.page_count AS PageCount,

    CAST(
        ips.avg_fragmentation_in_percent
        AS DECIMAL(10,2)
    ) AS FragmentationPercent

FROM sys.dm_db_index_physical_stats
(
    DB_ID(),
    OBJECT_ID('dbo.PedidosPerformance'),
    NULL,
    NULL,
    'LIMITED'
) AS ips

INNER JOIN sys.indexes AS i
    ON ips.object_id = i.object_id
   AND ips.index_id = i.index_id

WHERE i.name = 'IX_PedidosPerformance_ClienteID';
GO
