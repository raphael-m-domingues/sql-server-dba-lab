/*
=========================================================
 SQL Server DBA Lab
 Módulo 03: Transactions & Blocking
 Cenário: Simulação de Blocking
=========================================================

Objetivo:
Simular uma transação aberta que mantém locks sobre um
registro e provoca blocking em uma segunda sessão.

IMPORTANTE:
Este laboratório deve ser executado utilizando duas
janelas de consulta separadas no SSMS.
*/

USE DB_Laboratorio;
GO


/*
=========================================================
 SESSÃO 1 — Executar em uma janela do SSMS
=========================================================
*/

BEGIN TRAN;

UPDATE dbo.Clientes
SET Nome = 'Ana ALTERADA'
WHERE ClienteID = 1;

-- Não executar COMMIT ou ROLLBACK ainda.
-- A transação deve permanecer aberta para gerar o blocking.


/*
=========================================================
 SESSÃO 2 — Executar em outra janela do SSMS
=========================================================
*/

SELECT *
FROM dbo.Clientes
WHERE ClienteID = 1;

-- Esta consulta poderá permanecer aguardando enquanto
-- a transação da Sessão 1 estiver aberta.


/*
=========================================================
 FINALIZAÇÃO — Executar novamente na SESSÃO 1
=========================================================
*/

ROLLBACK;
GO
