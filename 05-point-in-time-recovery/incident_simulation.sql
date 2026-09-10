/*
=========================================================
 SQL Server DBA Lab
 Módulo 05: Point-in-Time Recovery
 Etapa: Simulação de incidente
=========================================================

Objetivo:
Simular a exclusão acidental de um registro para
posteriormente recuperá-lo utilizando Point-in-Time
Recovery.
*/

USE DB_Laboratorio;
GO


/*
=========================================================
 1. Criar registro de teste
=========================================================
*/

INSERT INTO dbo.Clientes (Nome, Email)
VALUES ('Eduardo Santos', 'eduardo@email.com');
GO


-- Confirmar que o registro existe
SELECT *
FROM dbo.Clientes
WHERE Email = 'eduardo@email.com';
GO


/*
=========================================================
 2. Registrar um ponto seguro
=========================================================

O horário registrado deve ser anterior ao incidente.
*/

SELECT SYSDATETIME() AS PontoSeguro;
GO


/*
Aguardar alguns segundos antes de executar o DELETE
para existir uma separação clara entre o ponto seguro
e o incidente.
*/


/*
=========================================================
 3. Simular exclusão acidental
=========================================================
*/

DELETE FROM dbo.Clientes
WHERE Email = 'eduardo@email.com';
GO


-- Confirmar que o registro foi removido
SELECT *
FROM dbo.Clientes
WHERE Email = 'eduardo@email.com';
GO


-- Registrar horário após o incidente
SELECT SYSDATETIME() AS HorarioAposIncidente;
GO
