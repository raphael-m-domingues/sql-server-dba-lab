/*
=========================================================
 SQL Server DBA Lab
 Módulo 09: Indexes & Statistics
 Script: Index Diagnostics
=========================================================

Objetivo:
Consultar informações operacionais dos índices utilizados
no laboratório, analisando:

- tipo do índice;
- quantidade de registros;
- espaço reservado;
- seeks;
- scans;
- lookups;
- operações de manutenção.

Essas informações ajudam o DBA a avaliar o benefício e
o custo de manter índices em uma tabela.
=========================================================
*/

USE DB_Laboratorio;
GO


/*
---------------------------------------------------------
 1. Índices existentes na tabela
---------------------------------------------------------
*/

SELECT
    i.index_id,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_primary_key,
    i.is_unique
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID('dbo.PedidosPerformance')
ORDER BY i.index_id;
GO


/*
---------------------------------------------------------
 2. Espaço reservado pelos índices
---------------------------------------------------------

reserved_page_count representa páginas reservadas.

Cada página do SQL Server possui 8 KB.

Conversão utilizada:

páginas * 8 KB / 1024 = MB
*/

SELECT
    i.name AS IndexName,
    i.type_desc AS IndexType,
    SUM(ps.row_count) AS [RowCount],
    CAST(
        SUM(ps.reserved_page_count) * 8.0 / 1024
        AS DECIMAL(10,2)
    ) AS ReservedMB
FROM sys.dm_db_partition_stats AS ps
INNER JOIN sys.indexes AS i
    ON ps.object_id = i.object_id
    AND ps.index_id = i.index_id
WHERE ps.object_id = OBJECT_ID('dbo.PedidosPerformance')
GROUP BY
    i.name,
    i.type_desc,
    i.index_id
ORDER BY
    i.index_id;
GO


/*
Resultado observado durante o laboratório:

PK_PedidosPerformance
    Tipo: CLUSTERED
    Linhas: 140.000
    Espaço reservado: 6,13 MB

IX_PedidosPerformance_ClienteID
    Tipo: NONCLUSTERED
    Linhas: 140.000
    Espaço reservado: 5,91 MB

O Covering Nonclustered Index ocupou espaço próximo ao
Clustered Index, demonstrando que índices possuem custo
de armazenamento.
*/


/*
---------------------------------------------------------
 3. Estatísticas de utilização dos índices
---------------------------------------------------------
*/

SELECT
    i.name AS IndexName,
    COALESCE(us.user_seeks, 0) AS UserSeeks,
    COALESCE(us.user_scans, 0) AS UserScans,
    COALESCE(us.user_lookups, 0) AS UserLookups,
    COALESCE(us.user_updates, 0) AS UserUpdates
FROM sys.indexes AS i
LEFT JOIN sys.dm_db_index_usage_stats AS us
    ON us.database_id = DB_ID()
    AND us.object_id = i.object_id
    AND us.index_id = i.index_id
WHERE i.object_id = OBJECT_ID('dbo.PedidosPerformance')
ORDER BY i.index_id;
GO


/*
Resultado observado:

PK_PedidosPerformance
    UserSeeks   = 0
    UserScans   = 0
    UserLookups = 0
    UserUpdates = 2

IX_PedidosPerformance_ClienteID
    UserSeeks   = 8
    UserScans   = 0
    UserLookups = 0
    UserUpdates = 2


IMPORTANTE:

sys.dm_db_index_usage_stats utiliza contadores
operacionais.

Esses valores não representam um histórico permanente
de utilização do índice e podem ser reinicializados,
por exemplo, após eventos relacionados ao ciclo de vida
da instância/banco.

Portanto, um índice não deve ser removido apenas porque
apresenta poucos seeks ou scans em uma observação isolada.
*/


/*
---------------------------------------------------------
 4. Interpretação das métricas
---------------------------------------------------------

user_seeks
    Operações que utilizaram o índice para buscas
    direcionadas.

user_scans
    Operações que percorreram o índice.

user_lookups
    Operações de lookup realizadas em um Clustered Index
    ou heap RID lookup, conforme a estrutura envolvida.

user_updates
    Operações que provocaram manutenção do índice.

IMPORTANTE:

user_updates não representa simplesmente a quantidade
de linhas modificadas.
*/


/*
---------------------------------------------------------
 Conclusão
---------------------------------------------------------

Índices podem reduzir significativamente o custo de
consultas de leitura.

Neste laboratório:

561 logical reads
        ↓
22 logical reads
        ↓
3 logical reads

Porém, o índice otimizado também apresentou custo de
armazenamento:

Clustered Index:
    6,13 MB

Covering Nonclustered Index:
    5,91 MB

Além disso, índices precisam ser mantidos quando os dados
são modificados.

A decisão de criar, manter ou remover um índice deve
considerar o workload real, incluindo:

- frequência das consultas;
- seletividade;
- volume de leitura;
- volume de escrita;
- armazenamento;
- custo de manutenção;
- planos de execução;
- período representado pelas métricas coletadas.

Um índice pouco utilizado pode ser candidato a análise,
mas não deve ser removido automaticamente apenas com base
em uma leitura isolada das DMVs.
---------------------------------------------------------
*/
