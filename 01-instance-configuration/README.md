# 01 — Configuração da Instância

## 🎯 Objetivo

Este módulo documenta as principais configurações da instância SQL Server utilizadas no laboratório.

Antes de realizar alterações em um servidor SQL Server, é importante conhecer o ambiente e verificar parâmetros relacionados a memória, paralelismo e armazenamento.

## 🔎 Informações da instância

Foram consultadas informações como:

- versão do SQL Server;
- edição instalada;
- nível da versão;
- nome da instância.

Essas informações podem ser obtidas utilizando `SERVERPROPERTY`.

## 🧠 Gerenciamento de memória

O parâmetro `max server memory (MB)` controla o limite máximo de memória que pode ser utilizado pelo buffer pool e por componentes relacionados do SQL Server.

No ambiente de laboratório, o limite foi configurado em:

```text
8192 MB
