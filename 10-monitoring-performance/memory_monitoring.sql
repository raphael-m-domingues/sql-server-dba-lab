/*
    SQL Server DBA Lab
    Module 10 - Monitoring & Performance

    File: memory_monitoring.sql

    Objective:
    Monitor SQL Server memory usage and identify indicators
    that may help investigate memory pressure.

    Important:
    Individual memory counters should not be interpreted
    in isolation. Performance analysis requires context,
    baselines and correlation between metrics.
*/

USE master;
GO


/* =========================================================
   1. SQL Server process memory

   Shows physical memory used by the SQL Server process
   and indicators of physical or virtual memory pressure.
   ========================================================= */

SELECT
    physical_memory_in_use_kb / 1024 AS SQLMemoryUsed_MB,
    large_page_allocations_kb / 1024 AS LargePages_MB,
    locked_page_allocations_kb / 1024 AS LockedPages_MB,
    memory_utilization_percentage AS MemoryUtilizationPercent,
    available_commit_limit_kb / 1024 AS AvailableCommitLimit_MB,
    process_physical_memory_low AS PhysicalMemoryLow,
    process_virtual_memory_low AS VirtualMemoryLow
FROM sys.dm_os_process_memory;
GO


/* =========================================================
   2. Total Server Memory vs Target Server Memory

   Total Server Memory:
   Memory currently acquired by SQL Server memory manager.

   Target Server Memory:
   Memory target calculated by SQL Server according to
   the current environment and workload.

   Total < Target does not automatically indicate
   memory pressure.
   ========================================================= */

SELECT
    MAX
    (
        CASE
            WHEN counter_name = 'Total Server Memory (KB)'
            THEN cntr_value
        END
    ) / 1024 AS TotalServerMemory_MB,

    MAX
    (
        CASE
            WHEN counter_name = 'Target Server Memory (KB)'
            THEN cntr_value
        END
    ) / 1024 AS TargetServerMemory_MB

FROM sys.dm_os_performance_counters
WHERE object_name LIKE '%Memory Manager%'
  AND counter_name IN
  (
      'Total Server Memory (KB)',
      'Target Server Memory (KB)'
  );
GO


/* =========================================================
   3. Page Life Expectancy

   PLE indicates how long data pages tend to remain
   in the buffer pool.

   A single PLE value should not be used as an automatic
   diagnosis of memory pressure. Trends and persistent
   drops are more useful than an isolated threshold.
   ========================================================= */

SELECT
    object_name,
    counter_name,
    instance_name,
    cntr_value AS PageLifeExpectancy_Seconds
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Page life expectancy';
GO


/* =========================================================
   4. Buffer pool usage by database

   SQL Server pages are 8 KB.

   CachedPages * 8 KB / 1024 = MB
   ========================================================= */

SELECT
    DB_NAME(database_id) AS DatabaseName,
    COUNT(*) AS CachedPages,

    CAST(
        COUNT(*) * 8.0 / 1024
        AS DECIMAL(18,2)
    ) AS BufferPool_MB

FROM sys.dm_os_buffer_descriptors
WHERE database_id <> 32767
GROUP BY database_id
ORDER BY CachedPages DESC;
GO


/* =========================================================
   5. Quick monitoring snapshot

   Provides a compact snapshot of selected indicators.

   This query is not a complete server health check.
   It represents only the state observed at the moment
   the query is executed.
   ========================================================= */

SELECT
    GETDATE() AS DataHora,
    @@SERVERNAME AS Servidor,

    (
        SELECT COUNT(*)
        FROM sys.dm_exec_sessions
        WHERE is_user_process = 1
    ) AS SessoesUsuario,

    (
        SELECT COUNT(*)
        FROM sys.dm_exec_requests
        WHERE blocking_session_id <> 0
    ) AS SessoesBloqueadas,

    (
        SELECT COUNT(*)
        FROM sys.dm_exec_sessions
        WHERE is_user_process = 1
          AND open_transaction_count > 0
    ) AS SessoesComTransacaoAberta,

    (
        SELECT physical_memory_in_use_kb / 1024
        FROM sys.dm_os_process_memory
    ) AS SQLMemoryUsed_MB,

    (
        SELECT process_physical_memory_low
        FROM sys.dm_os_process_memory
    ) AS PhysicalMemoryLow,

    (
        SELECT process_virtual_memory_low
        FROM sys.dm_os_process_memory
    ) AS VirtualMemoryLow;
GO
