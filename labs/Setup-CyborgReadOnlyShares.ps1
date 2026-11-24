<#
.SYNOPSIS
    Legt auf VanstrikeCyborg zwei dedizierte Read-Only-SMB-Freigaben fuer den SimRacer-Host an.
    Muss einmalig in einer erhoehten PowerShell (Als Administrator ausfuehren) gestartet werden.
#>

$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Bitte dieses Skript einmalig in einer PowerShell 'Als Administrator ausfuehren' starten!"
    exit 1
}

$shares = @(
    @{
        Name = 'Cyborg-GitLabor-RO'
        Path = 'C:\Users\strik\git-labor'
        Desc = 'Read-Only fuer SimRacer Host VS Code'
    },
    @{
        Name = 'Cyborg-AC-Content-RO'
        Path = 'C:\Users\strik\assetto-corsa-content'
        Desc = 'Read-Only fuer SimRacer Host VS Code'
    }
)

foreach ($s in $shares) {
    $existing = Get-SmbShare -Name $s.Name -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Output "Aktualisiere bestehende Freigabe $($s.Name) auf reines Read-Only..."
        Remove-SmbShare -Name $s.Name -Force
    }
    New-SmbShare -Name $s.Name -Path $s.Path -ReadAccess 'VANSTRIKECYBORG\strik' -Description $s.Desc | Out-Null
    Write-Output "[OK] Read-Only SMB Share erstellt: \\VanstrikeCyborg\$($s.Name) -> $($s.Path)"
    Get-SmbShareAccess -Name $s.Name | Format-Table -AutoSize
}

Write-Output "`nFertig. Auf dem SimRacer-Host sind \\VanstrikeCyborg\Cyborg-GitLabor-RO und \\VanstrikeCyborg\Cyborg-AC-Content-RO nun OS-seitig streng schreibgeschuetzt."
