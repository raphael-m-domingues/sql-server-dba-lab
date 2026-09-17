/*
    SQL Server DBA Lab
    Module 11 - Integrity & Maintenance

    File: maintenance_diagnostics.sql

    Objective:
    Identify indexes and statistics that may require
    further maintenance analysis.

    Important:
    These queries provide diagnostic indicators.
    They do not automatically determine that maintenance
    must be performed.
*/

USE DB_Laboratorio;
GO


/* =========================================================
   1. Index maintenance candidates

   Fragmentation is evaluated together with page count.

   The thresholds used here are educational criteria
   for this laboratory and should not be treated as
   universal production rules.
   ========================================================= */

SELECT
    OBJECT_SCHEMA_NAME(ips.object_id) AS SchemaName,
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc AS IndexType,
    ips.page_count AS PageCount,

    CAST(
        ips.avg_fragmentation_in_percent
        AS DECIMAL(10,2)
    ) AS FragmentationPercent,

    CASE
        WHEN ips.page_count < 1000
            THEN 'SMALL INDEX - EVALUATE'

        WHEN ips.avg_fragmentation_in_percent < 10
            THEN 'NO ACTION'

        WHEN ips.avg_fragmentation_in_percent < 30
            THEN 'EVALUATE REORGANIZE'

        ELSE 'EVALUATE REBUILD'
    END AS MaintenanceRecommendation

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

ORDER BY
    ips.page_count DESC,
    ips.avg_fragmentation_in_percent DESC;
GO


/* =========================================================
   2. Statistics maintenance indicators

   Shows:

   - Last statistics update
   - Number of represented rows
   - Sample size
   - Modification counter
   - Percentage of modifications relative to row count

   ModifiedPercent is an investigation indicator,
   not an automatic UPDATE STATISTICS threshold.
   ========================================================= */

SELECT
    OBJECT_SCHEMA_NAME(s.object_id) AS SchemaName,
    OBJECT_NAME(s.object_id) AS TableName,
    s.name AS StatisticName,

    STATS_DATE(
        s.object_id,
        s.stats_id
    ) AS LastUpdated,

    sp.rows AS TableRows,
    sp.rows_sampled AS RowsSampled,
    sp.modification_counter AS ModificationCounter,

    CAST(
        CASE
            WHEN sp.rows > 0
                THEN sp.modification_counter * 100.0
                     / sp.rows
            ELSE 0
        END
        AS DECIMAL(10,2)
    ) AS ModifiedPercent

FROM sys.stats AS s

CROSS APPLY sys.dm_db_stats_properties
(
    s.object_id,
    s.stats_id
) AS sp

WHERE OBJECTPROPERTY(
    s.object_id,
    'IsUserTable'
) = 1

ORDER BY
    ModifiedPercent DESC,
    sp.modification_counter DESC;
GO
