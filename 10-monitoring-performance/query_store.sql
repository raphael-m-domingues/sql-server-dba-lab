/*
    SQL Server DBA Lab
    Module 10 - Monitoring & Performance

    File: query_store.sql

    Objective:
    Analyze historical query performance using Query Store.

    Query Store persists query texts, execution plans and
    runtime statistics inside the database.

    Unlike sys.dm_exec_query_stats, its history does not
    depend exclusively on plans currently available in cache.
*/

USE DB_Laboratorio;
GO


/* =========================================================
   1. Query Store configuration

   Confirms whether Query Store is enabled and its
   current operating state.
   ========================================================= */

SELECT
    actual_state_desc,
    desired_state_desc,
    readonly_reason,
    query_capture_mode_desc
FROM sys.database_query_store_options;
GO


/* =========================================================
   2. Queries and plans stored in Query Store

   A query may have more than one plan_id over time.
   ========================================================= */

SELECT TOP (20)
    q.query_id,
    p.plan_id,
    qt.query_sql_text,
    q.count_compiles,
    q.last_execution_time
FROM sys.query_store_query AS q
INNER JOIN sys.query_store_query_text AS qt
    ON q.query_text_id = qt.query_text_id
INNER JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
ORDER BY q.last_execution_time DESC;
GO


/* =========================================================
   3. Historical runtime statistics

   Runtime statistics are aggregated using execution count
   so that intervals with different numbers of executions
   are weighted correctly.

   Results are ordered by average logical reads.
   ========================================================= */

SELECT TOP (20)
    q.query_id,
    p.plan_id,

    SUM(rs.count_executions) AS ExecutionCount,

    CAST(
        SUM(rs.avg_cpu_time * rs.count_executions)
        / NULLIF(SUM(rs.count_executions), 0)
        / 1000.0
        AS DECIMAL(18,2)
    ) AS AvgCPU_ms,

    CAST(
        SUM(rs.avg_duration * rs.count_executions)
        / NULLIF(SUM(rs.count_executions), 0)
        / 1000.0
        AS DECIMAL(18,2)
    ) AS AvgDuration_ms,

    CAST(
        SUM(rs.avg_logical_io_reads * rs.count_executions)
        / NULLIF(SUM(rs.count_executions), 0)
        AS DECIMAL(18,2)
    ) AS AvgLogicalReads,

    MAX(rs.last_execution_time) AS LastExecutionTime,

    LEFT(qt.query_sql_text, 200) AS QueryText

FROM sys.query_store_query AS q
INNER JOIN sys.query_store_query_text AS qt
    ON q.query_text_id = qt.query_text_id
INNER JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
INNER JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id

GROUP BY
    q.query_id,
    p.plan_id,
    qt.query_sql_text

ORDER BY AvgLogicalReads DESC;
GO


/* =========================================================
   4. Runtime statistics by interval

   Query Store divides runtime statistics into time
   intervals, allowing performance to be analyzed
   historically.

   Differences between intervals do not automatically
   prove a performance regression.
   ========================================================= */

SELECT TOP (30)
    q.query_id,
    p.plan_id,

    rsi.start_time,
    rsi.end_time,

    rs.count_executions,

    CAST(
        rs.avg_duration / 1000.0
        AS DECIMAL(18,2)
    ) AS AvgDuration_ms,

    CAST(
        rs.avg_cpu_time / 1000.0
        AS DECIMAL(18,2)
    ) AS AvgCPU_ms,

    CAST(
        rs.avg_logical_io_reads
        AS DECIMAL(18,2)
    ) AS AvgLogicalReads,

    LEFT(qt.query_sql_text, 150) AS QueryText

FROM sys.query_store_query AS q
INNER JOIN sys.query_store_query_text AS qt
    ON q.query_text_id = qt.query_text_id
INNER JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
INNER JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id
INNER JOIN sys.query_store_runtime_stats_interval AS rsi
    ON rs.runtime_stats_interval_id =
       rsi.runtime_stats_interval_id

ORDER BY
    rsi.start_time DESC,
    AvgLogicalReads DESC;
GO
