/*
=========================================================
 SQL Server DBA Lab
 Módulo 03: Transactions & Blocking
 Diagnóstico de Blocking
=========================================================

Objetivo:
Identificar sessões bloqueadas, sessões bloqueadoras
e transações abertas utilizando DMVs do SQL Server.
*/


-- Identificar requisições bloqueadas
SELECT
    session_id,
    status,
    blocking_session_id,
    wait_type,
    wait_time,
    wait_resource
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;
GO


-- Verificar sessões e transações abertas
SELECT
    s.session_id,
    s.status,
    s.login_name,
    s.host_name,
    r.status AS request_status,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    s.open_transaction_count
FROM sys.dm_exec_sessions AS s
LEFT JOIN sys.dm_exec_requests AS r
    ON s.session_id = r.session_id
WHERE
    s.is_user_process = 1;
GO


-- Identificar transações ativas
SELECT
    s.session_id,
    at.transaction_begin_time AS TransactionStart,
    DATEDIFF(
        SECOND,
        at.transaction_begin_time,
        GETDATE()
    ) AS SecondsOpen,
    at.transaction_type AS TransactionType,
    at.transaction_state AS TransactionState
FROM sys.dm_tran_session_transactions AS st
INNER JOIN sys.dm_tran_active_transactions AS at
    ON st.transaction_id = at.transaction_id
INNER JOIN sys.dm_exec_sessions AS s
    ON st.session_id = s.session_id;
GO


/*
Para investigar o último comando executado por uma sessão:

DBCC INPUTBUFFER(<session_id>);

Exemplo:

DBCC INPUTBUFFER(53);

O session_id varia entre execuções e ambientes.
*/
