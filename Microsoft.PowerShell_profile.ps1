using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Import-Module -Name Terminal-Icons

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\space.omp.json" | Invoke-Expression

# Check connection
$canConnectToGitHub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1

function Update-GlazeWM {
    try {
        $url = "https://raw.githubusercontent.com/hoangpc0112/GlazeWM_2.11_Config/main/config.yaml"
        $oldhash = Get-FileHash "$env:USERPROFILE/.glaze-wm/config.yaml"
        Invoke-RestMethod $url -OutFile "$env:temp/GlazeWM_config.yaml"
        $newhash = Get-FileHash "$env:temp/GlazeWM_config.yaml"
        
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item -Path "$env:temp/GLazeWM_config.yaml" -Destination "$env:USERPROFILE/.glaze-wm/config.yaml" -Force
            Write-Host "GlazeWM config updated. Please reload" -ForegroundColor Magenta
        }
        else {
            Write-Host "GlazeWM config is up to date" -ForegroundColor Green
        }
    } catch {
        Write-Error "GlazeWM config update failed"
    } finally {
        Remove-Item "$env:temp/GlazeWM_config.yaml" -ErrorAction SilentlyContinue
    }
}

function Update-Profile {
    try {
        $url = "https://raw.githubusercontent.com/hoangpc0112/PowerShell_Config/main/Microsoft.PowerShell_profile.ps1"
        $oldhash = Get-FileHash $PROFILE
        Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
        $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
        
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
            Write-Host "PowerShell profile updated. Please reload" -ForegroundColor Magenta
        }
        else {
            Write-Host "PowerShell profile is up to date" -ForegroundColor Green
        }
    } catch {
        Write-Error "PowerShell profile update failed"
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

function wf {
    $hostname = $env:COMPUTERNAME
    $username = $env:USERNAME
    $os = (Get-CimInstance Win32_OperatingSystem).Caption
    $cpu = (Get-CimInstance Win32_Processor).Name.Trim()

    $gpuList = Get-CimInstance Win32_VideoController
    if ($gpuList.Count -gt 1) {
        $gpu = $gpuList[1].Name
    } else {
        $gpu = $gpuList[0].Name
    }
    $gpuWords = $gpu -split "\s+"
    if ($gpuWords.Count -gt 2) {
        $gpu = ($gpuWords[0..($gpuWords.Count - 3)]) -join " "
    }
    
    $ram_total = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 0)
    $shell = $PSVersionTable.PSVersion
    $resolution = (Get-CimInstance Win32_VideoController | Select-Object -First 1).CurrentHorizontalResolution.ToString() + "x" + (Get-CimInstance Win32_VideoController | Select-Object -First 1).CurrentVerticalResolution.ToString()

$winfetch = @"

[37m⡧⠡⠡⢑⣌⣍⣍⣍⣍⣍⣍⣍⣍⣦⠀⣷⡈⢢⠘⡄⠱⡈⡆⣨⣩⣩⣩⣩⣩⣩⣩⣩⣩⣡⡊⠌⠌⠌⢼   [0m[1;33m$hostname    [0m@[1;37m$username[0m
[37m⣿⣾⣨⣿⠿⠟⠛⠛⠉⠉⠙⠙⠛⠾⣧⣿⣿⡌⢂⠘⡀⠡⣱⣿⣿⠿⠛⠛⠋⠋⠙⠛⠛⠛⠿⢾⣅⣷⣿   [0m─────────────────────────────────────────
[37m⠟⢋⣩⣤⣶⡶⣛⣭⣭⣭⣛⣿⣿⣷⣶⣿⣿⣿⡄⠣⢩⣾⣿⣿⣶⣾⣿⣿⣛⣭⣭⣭⣛⣿⣷⣦⣄⡙⠻   [0m[1;33mOS:        [0m[1;37m$os[0m
[37m⣾⣿⣿⣿⡿⣾⣿⣿⣿⣿⣿⣷⢿⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⡿⣾⣿⣿⣿⣿⣿⣷⢿⣿⣿⣿⣷   [0m[1;33mCPU:       [0m[1;37m$cpu[0m
[37m⣿⣿⣿⣿⣇⣿⣿⣿⣿⣿⣿⣿⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⣿⣿⣿⣿⣿⣿⣿⣸⣿⣿⣿⣿   [0m[1;33mGPU:       [0m[1;37m$gpu[0m
[37m⣿⣿⣿⣿⣿⣞⢿⣿⣿⣿⡿⣳⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣞⢿⣿⣿⣿⡿⣳⣿⣿⣿⣿⣿   [0m[1;33mRes:       [0m[1;37m$resolution[0m
[37m⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿   [0m[1;33mMem:       [0m[1;37m$ram_total GB[0m
[37m⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⣝⡻⡿⢿⢿⢿⢟⣮⡻⡿⡿⡿⢿⢟⣫⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿   [0m[1;33mShell:     [0m[1;37mPowerShell $shell[0m
[37m⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⢹⣿⣿⣿⣿⣿⣿⣿⡏⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿   [0m
[37m⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⢻⣿⣿⣿⣿⣿⡟⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿   [0m[1;41m    [1;42m    [1;43m    [1;44m    [1;45m    [1;46m    [1;47m    [0m
[37m⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣭⣭⣭⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿   [0m[1;41m    [1;42m    [1;43m    [1;44m    [1;45m    [1;46m    [1;47m    [0m

"@
    Write-Host $winfetch
}

Write-Host "`n💡 Hi HoangPC, what can I do for you today? ❤️`n" -ForegroundColor White

# Core utilities
function which ($command) { Get-Command $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path }
function reload-profile { & $profile }
function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize }
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize }
function pwd { Get-Location }
function wtadmin {Start-Process wt -Verb RunAs}
function mf {
    param (
        [string]$FileNamePattern,   # Filename pattern (e.g., "*.txt", "file*.log")
        [int]$Count,                # Number of files to move
        [string]$Destination        # Target directory
    )

    if (!(Test-Path -Path $Destination)) {
        Write-Host "Creating destination directory: $Destination"
        New-Item -ItemType Directory -Path $Destination | Out-Null
    }

    $files = Get-ChildItem -Path . -Filter $FileNamePattern | Select-Object -First $Count

    if ($files.Count -eq 0) {
        Write-Host "No files found matching the pattern '$FileNamePattern'."
        return
    }

    foreach ($file in $files) {
        Move-Item -Path $file.FullName -Destination $Destination -Force
        Write-Host "Moved: $($file.Name) → $Destination"
    }
}


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

# Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })