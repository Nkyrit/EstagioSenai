$arquivo = "C:\Users\sherlock\Relatorios\listaparademi.csv"
$relatorio = "C:\Users\sherlock\Relatorios\foramdemi.txt"

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) { 
    Write-Host "Módulo Active Directory não encontrado. Saindo."
    exit 
}

$demitidos = Import-Csv -Path $arquivo -Delimiter ";"

if (Test-Path $relatorio) {
    Remove-Item $relatorio
}

$demitidos | ForEach-Object {
    $nomeUsuario = $_.Nome
    $grupoUsuario = $_.Grupo

    $user = Get-ADUser -Filter {SamAccountName -eq $nomeUsuario} -Properties MemberOf, Enabled
    if ($user) {
        if ($user.Enabled) {
            Disable-ADAccount -Identity $user

            $user.MemberOf | ForEach-Object { 
                Remove-ADGroupMember -Identity $_ -Members $user -Confirm:$false 
            }

            $logEntry = [PSCustomObject]@{
                Usuario = $nomeUsuario
                Status = "Desativado"
                Data = Get-Date
                Grupo = $grupoUsuario
            }

            $logEntry | Export-Csv -Path $relatorio -Append -NoTypeInformation

            Write-Host "Usuario $nomeUsuario foi desativado e removido dos grupos."
        }
        else {
            Write-Host "Usuario $nomeUsuario ja esta desativado."
        }
    }
    else {
        Write-Host "Usuario $nomeUsuario nao encontrado no Active Directory."
    }
}

Write-Host "Processo concluido. Relatorio salvo em $relatorio."
