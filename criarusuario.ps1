$arquivoUsuarios = "C:\Users\Sherlock\Relatorios\listausuarios.csv"
$SPadrao = "Sherlock123!"
$dominio = "exemplo.local" 

$usuarios = Import-Csv -Path "C:\Users\Sherlock\Relatorios\listausuarios.csv" -Delimiter ";"
$usuarios | ForEach-Object { Write-Host "Usuario encontrado: $($_.Nome), Grupo: $($_.Grupo)" }


foreach ($usuario in $usuarios) {
    $SamAccountName = $usuario.Nome
    $UPN = "$SamAccountName@$dominio"
    $grupo = $usuario.Grupo

    if (-not (Get-ADUser -Filter {SamAccountName -eq $SamAccountName} -ErrorAction SilentlyContinue)) {
        New-ADUser -Name $usuario.Nome `
                   -SamAccountName $SamAccountName `
                   -UserPrincipalName $UPN `
                   -AccountPassword (ConvertTo-SecureString $SPadrao -AsPlainText -Force) `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true `
                   -Path "CN=Users,DC=exemplo,DC=local"
    } else {
        Write-Host "Usuario $SamAccountName ja existe. Pulando criacao..."
    }

    if (-not (Get-ADGroup -Filter {Name -eq $grupo} -ErrorAction SilentlyContinue)) {
         New-ADGroup -Name $grupo -GroupScope Global -GroupCategory Security -Path "CN=Users,DC=exemplo,DC=local"
         Write-Host "Grupo $grupo criado."
    }


    Add-ADGroupMember -Identity $grupo -Members $SamAccountName
    Write-Host "Usuario $SamAccountName adicionado ao grupo $grupo."
}
