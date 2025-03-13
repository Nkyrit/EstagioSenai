$usuarios = Get-Content "C:\Users\Relatorios\listausuarios.txt"

foreach ($linha in $usuarios) {
$dados = $linha -split ";"
$username = $dados[0]
$group = $dados[1]
$password = ConvertTo-SecureString "Sherlock#123654" -AsPlainText -Force
New-ADUser -SamAccountName $username `
    -UserPrincipalName "$username@exemplo.local" `
    -Name $username `
    -GivenName ($username -split "_")[0] `
    -Surname ($username -split "_")[1] `
    -Path "OU=Usuarios,DC=exemplo,DC=local" `
    -AccountPassword $password `
    -Enabled $true `
    -ChangePasswordAtLogon $true
}

$grupos = $usuarios | ForEach-Object { ($_ -split ";")[1] } | Select-Object -Unique
foreach ($grupo in $grupos) {
    if (-not (Get-ADGroup -Filter {Name -eq $grupo})) {
        New-ADGroup -Name $grupo -GroupScope Global -Path "OU=Grupos,DC=exemplo,DC=local"
    }
}

foreach ($linha in $usuarios) {
    $dados = $linha -split ";"
    $username = $dados[0]
    $group = $dados[1]
    Add-ADGroupMember -Identity $group -Members $username
}

    if (-not (Get-ADUser -Filter {SamAccountName -eq $username})) {
..........
}     else {
Write-Host "Usuário $username já existe..."
}

    if (-not (Get-ADGroup -Filter {Name -eq $grupo})) {
.....
}     else {
Write-Host "Grupo $grupo já existe..."
}

    if (-not (Get-ADGroupMember -Identity $group | Where-Object { $_.SamAccountName -eq
$username })) {
....
}     else {
Write-Host "Usuário $username já está no grupo $group..."
}
