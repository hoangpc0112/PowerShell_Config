using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Import-Module PSReadLine
Import-Module -Name Terminal-Icons
set-alias desktop "Desktop.ps1"

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\space.omp.json" | Invoke-Expression

$canConnectToGitHub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1

function Update-GlazeWM {
    try {
        $url = "https://raw.githubusercontent.com/hoangpc0112/GlazeWM_2.11_Config/refs/heads/main/config.yaml"
        $oldhash = Get-FileHash "$env:USERPROFILE/.glaze-wm/config.yaml"
        Invoke-RestMethod $url -OutFile "$env:temp/GlazeWM_config.yaml"
        $newhash = Get-FileHash "$env:temp/GlazeWM_config.yaml"
        
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item -Path "$env:temp/GLazeWM_config.yaml" -Destination "$env:USERPROFILE/.glaze-wm/config.yaml" -Force
            Write-Host "Config updated. Reload GlazeWM" -ForegroundColor Magenta
        }
        else {
            Write-Host "GlazeWM up to date" -ForegroundColor Green
        }
    } catch {
        Write-Error "Config update failed"
    } finally {
        Remove-Item "$env:temp/GlazeWM_config.yaml" -ErrorAction SilentlyContinue
    }
}

function Update-Profile {
    try {
        $url = "https://raw.githubusercontent.com/hoangpc0112/PowerShell_Config/refs/heads/main/Microsoft.PowerShell_profile.ps1"
        $oldhash = Get-FileHash $PROFILE
        Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
        $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
        
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
            Write-Host "Profile updated. Please reload" -ForegroundColor Magenta
        }
        else {
            Write-Host "Profile is up to date" -ForegroundColor Green
        }
    } catch {
        Write-Error "Profile update failed"
    } finally {
        Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
    }
}

function Update-PowerShell {
    try {
        $currentVersion = $PSVersionTable.PSVersion.ToString()
        $latestVersion = (Invoke-RestMethod "https://api.github.com/repos/PowerShell/PowerShell/releases/latest").tag_name.Trim('v')
        
        if ($currentVersion -lt $latestVersion) {
            winget upgrade "Microsoft.PowerShell" --accept-source-agreements --accept-package-agreements
            Write-Host "PowerShell updated. Please restart" -ForegroundColor Magenta
        }
        else {
            Write-Host "PowerShell is up to date" -ForegroundColor Green
        }
    } catch {
        Write-Error "PowerShell update failed"
    }
}

if ($global:canConnectToGitHub) {
    Update-GlazeWM
    Update-Profile
    Update-PowerShell
}

Write-Host "`n🚀 Hi HoangPC, what can I do for you today? ❤️`n" -ForegroundColor White

# Core utilities
function which ($command) { Get-Command $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path }
function reload-profile { & $profile }
function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize }
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize }

# Git shortcuts
function gs { git status }
function ga { git add . }
function gc { param($m) git commit -m "$m" }
function gp { git push }
function lazyg { git add .; git commit -m "$args"; git push }

# Shell experience
Set-PSReadLineOption -Colors @{ Command = 'Yellow'; Parameter = 'Green'; String = 'Cyan' }
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    winget complete --word="$($wordToComplete.Replace('"', '""'))" --commandline "$($commandAst.ToString().Replace('"', '""'))" --position $cursorPosition | 
        ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
}

Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Chocolatey integration
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path $ChocolateyProfile) { Import-Module $ChocolateyProfile }
