$DiasInatividade = 90
$DataLimite = (Get-Date).AddDays(-$DiasInatividade)

$CaminhoArquivoCSV = "C:\Users\sherlock\Relatorios\ContasInativas.csv"

$CaminhoRelatorio = "C:\Users\sherlock\Relatorios\ContasInativas_Resultado.csv"

If (!(Test-Path "C:\Users\sherlock\Relatorios")) {
    New-Item -ItemType Directory -Path "C:\Users\sherlock\Relatorios"
}

$UsuariosCSV = Import-Csv -Path $CaminhoArquivoCSV -Delimiter ";"

$ContasInativas = Get-ADUser -Filter {LastLogonDate -lt $DataLimite -and Enabled -eq $true} -Properties LastLogonDate
if ($ContasInativas) {
    $ContasInativas | Select-Object Name, SamAccountName, LastLogonDate | Export-Csv -Path $CaminhoRelatorio -NoTypeInformation
    Write-Host "Relatório de contas inativas gerado em $CaminhoRelatorio"

    foreach ($Conta in $ContasInativas) {
        # Desativa a conta
        Disable-ADAccount -Identity $Conta.SamAccountName
        Write-Host "Conta bloqueada: $($Conta.SamAccountName)"
    }

    Write-Host "`nProcesso concluido. Contas inativas foram bloqueadas."
} else {
    Write-Host "Nao existem contas inativas no momento."
}

$ContasDesabilitadas = Get-ADUser -Filter {Enabled -eq $false} -Properties SamAccountName, Name

if ($ContasDesabilitadas) {
    Write-Host "`nContas ja desabilitadas:"
    $ContasDesabilitadas | Select-Object Name, SamAccountName | Format-Table -AutoSize
} else {
    Write-Host "`nNenhuma conta desabilitada encontrada."
}

foreach ($UsuarioCSV in $UsuariosCSV) {
    $nomeUsuario = $UsuarioCSV.Nome
    $grupoUsuario = $UsuarioCSV.Grupo

    $user = Get-ADUser -Filter {SamAccountName -eq $nomeUsuario} -Properties SamAccountName, Enabled
    if ($user) {
        if ($user.Enabled) {
            Disable-ADAccount -Identity $user
            Write-Host "Conta $nomeUsuario desativada."

        } else {
            Write-Host "Conta $nomeUsuario ja esta desativada."
        }
    } else {
        Write-Host "Usuario $nomeUsuario nao encontrado no Active Directory."
    }
}

Write-Host "`nProcesso de desativacao de contas do arquivo CSV concluido."
