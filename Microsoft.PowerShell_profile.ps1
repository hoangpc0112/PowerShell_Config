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

function winfetch {
    $hostname = $env:COMPUTERNAME
    $username = $env:USERNAME
    $os = (Get-CimInstance Win32_OperatingSystem).Caption
    $cpu = (Get-CimInstance Win32_Processor).Name.Trim()
    $gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
    $ram_total = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    $ram_free = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)
    $ram_used = $ram_total - $ram_free
    $shell = $PSVersionTable.PSVersion
    $resolution = (Get-CimInstance Win32_VideoController | Select-Object -First 1).CurrentHorizontalResolution.ToString() + "x" + (Get-CimInstance Win32_VideoController | Select-Object -First 1).CurrentVerticalResolution.ToString()

$ascii_logo = @"

[37m⡧⠡⠡⢑⣌⣍⣍⣍⣍⣍⣍⣍⣍⣦⠀⣷⡈⢢⠘⡄⠱⡈⡆⣨⣩⣩⣩⣩⣩⣩⣩⣩⣩⣡⡊⠌⠌⠌⢼   [0m[1;37m$hostname  [0m@[1;37m$username[0m
[37m⣿⣾⣨⣿⠿⠟⠛⠛⠉⠉⠙⠙⠛⠾⣧⣿⣿⡌⢂⠘⡀⠡⣱⣿⣿⠿⠛⠛⠋⠋⠙⠛⠛⠛⠿⢾⣅⣷⣿   [0m─────────────────────────────────────────
[37m⠟⢋⣩⣤⣶⡶⣛⣭⣭⣭⣛⣿⣿⣷⣶⣿⣿⣿⡄⠣⢩⣾⣿⣿⣶⣾⣿⣿⣛⣭⣭⣭⣛⣿⣷⣦⣄⡙⠻   [0m[1;33mOS:        [0m[1;37m$os[0m
[37m⣾⣿⣿⣿⡿⣾⣿⣿⣿⣿⣿⣷⢿⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⡿⣾⣿⣿⣿⣿⣿⣷⢿⣿⣿⣿⣷   [0m[1;33mCPU:       [0m[1;37m$cpu[0m
[37m⣿⣿⣿⣿⣇⣿⣿⣿⣿⣿⣿⣿⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⣿⣿⣿⣿⣿⣿⣿⣸⣿⣿⣿⣿   [0m[1;33mGPU:       [0m[1;37m$gpu[0m
[37m⣿⣿⣿⣿⣿⣞⢿⣿⣿⣿⡿⣳⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣞⢿⣿⣿⣿⡿⣳⣿⣿⣿⣿⣿   [0m[1;33mRes:       [0m[1;37m$resolution[0m
[37m⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿   [0m[1;33mMem:       [0m[1;37m$ram_used GB / $ram_total GB[0m
[37m⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⣝⡻⡿⢿⢿⢿⢟⣮⡻⡿⡿⡿⢿⢟⣫⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿   [0m[1;33mShell:     [0m[1;37mPowerShell $shell[0m
[37m⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⢹⣿⣿⣿⣿⣿⣿⣿⡏⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿   [0m
[37m⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⢻⣿⣿⣿⣿⣿⡟⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿   [0m[1;41m    [1;42m    [1;43m    [1;44m    [1;45m    [1;46m    [1;47m    [0m
[37m⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣭⣭⣭⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿   [0m[1;41m    [1;42m    [1;43m    [1;44m    [1;45m    [1;46m    [1;47m    [0m
"@

    Write-Host $ascii_logo
}

Write-Host "`n💡 Hi HoangPC, what can I do for you today? ❤️`n" -ForegroundColor White

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

# Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })