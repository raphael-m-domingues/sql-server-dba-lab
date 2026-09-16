/*
    SQL Server DBA Lab
    Module 10 - Monitoring & Performance

    File: query_performance.sql

    Objective:
    Identify resource-intensive queries using the plan cache
    and correlate cached statistics with execution metrics.

    Important:
    sys.dm_exec_query_stats only contains statistics for
    query plans currently available in the plan cache.
    It is not a permanent performance history.
*/

USE DB_Laboratorio;
GO


/* =========================================================
   1. Controlled workload

   Execute this query multiple times to generate measurable
   activity in the plan cache.

   In the lab, it was executed five times before analyzing
   sys.dm_exec_query_stats.
   ========================================================= */

SELECT
    StatusPedido,
    COUNT(*) AS Quantidade,
    SUM(ValorTotal) AS ValorTotal,
    AVG(ValorTotal) AS TicketMedio
FROM dbo.PedidosPerformance
WHERE StatusPedido = 'Pago'
GROUP BY StatusPedido;
GO


/* =========================================================
   2. Expensive queries by logical reads

   Metrics in sys.dm_exec_query_stats are accumulated
   while the associated plan remains in cache.

   Total metrics show accumulated resource consumption.
   Average metrics help evaluate the cost per execution.
   ========================================================= */

SELECT TOP (10)
    qs.execution_count,

    CAST(
        qs.total_worker_time / 1000.0
        AS DECIMAL(18,2)
    ) AS TotalCPU_ms,

    CAST(
        (qs.total_worker_time / NULLIF(qs.execution_count, 0))
        / 1000.0
        AS DECIMAL(18,2)
    ) AS AvgCPU_ms,

    qs.total_logical_reads AS TotalLogicalReads,

    qs.total_logical_reads
        / NULLIF(qs.execution_count, 0)
        AS AvgLogicalReads,

    CAST(
        qs.total_elapsed_time / 1000.0
        AS DECIMAL(18,2)
    ) AS TotalElapsed_ms,

    qs.last_execution_time,

    SUBSTRING
    (
        st.text,
        (qs.statement_start_offset / 2) + 1,
        (
            (
                CASE qs.statement_end_offset
                    WHEN -1 THEN DATALENGTH(st.text)
                    ELSE qs.statement_end_offset
                END
                - qs.statement_start_offset
            ) / 2
        ) + 1
    ) AS StatementText

FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY qs.total_logical_reads DESC;
GO


/* =========================================================
   3. STATISTICS IO and TIME

   Provides metrics for an individual execution and allows
   comparison with the averages observed in the plan cache.
   ========================================================= */

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    StatusPedido,
    COUNT(*) AS Quantidade,
    SUM(ValorTotal) AS ValorTotal,
    AVG(ValorTotal) AS TicketMedio
FROM dbo.PedidosPerformance
WHERE StatusPedido = 'Pago'
GROUP BY StatusPedido;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
