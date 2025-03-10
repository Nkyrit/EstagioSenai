$arquivoUsuarios = "C:\Users\Sherlock\Relatorios\listausuarios.csv"

$SPadrao = "Sherlock123!"

$usuarios = Import-Csv -Path $arquivoUsuarios

foreach ($usuario in $usuarios) {
    New-ADUser -Name $usuario.Nome `
               -UserPrincipalName $usuario.Nome `
               -AccountPassword (ConvertTo-SecureString $SPadrao -AsPlainText -Force) `
               -Enabled $true `
               -ChangePasswordAtLogon $true `
               -Path "CN=Users,DC=exemplo,DC=local"
    $grupo = $usuario.Grupo

    if (-not (Get-ADGroup -Filter "Name -eq '$grupo'" -ErrorAction SilentlyContinue)) {
         New-ADGroup -Name $grupo -GroupScope Global -GroupCategory Security -Path "CN=Users,DC=exemplo,DC=local"
    }
    
    Add-ADGroupMember -Identity $grupo -Members $usuario.Nome
}
