/*
    SQL Server DBA Lab
    Module 10 - Monitoring & Performance

    File: blocking_monitoring.sql

    Objective:
    Detect blocking sessions and identify transactions
    that remain open even when the blocking session is sleeping.

    Run the blocking simulation in separate SSMS windows.
*/

USE DB_Laboratorio;
GO


/* =========================================================
   1. Blocking simulation - Session 1

   Execute in the first SSMS window.
   Keep the transaction open.
   ========================================================= */

BEGIN TRAN;

UPDATE dbo.Clientes
SET Nome = 'Ana MONITORAMENTO'
WHERE ClienteID = 1;

-- Do not COMMIT or ROLLBACK yet.


/* =========================================================
   2. Blocked request - Session 2

   Execute in a second SSMS window.

   Under READ COMMITTED, this SELECT waits for the
   transaction from Session 1 to release its lock.
   ========================================================= */

SELECT *
FROM dbo.Clientes
WHERE ClienteID = 1;


/* =========================================================
   3. Detect blocking

   Execute in a third SSMS window.
   ========================================================= */

SELECT
    r.session_id AS BlockedSession,
    r.blocking_session_id AS BlockingSession,
    r.status,
    r.command,
    r.wait_type,
    r.wait_time,
    r.total_elapsed_time,
    DB_NAME(r.database_id) AS DatabaseName,
    s.login_name,
    t.text AS BlockedSQL
FROM sys.dm_exec_requests AS r
INNER JOIN sys.dm_exec_sessions AS s
    ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE r.blocking_session_id <> 0
ORDER BY r.wait_time DESC;


/* =========================================================
   4. Detect an open transaction in the blocking session

   Replace <BLOCKING_SESSION_ID> with the session_id
   identified by the previous query.
   ========================================================= */

DECLARE @BlockingSessionID INT = <BLOCKING_SESSION_ID>;

SELECT
    s.session_id,
    s.login_name,
    s.status AS SessionStatus,
    s.open_transaction_count,
    at.transaction_begin_time,
    at.transaction_type,
    at.transaction_state,
    DB_NAME(dt.database_id) AS DatabaseName,
    dt.database_transaction_begin_time,
    dt.database_transaction_log_record_count,
    dt.database_transaction_log_bytes_used
FROM sys.dm_exec_sessions AS s
INNER JOIN sys.dm_tran_session_transactions AS st
    ON s.session_id = st.session_id
INNER JOIN sys.dm_tran_active_transactions AS at
    ON st.transaction_id = at.transaction_id
INNER JOIN sys.dm_tran_database_transactions AS dt
    ON st.transaction_id = dt.transaction_id
WHERE s.session_id = @BlockingSessionID;


/* =========================================================
   5. Consolidated blocking diagnostics

   Shows the blocked request and information about
   the blocking session in the same result.
   ========================================================= */

SELECT
    blocked.session_id AS BlockedSession,
    blocker.session_id AS BlockingSession,
    blocker.status AS BlockingSessionStatus,
    blocker.open_transaction_count AS BlockingOpenTransactions,
    blocked_req.status AS BlockedStatus,
    blocked_req.command AS BlockedCommand,
    blocked_req.wait_type AS WaitType,
    blocked_req.wait_time AS WaitTimeMs,
    DB_NAME(blocked_req.database_id) AS DatabaseName,
    blocked_sql.text AS BlockedSQL,
    blocker_buffer.event_info AS BlockingLastCommand
FROM sys.dm_exec_requests AS blocked_req
INNER JOIN sys.dm_exec_sessions AS blocked
    ON blocked_req.session_id = blocked.session_id
INNER JOIN sys.dm_exec_sessions AS blocker
    ON blocked_req.blocking_session_id = blocker.session_id
CROSS APPLY sys.dm_exec_sql_text(blocked_req.sql_handle) AS blocked_sql
OUTER APPLY sys.dm_exec_input_buffer(
    blocker.session_id,
    NULL
) AS blocker_buffer
WHERE blocked_req.blocking_session_id <> 0
ORDER BY blocked_req.wait_time DESC;


/* =========================================================
   6. Cleanup

   Execute in Session 1 after finishing the experiment.

   ROLLBACK releases the locks and restores the original
   value used before the monitoring test.
   ========================================================= */

ROLLBACK;
GO
