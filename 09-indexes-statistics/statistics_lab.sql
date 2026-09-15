/*
=========================================================
 SQL Server DBA Lab
 Módulo 09: Indexes & Statistics
 Script: Statistics Lab
=========================================================

Objetivo:
Demonstrar como as estatísticas auxiliam o Query Optimizer
na estimativa de cardinalidade e como estatísticas
desatualizadas podem gerar estimativas muito diferentes
da quantidade real de linhas.

Experimento realizado:

1. Estatística atualizada
   Estimated Rows = 10
   Actual Rows    = 10

2. Distribuição dos dados alterada
   AUTO_UPDATE_STATISTICS desativado

   Estimated Rows = 14
   Actual Rows    = 40.010

3. Estatística atualizada manualmente
   Estimated Rows = 40.010
   Actual Rows    = 40.010
=========================================================
*/

USE DB_Laboratorio;
GO


/*
---------------------------------------------------------
 1. Consultar estatísticas da tabela
---------------------------------------------------------
*/

SELECT
    s.name AS StatisticsName,
    s.auto_created,
    s.user_created,
    s.has_filter,
    s.stats_id
FROM sys.stats AS s
WHERE s.object_id = OBJECT_ID('dbo.PedidosPerformance')
ORDER BY s.stats_id;
GO


/*
---------------------------------------------------------
 2. Inspecionar estatística do índice
---------------------------------------------------------

DBCC SHOW_STATISTICS retorna informações como:

- STAT_HEADER
- DENSITY_VECTOR
- HISTOGRAM
*/

DBCC SHOW_STATISTICS
(
    'dbo.PedidosPerformance',
    'IX_PedidosPerformance_ClienteID'
);
GO


/*
---------------------------------------------------------
 3. Cardinalidade inicial
---------------------------------------------------------

Distribuição inicial:

100.000 linhas
10.000 ClienteIDs
aproximadamente 10 pedidos por ClienteID

Para ClienteID = 5000:

Estimated Rows = 10
Actual Rows    = 10

A estimativa de cardinalidade correspondia à quantidade
real de registros.
*/

SELECT
    PedidoID,
    ClienteID,
    DataPedido,
    StatusPedido,
    ValorTotal
FROM dbo.PedidosPerformance
WHERE ClienteID = 5000;
GO


/*
---------------------------------------------------------
 4. Desativar temporariamente atualização automática
---------------------------------------------------------

ATENÇÃO:

Esta alteração foi realizada apenas para produzir um
cenário controlado de laboratório.

Não representa uma recomendação para ambientes de produção.
*/

USE master;
GO

ALTER DATABASE DB_Laboratorio
SET AUTO_UPDATE_STATISTICS OFF;
GO


/*
---------------------------------------------------------
 5. Alterar drasticamente a distribuição
---------------------------------------------------------

Durante o laboratório foram realizadas duas inserções
de 20.000 registros para ClienteID = 5000.

Como esse ClienteID já possuía 10 registros:

10 + 20.000 + 20.000 = 40.010 registros

A segunda inserção ocorreu durante a repetição do
experimento e foi mantida propositalmente no cenário final.
*/

USE DB_Laboratorio;
GO

SET NOCOUNT ON;

WITH Numeros AS
(
    SELECT TOP (20000)
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
    5000,
    DATEADD(SECOND, -Numero, SYSDATETIME()),
    'Pago',
    CAST(100.00 AS DECIMAL(10,2))
FROM Numeros;
GO

/*
O bloco acima foi executado duas vezes durante o
experimento, totalizando 40.000 novos registros.
*/


/*
---------------------------------------------------------
 6. Confirmar cardinalidade real
---------------------------------------------------------
*/

SELECT
    COUNT(*) AS QuantidadeReal
FROM dbo.PedidosPerformance
WHERE ClienteID = 5000;
GO

/*
Resultado observado:

QuantidadeReal = 40.010
*/


/*
---------------------------------------------------------
 7. Consultar com estatística desatualizada
---------------------------------------------------------

Resultado observado no Actual Execution Plan:

Estimated Rows = 14
Actual Rows    = 40.010

A estimativa ficou muito distante da cardinalidade real.
*/

SELECT
    PedidoID,
    ClienteID,
    DataPedido,
    StatusPedido,
    ValorTotal
FROM dbo.PedidosPerformance
WHERE ClienteID = 5000;
GO


/*
---------------------------------------------------------
 8. Atualizar manualmente a estatística
---------------------------------------------------------

FULLSCAN foi utilizado para tornar o experimento
controlado, fazendo a estatística considerar todas as
linhas da tabela.

Isso não significa que FULLSCAN deva ser utilizado
indiscriminadamente em produção.
*/

UPDATE STATISTICS dbo.PedidosPerformance
    IX_PedidosPerformance_ClienteID
WITH FULLSCAN;
GO


/*
---------------------------------------------------------
 9. Inspecionar o novo histograma
---------------------------------------------------------

Após a atualização:

Rows         = 140.000
Rows Sampled = 140.000

O histograma passou a possuir um passo para ClienteID 5000:

RANGE_HI_KEY = 5000
EQ_ROWS      = 40010
*/

DBCC SHOW_STATISTICS
(
    'dbo.PedidosPerformance',
    'IX_PedidosPerformance_ClienteID'
);
GO


/*
---------------------------------------------------------
 10. Forçar nova compilação para validação
---------------------------------------------------------

OPTION (RECOMPILE) foi utilizado no experimento para
garantir que a consulta fosse compilada considerando
as estatísticas atualizadas.

Resultado:

Estimated Rows = 40.010
Actual Rows    = 40.010
*/

SELECT
    PedidoID,
    ClienteID,
    DataPedido,
    StatusPedido,
    ValorTotal
FROM dbo.PedidosPerformance
WHERE ClienteID = 5000
OPTION (RECOMPILE);
GO


/*
---------------------------------------------------------
 11. Restaurar configuração do banco
---------------------------------------------------------

AUTO_UPDATE_STATISTICS foi reativado ao final do
experimento.
*/

USE master;
GO

ALTER DATABASE DB_Laboratorio
SET AUTO_UPDATE_STATISTICS ON;
GO


/*
---------------------------------------------------------
 12. Validar configuração
---------------------------------------------------------
*/

SELECT
    name,
    is_auto_create_stats_on,
    is_auto_update_stats_on
FROM sys.databases
WHERE name = 'DB_Laboratorio';
GO


/*
---------------------------------------------------------
 Resultado final
---------------------------------------------------------

ESTADO INICIAL

Estimated Rows = 10
Actual Rows    = 10


DISTRIBUIÇÃO ALTERADA
ESTATÍSTICA DESATUALIZADA

Estimated Rows = 14
Actual Rows    = 40.010


APÓS UPDATE STATISTICS WITH FULLSCAN

Estimated Rows = 40.010
Actual Rows    = 40.010


Conclusão:

As estatísticas fornecem informações sobre a distribuição
dos dados que auxiliam o Query Optimizer na estimativa de
cardinalidade.

Quando a distribuição muda significativamente e as
estatísticas não representam mais os dados atuais, as
estimativas podem se afastar bastante da cardinalidade
real, potencialmente influenciando a escolha do plano de
execução.
---------------------------------------------------------
*/
