/*
    SQL Server DBA Lab
    Module 11 - Integrity & Maintenance

    File: integrity_checks.sql

    Objective:
    Validate database and table consistency using
    SQL Server DBCC integrity-checking commands.

    Important:
    Integrity checks should be performed regularly.
    A successful execution represents the state observed
    when the command was executed.
*/

USE DB_Laboratorio;
GO


/* =========================================================
   1. Complete database integrity check

   DBCC CHECKDB performs consistency checks against
   the database and its internal structures.

   Without NO_INFOMSGS, SQL Server displays detailed
   informational output and the final integrity summary.
   ========================================================= */

DBCC CHECKDB ('DB_Laboratorio');
GO


/* =========================================================
   2. Clean integrity check output

   NO_INFOMSGS suppresses informational messages.

   If no errors are reported, SSMS normally displays only
   that the command completed successfully.
   ========================================================= */

DBCC CHECKDB ('DB_Laboratorio')
WITH NO_INFOMSGS;
GO


/* =========================================================
   3. Table-level integrity check

   CHECKTABLE performs consistency checks against a
   specific table and its associated structures.

   CHECKTABLE is useful for targeted investigation,
   but it does not replace a complete CHECKDB strategy.
   ========================================================= */

DBCC CHECKTABLE ('dbo.PedidosPerformance');
GO


/* =========================================================
   4. Post-maintenance validation

   Run this check after maintenance operations to verify
   that CHECKDB reports no integrity errors.

   NO_INFOMSGS keeps the output focused on problems,
   if any are detected.
   ========================================================= */

DBCC CHECKDB ('DB_Laboratorio')
WITH NO_INFOMSGS;
GO
