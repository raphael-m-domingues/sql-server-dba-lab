/*
    SQL Server DBA Lab
    Module 10 - Monitoring & Performance

    File: wait_statistics.sql

    Objective:
    Analyze accumulated wait statistics in the SQL Server
    instance and identify waits that may deserve investigation.

    Important:
    sys.dm_os_wait_stats contains cumulative statistics
    since the SQL Server instance started or the statistics
    were manually cleared.

    A high wait value alone does not prove a performance problem.
*/

USE master;
GO


/* =========================================================
   1. SQL Server instance start time

   Provides context for accumulated wait statistics.
   ========================================================= */

SELECT
    sqlserver_start_time
FROM sys.dm_os_sys_info;
GO


/* =========================================================
   2. Top accumulated waits

   Common background and idle waits are excluded to make
   the result more useful for investigation.
   ========================================================= */

SELECT TOP (20)
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    max_wait_time_ms,
    signal_wait_time_ms,

    CAST(
        100.0 * wait_time_ms
        / NULLIF(SUM(wait_time_ms) OVER (), 0)
        AS DECIMAL(6,2)
    ) AS WaitPercentage

FROM sys.dm_os_wait_stats

WHERE wait_type NOT IN
(
    'BROKER_EVENTHANDLER',
    'BROKER_RECEIVE_WAITFOR',
    'BROKER_TASK_STOP',
    'BROKER_TO_FLUSH',
    'CHECKPOINT_QUEUE',
    'CHKPT',
    'CLR_AUTO_EVENT',
    'CLR_MANUAL_EVENT',
    'DBMIRROR_DBM_EVENT',
    'DBMIRROR_EVENTS_QUEUE',
    'DBMIRROR_WORKER_QUEUE',
    'DIRTY_PAGE_POLL',
    'DISPATCHER_QUEUE_SEMAPHORE',
    'EXECSYNC',
    'FSAGENT',
    'FT_IFTS_SCHEDULER_IDLE_WAIT',
    'HADR_CLUSAPI_CALL',
    'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
    'HADR_LOGCAPTURE_WAIT',
    'HADR_NOTIFICATION_DEQUEUE',
    'HADR_TIMER_TASK',
    'HADR_WORK_QUEUE',
    'LAZYWRITER_SLEEP',
    'LOGMGR_QUEUE',
    'ONDEMAND_TASK_QUEUE',
    'PARALLEL_REDO_DRAIN_WORKER',
    'PARALLEL_REDO_LOG_CACHE',
    'PARALLEL_REDO_TRAN_LIST',
    'PARALLEL_REDO_WORKER_SYNC',
    'PREEMPTIVE_OS_FLUSHFILEBUFFERS',
    'PREEMPTIVE_XE_GETTARGETSTATE',
    'PWAIT_ALL_COMPONENTS_INITIALIZED',
    'QDS_ASYNC_QUEUE',
    'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
    'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
    'REQUEST_FOR_DEADLOCK_SEARCH',
    'RESOURCE_QUEUE',
    'SERVER_IDLE_CHECK',
    'SLEEP_BPOOL_FLUSH',
    'SLEEP_DBSTARTUP',
    'SLEEP_DCOMSTARTUP',
    'SLEEP_MASTERDBREADY',
    'SLEEP_MASTERMDREADY',
    'SLEEP_MASTERUPGRADED',
    'SLEEP_MSDBSTARTUP',
    'SLEEP_SYSTEMTASK',
    'SLEEP_TASK',
    'SLEEP_TEMPDBSTARTUP',
    'SNI_HTTP_ACCEPT',
    'SP_SERVER_DIAGNOSTICS_SLEEP',
    'SQLTRACE_BUFFER_FLUSH',
    'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
    'WAITFOR',
    'XE_DISPATCHER_JOIN',
    'XE_DISPATCHER_WAIT',
    'XE_TIMER_EVENT'
)

ORDER BY wait_time_ms DESC;
GO


/* =========================================================
   3. Lock-related waits

   LCK_M_S indicates that a request waited to acquire
   a Shared (S) lock.

   During the blocking experiment, LCK_M_S was observed
   while the SELECT waited for the open transaction.
   ========================================================= */

SELECT
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    max_wait_time_ms,
    signal_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type LIKE 'LCK%'
  AND wait_time_ms > 0
ORDER BY wait_time_ms DESC;
GO
