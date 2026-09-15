/*
=========================================================
 SQL Server DBA Lab
 Módulo 09: Indexes & Statistics
 Script: Performance Lab
=========================================================

Objetivo:
Criar um cenário controlado para análise de performance
utilizando uma tabela com volume suficiente para observar:

- Execution Plans;
- Clustered Index Scan;
- logical reads;
- impacto da ausência de um índice adequado.

Este script representa o estado inicial do experimento,
antes da criação do Nonclustered Index.
=========================================================
*/


/*
---------------------------------------------------------
 1. Criar tabela para o laboratório
---------------------------------------------------------
*/

USE DB_Laboratorio;
GO

CREATE TABLE dbo.PedidosPerformance
(
    PedidoID       INT IDENTITY(1,1) NOT NULL,
    ClienteID      INT NOT NULL,
    DataPedido     DATETIME2 NOT NULL,
    StatusPedido   VARCHAR(20) NOT NULL,
    ValorTotal     DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_PedidosPerformance
        PRIMARY KEY CLUSTERED (PedidoID)
);
GO


/*
---------------------------------------------------------
 2. Verificar índices existentes
---------------------------------------------------------

Neste momento existe somente o Clustered Index criado
pela Primary Key em PedidoID.
*/

SELECT
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_primary_key
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID('dbo.PedidosPerformance');
GO


/*
---------------------------------------------------------
 3. Gerar 100.000 pedidos
---------------------------------------------------------

São utilizados 10.000 ClienteIDs.

Cada ClienteID recebe aproximadamente 10 pedidos,
criando uma distribuição adequada para testar consultas
seletivas posteriormente.
*/

SET NOCOUNT ON;

WITH Numeros AS
(
    SELECT TOP (100000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Numero
    FROM sys.all_objects AS a
    CROSS JOIN sys.all_objects AS b
)
INSERT INTO dbo.PedidosPerformance
(
    ClienteID,
    DataPedido,
    StatusPedido,
    ValorTotal
)
SELECT
    ((Numero - 1) % 10000) + 1,
    DATEADD(MINUTE, -(Numero % 525600), SYSDATETIME()),
    CASE Numero % 4
        WHEN 0 THEN 'Pendente'
        WHEN 1 THEN 'Pago'
        WHEN 2 THEN 'Enviado'
        ELSE 'Cancelado'
    END,
    CAST(
        10 + (Numero % 49990) / 100.0
        AS DECIMAL(10,2)
    )
FROM Numeros;
GO


/*
---------------------------------------------------------
 4. Validar quantidade de registros
---------------------------------------------------------
*/

SELECT
    COUNT(*) AS TotalPedidos
FROM dbo.PedidosPerformance;
GO


/*
---------------------------------------------------------
 5. Validar distribuição por ClienteID
---------------------------------------------------------
*/

SELECT TOP (10)
    ClienteID,
    COUNT(*) AS QuantidadePedidos
FROM dbo.PedidosPerformance
GROUP BY ClienteID
ORDER BY ClienteID;
GO


/*
---------------------------------------------------------
 6. Baseline da consulta
---------------------------------------------------------

Consulta utilizada durante todo o experimento.

Neste momento não existe índice específico em ClienteID.

Resultado observado durante o laboratório:

Execution Plan:
    Clustered Index Scan

STATISTICS IO:
    Logical Reads = 561

A consulta retorna aproximadamente 10 registros entre
100.000 linhas.
*/

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    PedidoID,
    ClienteID,
    DataPedido,
    StatusPedido,
    ValorTotal
FROM dbo.PedidosPerformance
WHERE ClienteID = 5000;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


/*
---------------------------------------------------------
 Resultado observado
---------------------------------------------------------

Tabela:
    dbo.PedidosPerformance

Total de registros:
    100.000

Filtro:
    ClienteID = 5000

Registros retornados:
    10

Execution Plan:
    Clustered Index Scan

Logical Reads:
    561

Esse resultado será utilizado como baseline para comparar
o impacto dos índices criados nas próximas etapas.
---------------------------------------------------------
*/
