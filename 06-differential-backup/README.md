# 06 — Differential Backup

## 🎯 Objetivo

Este módulo demonstra o funcionamento de **Differential Backups** no SQL Server.

O objetivo do laboratório foi criar uma base FULL, realizar alterações no banco, gerar dois backups diferenciais e comprovar que o segundo diferencial pode ser restaurado diretamente sobre sua base FULL, sem a necessidade de restaurar o primeiro diferencial.

---

## 🧠 Conceito

Um Differential Backup contém as extensões de dados modificadas desde o FULL Backup que serve como sua base diferencial.

Durante o laboratório foi utilizada a seguinte sequência:

```text
FULL
  │
  ├── alterações A
  │
DIFF 01
  │
  ├── alterações B
  │
DIFF 02
```

O `DIFF 02` inclui as extensões modificadas desde a base FULL até o momento em que ele foi criado.

Por isso, para recuperar o estado correspondente ao `DIFF 02`, não foi necessário restaurar o `DIFF 01`.

---

## 💾 Criando a base FULL

Foi criado um novo FULL Backup especificamente para este laboratório:

```text
DB_Laboratorio_DIFF_BASE_FULL.bak
```

Essa separação permitiu preservar os backups utilizados nos módulos anteriores.

---

## 🧪 Primeiras alterações

Após a criação do FULL, foi criada a tabela `dbo.Produtos` e inseridos três registros:

```text
Teclado
Mouse
Headset
```

Em seguida foi criado:

```text
DB_Laboratorio_DIFF_01.bak
```

---

## 🔄 Novas alterações

Após o primeiro diferencial, mais dois produtos foram inseridos:

```text
Monitor
Webcam
```

Foi então criado:

```text
DB_Laboratorio_DIFF_02.bak
```

A sequência do experimento ficou:

```text
FULL
 │
 ├── Teclado
 ├── Mouse
 ├── Headset
 │
 ▼
DIFF 01
 │
 ├── Monitor
 └── Webcam
 │
 ▼
DIFF 02
```

---

## 📊 Histórico observado

Durante o laboratório, o histórico registrado no `msdb` mostrou:

| Tipo | Tamanho observado |
|---|---:|
| FULL | 6.09 MB |
| DIFF 01 | 3.09 MB |
| DIFF 02 | 4.09 MB |

O aumento observado entre os diferenciais está relacionado às extensões modificadas desde a base FULL.

> O tamanho de um Differential Backup não representa simplesmente a quantidade de linhas alteradas. O SQL Server trabalha com extensões de dados modificadas.

---

## ♻️ Teste de restauração

Para comprovar o comportamento cumulativo do Differential Backup, foi criado:

```text
DB_Laboratorio_DiffRestore
```

A restauração utilizou somente:

```text
FULL BASE
    │
    │ NORECOVERY
    ▼
DIFF 02
    │
    │ RECOVERY
    ▼
DB_Laboratorio_DiffRestore
```

O `DIFF 01` propositalmente **não foi restaurado**.

---

## 🔎 Validação

Após a restauração, a tabela `dbo.Produtos` foi consultada no banco recuperado.

O resultado esperado era encontrar:

```text
Teclado
Mouse
Headset
Monitor
Webcam
```

Os cinco registros estavam presentes.

Isso demonstrou que o `DIFF 02` continha as extensões modificadas desde sua base FULL, incluindo alterações realizadas antes e depois da criação do `DIFF 01`.

---

## 🆚 Differential x Transaction Log

Os dois tipos de backup possuem comportamentos diferentes.

### Transaction Log

Uma cadeia de logs deve preservar sua sequência:

```text
FULL
 ↓
LOG 01
 ↓
LOG 02
 ↓
LOG 03
```

Para alcançar determinado ponto por essa cadeia, os backups de log necessários precisam ser aplicados na ordem correta.

### Differential

Os diferenciais são cumulativos em relação à sua base:

```text
        ┌── DIFF 01
FULL ───┤
        └── DIFF 02
```

Para restaurar o estado representado pelo `DIFF 02`:

```text
FULL + DIFF 02
```

Não é necessário restaurar o `DIFF 01`.

---

## 🧪 Scripts

- `differential_backup.sql` — criação da base FULL, alterações controladas e backups diferenciais.
- `differential_restore.sql` — restauração utilizando diretamente FULL + DIFF 02.

---

## 📌 Aprendizados

Neste módulo foram praticados:

- FULL Backup como base diferencial;
- Differential Backup;
- criação de alterações controladas entre backups;
- histórico de backups no `msdb`;
- comportamento cumulativo dos diferenciais;
- restauração com `NORECOVERY`;
- finalização com `RECOVERY`;
- restauração utilizando FULL + último Differential;
- diferenças entre Differential Backup e Transaction Log Backup.
