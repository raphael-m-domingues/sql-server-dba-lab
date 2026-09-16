/*
    SQL Server DBA Lab
    Module 10 - Monitoring & Performance

    File: current_activity.sql

    Objective:
    Monitor user sessions and currently executing requests.

    Important:
    sys.dm_exec_sessions represents sessions connected to SQL Server.
    sys.dm_exec_requests represents requests that are executing now.
*/

USE master;
GO


/* =========================================================
   1. Instance snapshot
   ========================================================= */

SELECT
    GETDATE() AS DataHora,
    @@SERVERNAME AS Servidor,
    DB_NAME() AS BancoAtual,
    (
        SELECT COUNT(*)
        FROM sys.dm_exec_sessions
        WHERE is_user_process = 1
    ) AS SessoesUsuario;
GO


/* =========================================================
   2. User sessions

   Metrics such as CPU and logical reads are accumulated
   during the lifetime of the session.

   A sleeping session is not necessarily a problem.
   ========================================================= */

SELECT
    s.session_id,
    s.login_name,
    s.status,
    s.cpu_time AS CPU_ms,
    s.memory_usage * 8 AS MemoryUsage_KB,
    s.reads,
    s.writes,
    s.logical_reads,
    s.open_transaction_count,
    s.last_request_start_time,
    s.last_request_end_time,
    DB_NAME(s.database_id) AS DatabaseName
FROM sys.dm_exec_sessions AS s
WHERE s.is_user_process = 1
ORDER BY s.cpu_time DESC;
GO


/* =========================================================
   3. Currently executing requests

   Unlike sys.dm_exec_sessions, this DMV shows requests
   that are executing at this moment.
   ========================================================= */

SELECT
    r.session_id,
    r.status,
    r.command,
    r.cpu_time AS CPU_ms,
    r.total_elapsed_time AS ElapsedTime_ms,
    r.logical_reads,
    r.reads,
    r.writes,
    r.wait_type,
    r.wait_time AS WaitTime_ms,
    r.blocking_session_id,
    DB_NAME(r.database_id) AS DatabaseName,
    t.text AS SQLText
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE r.session_id <> @@SPID
ORDER BY r.total_elapsed_time DESC;
GO
