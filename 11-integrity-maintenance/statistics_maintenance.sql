/*
    SQL Server DBA Lab
    Module 11 - Integrity & Maintenance

    File: statistics_maintenance.sql

    Objective:
    Inspect statistics metadata and perform a controlled
    statistics update.

    Important:
    Statistics help the Query Optimizer estimate
    cardinality and choose execution plans.

    Statistics maintenance should consider the workload,
    table size and modification activity.
*/

USE DB_Laboratorio;
GO


/* =========================================================
   1. Statistics status

   sys.dm_db_stats_properties provides information such as:

   - Number of rows represented by the statistics
   - Number of sampled rows
   - Modification counter
   - Last update time
   ========================================================= */

SELECT
    s.name AS StatisticName,
    s.auto_created,
    s.user_created,
    s.no_recompute,

    STATS_DATE(
        s.object_id,
        s.stats_id
    ) AS LastUpdated,

    sp.rows AS TableRows,
    sp.rows_sampled AS RowsSampled,
    sp.modification_counter AS ModificationCounter

FROM sys.stats AS s

CROSS APPLY sys.dm_db_stats_properties
(
    s.object_id,
    s.stats_id
) AS sp

WHERE s.object_id =
      OBJECT_ID('dbo.PedidosPerformance')

ORDER BY s.name;
GO


/* =========================================================
   2. Controlled statistics update

   During the lab, the following auto-created statistic
   represented 100,000 rows and had accumulated
   40,000 modifications.

   FULLSCAN reads all rows when rebuilding the statistic.

   This is useful for the experiment but should not be
   applied indiscriminately to every statistic in a
   production environment.
   ========================================================= */

UPDATE STATISTICS dbo.PedidosPerformance
    [_WA_Sys_00000002_6E01572D]
WITH FULLSCAN;
GO


/* =========================================================
   3. Validate statistics after UPDATE STATISTICS
   ========================================================= */

SELECT
    s.name AS StatisticName,

    STATS_DATE(
        s.object_id,
        s.stats_id
    ) AS LastUpdated,

    sp.rows AS TableRows,
    sp.rows_sampled AS RowsSampled,
    sp.modification_counter AS ModificationCounter

FROM sys.stats AS s

CROSS APPLY sys.dm_db_stats_properties
(
    s.object_id,
    s.stats_id
) AS sp

WHERE s.object_id =
      OBJECT_ID('dbo.PedidosPerformance')

ORDER BY s.name;
GO
