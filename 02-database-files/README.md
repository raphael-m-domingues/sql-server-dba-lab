# 02 — Gerenciamento de Arquivos do Banco de Dados

## 🎯 Objetivo

Este módulo demonstra a criação de um banco de dados e a análise e configuração dos seus arquivos de dados e transaction log.

O banco utilizado nos testes foi o `DB_Laboratorio`.

## 📁 MDF e LDF

Ao criar o banco de dados, o SQL Server utiliza arquivos com funções diferentes.

### MDF — Arquivo de dados

O arquivo MDF é o arquivo de dados principal do banco.

Nele são armazenadas páginas que contêm estruturas como tabelas e índices.

### LDF — Transaction Log

O arquivo LDF contém o transaction log do banco de dados.

O transaction log registra as alterações realizadas no banco e possui papel fundamental na consistência e nos processos de recuperação.

Durante este laboratório, o transaction log também será utilizado posteriormente nos testes de backup e Point-in-Time Recovery.

## 📏 Dimensionamento dos arquivos

Após analisar os arquivos inicialmente criados pelo SQL Server, foram definidos os seguintes tamanhos para o ambiente de laboratório:

| Arquivo | Tipo | SIZE | FILEGROWTH |
|---|---|---:|---:|
| DB_Laboratorio | DATA | 256 MB | 64 MB |
| DB_Laboratorio_log | LOG | 128 MB | 64 MB |

Esses valores foram definidos especificamente para o ambiente de laboratório e não representam uma recomendação universal para ambientes de produção.

## 📈 Autogrowth

O parâmetro `FILEGROWTH` determina quanto um arquivo aumenta quando precisa de mais espaço.

Por exemplo, considerando:

`SIZE = 256 MB`

`FILEGROWTH = 64 MB`

Quando ocorrer um evento de autogrowth, o arquivo passará de 256 MB para 320 MB.

Caso seja necessário outro crescimento:

256 MB → 320 MB → 384 MB → 448 MB

Portanto, `FILEGROWTH` não representa o tamanho máximo do arquivo, mas o incremento realizado em cada evento de crescimento.

O autogrowth funciona como um mecanismo de segurança para disponibilizar espaço adicional, mas não substitui o planejamento e o monitoramento da capacidade de armazenamento.

## 🔎 Consultando os arquivos

A view `sys.master_files` foi utilizada para consultar informações como:

- nome lógico;
- tipo do arquivo;
- caminho físico;
- tamanho;
- configuração de crescimento.

Quando `is_percent_growth = 0`, o valor da coluna `growth` é armazenado em páginas de 8 KB.

Por isso, para apresentar o crescimento em MB, foi utilizada a conversão:

`growth * 8.0 / 1024`

## 🧪 Script

O script utilizado neste módulo está disponível em:

`database_files.sql`

## 📌 Aprendizados

Neste módulo foram praticados:

- criação de banco de dados;
- diferença entre arquivos MDF e LDF;
- dimensionamento de arquivos;
- configuração de `SIZE`;
- configuração de `FILEGROWTH`;
- funcionamento do autogrowth;
- consulta à `sys.master_files`;
- interpretação do crescimento armazenado em páginas de 8 KB.
