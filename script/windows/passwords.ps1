if (-not (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) `
            -or (([Environment]::UserName) -eq "System"))) {
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy", "Bypass", "-Command", "Set-Location $PSScriptRoot; . '$PSCommandPath'" -Verb RunAs
}

function Get-Password {
    param (
        [Parameter(Mandatory = $false)]
        [int]$Length = 20,
        [Parameter(Mandatory = $false)]
        [int[]]$CharSet = 33..46 + 48..57 + 65..90 + 97..122
    )
    return -join ($CharSet | Get-Random -Count $Length | ForEach-Object { [char]$_ }) | ConvertTo-SecureString -AsPlainText
}

function Get-Users {
    param (
        [Parameter(Mandatory = $false)]
        [string[]]$Exclude = @('Administrator', 'Guest', 'DefaultAccount', 'WDAGUtilityAccount')
    )
    return (Get-LocalUser).Name | Where-Object { $_ -notin $Exclude }
}

Remove-Item "$PSScriptRoot\password.log" -Force -ErrorAction Stop

foreach ($User in Get-Users) {
    $Password = Get-Password -Length 20
    $PlaintextPassword = $Password | ConvertFrom-SecureString -AsPlainText

    Write-Output "Setting password for $User to $PlaintextPassword"
    Set-LocalUser -Name $User -Password $Password
    Out-File "$PSScriptRoot\password.log" -InputObject "${User}:$PlaintextPassword" -Append
}