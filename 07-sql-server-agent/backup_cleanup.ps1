# =========================================================
# SQL Server DBA Lab
# Módulo 07: SQL Server Agent
# Script: Backup Cleanup
# =========================================================
#
# Objetivo:
# Aplicar uma política simples de retenção aos arquivos
# de backup do banco DB_Laboratorio.
#
# Retenção utilizada no laboratório:
# - LOG  : 7 dias
# - DIFF : 14 dias
# - FULL : 28 dias
#
# O script é executado pelo SQL Server Agent.
# =========================================================


$ErrorActionPreference = "Stop"

$BackupPath = "E:\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\Backup"


# ---------------------------------------------------------
# Identificar arquivos expirados
# ---------------------------------------------------------

$ExpiredBackups = Get-ChildItem -Path $BackupPath -File |
Where-Object {

    (
        $_.Name -like "DB_Laboratorio_LOG_*.trn" -and
        $_.LastWriteTime -lt (Get-Date).AddDays(-7)
    ) -or

    (
        $_.Name -like "DB_Laboratorio_DIFF_*.bak" -and
        $_.LastWriteTime -lt (Get-Date).AddDays(-14)
    ) -or

    (
        $_.Name -like "DB_Laboratorio_FULL_*.bak" -and
        $_.LastWriteTime -lt (Get-Date).AddDays(-28)
    )
}


# ---------------------------------------------------------
# Excluir arquivos encontrados
# ---------------------------------------------------------

$RemovedCount = 0

foreach ($Backup in $ExpiredBackups)
{
    Write-Output ("Excluindo: " + $Backup.FullName)

    Remove-Item -LiteralPath $Backup.FullName -Force

    $RemovedCount = $RemovedCount + 1
}


# ---------------------------------------------------------
# Registrar resultado
# ---------------------------------------------------------

Write-Output ("Limpeza concluida. Arquivos removidos: " + $RemovedCount)
