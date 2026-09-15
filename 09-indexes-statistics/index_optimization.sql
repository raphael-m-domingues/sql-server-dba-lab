/*
=========================================================
 SQL Server DBA Lab
 Módulo 09: Indexes & Statistics
 Script: Index Optimization
=========================================================

Objetivo:
Demonstrar o impacto de diferentes estratégias de índice
sobre uma mesma consulta.

Cenários analisados:

1. Sem índice adequado
   Clustered Index Scan
   561 logical reads

2. Nonclustered Index simples
   Index Seek + Key Lookup
   22 logical reads

3. Covering Nonclustered Index
   Index Seek
   3 logical reads
=========================================================
*/

USE DB_Laboratorio;
GO


/*
---------------------------------------------------------
 1. Consulta utilizada como baseline
---------------------------------------------------------

Antes da criação de um índice em ClienteID:

Execution Plan:
    Clustered Index Scan

Logical Reads:
    561
*/

SET STATISTICS IO ON;
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
GO


/*
---------------------------------------------------------
 2. Criar Nonclustered Index simples
---------------------------------------------------------

ClienteID passa a ser a chave de busca do índice.
*/

CREATE NONCLUSTERED INDEX IX_PedidosPerformance_ClienteID
ON dbo.PedidosPerformance (ClienteID);
GO


/*
---------------------------------------------------------
 3. Executar novamente a mesma consulta
---------------------------------------------------------

Resultado observado:

Execution Plan:
    Nonclustered Index Seek
        +
    Key Lookup (Clustered)

Logical Reads:
    22

O índice permite localizar ClienteID rapidamente.

Porém, a consulta também precisa retornar:

- DataPedido
- StatusPedido
- ValorTotal

Como essas colunas não estão disponíveis no índice simples,
o SQL Server utiliza Key Lookup no Clustered Index para
obter os dados restantes.
*/

SET STATISTICS IO ON;
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
GO


/*
---------------------------------------------------------
 4. Substituir por um Covering Index
---------------------------------------------------------

O primeiro índice é removido e recriado incluindo as
colunas necessárias para atender completamente a consulta.
*/

DROP INDEX IX_PedidosPerformance_ClienteID
ON dbo.PedidosPerformance;
GO

CREATE NONCLUSTERED INDEX IX_PedidosPerformance_ClienteID
ON dbo.PedidosPerformance (ClienteID)
INCLUDE
(
    DataPedido,
    StatusPedido,
    ValorTotal
);
GO


/*
---------------------------------------------------------
 5. Executar novamente a mesma consulta
---------------------------------------------------------

Resultado observado:

Execution Plan:
    Nonclustered Index Seek

Key Lookup:
    Eliminado

Logical Reads:
    3
*/

SET STATISTICS IO ON;
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
GO


/*
---------------------------------------------------------
 6. Comparação final
---------------------------------------------------------

CENÁRIO                         PLANO                    READS

Sem índice adequado             Clustered Index Scan      561

Nonclustered simples            Index Seek
                                + Key Lookup                22

Covering Nonclustered Index     Index Seek                   3


Redução aproximada:

561 -> 22
    ~96,1%

561 -> 3
    ~99,5%


Importante:

Index Seek não significa automaticamente um plano bom,
assim como Index Scan não significa automaticamente um
plano ruim.

A eficiência depende de fatores como:

- seletividade;
- quantidade de registros;
- distribuição dos dados;
- estatísticas;
- custo estimado;
- colunas necessárias pela consulta.

Também existe um custo associado aos índices:

- armazenamento;
- manutenção em INSERT;
- manutenção em UPDATE;
- manutenção em DELETE.

Portanto, índices devem ser criados de acordo com o
workload e não simplesmente adicionados indiscriminadamente.
---------------------------------------------------------
*/
