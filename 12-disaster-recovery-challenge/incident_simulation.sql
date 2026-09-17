/*
    SQL Server DBA Lab
    Module 12 - Disaster Recovery Challenge

    File: incident_simulation.sql

    Objective:
    Simulate an accidental data-loss incident and capture
    the transaction log required for Point-in-Time Recovery.

    WARNING:
    This script intentionally deletes data.

    Execute only in the laboratory database.
*/

USE DB_Laboratorio;
GO


/* =========================================================
   1. Register the moment immediately before the incident

   This timestamp helps identify the time window in which
   the destructive transaction occurred.
   ========================================================= */

SELECT
    SYSDATETIME() AS BeforeIncident;
GO


/* =========================================================
   2. Simulate the incident

   An accidental DELETE without a WHERE clause removes
   every row from dbo.Clientes.

   This represents the data-loss event that the DBA
   must recover from.
   ========================================================= */

DELETE FROM dbo.Clientes;
GO


/* =========================================================
   3. Record the impact of the incident
   ========================================================= */

SELECT
    @@ROWCOUNT AS DeletedRows;
GO

SELECT
    SYSDATETIME() AS AfterIncident;
GO

SELECT
    COUNT(*) AS RemainingClients
FROM dbo.Clientes;
GO


/* =========================================================
   4. Capture the transaction log containing the incident

   This backup contains activity that occurred after
   LOG_01, including:

   - Valid transaction #2
   - The destructive DELETE

   The backup is still required because Point-in-Time
   Recovery can stop before the destructive transaction.
   ========================================================= */

USE master;
GO

BACKUP LOG DB_Laboratorio
TO DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DR_LOG_02.trn'
WITH
    INIT,
    CHECKSUM,
    STATS = 10;
GO


/* =========================================================
   5. Validate LOG_02
   ========================================================= */

RESTORE VERIFYONLY
FROM DISK =
'E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup\DB_Laboratorio_DR_LOG_02.trn'
WITH CHECKSUM;
GO


/* =========================================================
   Recovery timeline

   FULL
     ↓
   Valid transaction #1
     ↓
   LOG_01
     ↓
   Valid transaction #2
     ↓
   SAFE POINT
     ↓
   DELETE FROM dbo.Clientes
     ↓
   LOG_02

   LOG_02 contains the incident, but it is still part
   of the required recovery chain.

   During restore, STOPAT will be used to stop before
   the destructive transaction.
   ========================================================= */
