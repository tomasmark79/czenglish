# PowerShell Installation Script for Czech (czenglish) Keyboard Layout
# © 2025 Tomas Mark
# This script helps install the czenglish keyboard layout on Windows

# Requires running as Administrator
#Requires -RunAsAdministrator

param(
    [switch]$Uninstall,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Show-Help {
    Write-Host @"
Czech (czenglish) Keyboard Layout Installer
===========================================

Usage:
    .\Install-CzEnglishLayout.ps1          # Install the layout
    .\Install-CzEnglishLayout.ps1 -Uninstall    # Uninstall the layout
    .\Install-CzEnglishLayout.ps1 -Help         # Show this help

Prerequisites:
    1. Microsoft Keyboard Layout Creator (MSKLC) must be installed
    2. The .klc file must be compiled to a setup package using MSKLC
    3. This script must be run as Administrator

Steps to install:
    1. Open Microsoft Keyboard Layout Creator
    2. Load the czenglish.klc file (File -> Load Source File)
    3. Build the installer (Project -> Build DLL and Setup Package)
    4. Run this script or manually run the generated setup.exe

"@
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Layout {
    Write-Host "Czech (czenglish) Keyboard Layout Installer" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Cyan
    Write-Host ""

    # Check for MSKLC installation
    $msklcPaths = @(
        "${env:ProgramFiles(x86)}\Microsoft Keyboard Layout Creator 1.4\MSKLC.exe",
        "${env:ProgramFiles}\Microsoft Keyboard Layout Creator 1.4\MSKLC.exe"
    )

    $msklcFound = $false
    foreach ($path in $msklcPaths) {
        if (Test-Path $path) {
            $msklcFound = $true
            Write-Host "[OK] MSKLC found at: $path" -ForegroundColor Green
            break
        }
    }

    if (-not $msklcFound) {
        Write-Host "[WARNING] Microsoft Keyboard Layout Creator not found!" -ForegroundColor Yellow
        Write-Host "Please download and install MSKLC from:" -ForegroundColor Yellow
        Write-Host "https://www.microsoft.com/en-us/download/details.aspx?id=102134" -ForegroundColor Cyan
        Write-Host ""
    }

    # Look for compiled setup
    $setupPaths = @(
        ".\czenglish\setup.exe",
        ".\czenglish_amd64\setup.exe",
        ".\czenglish_i386\setup.exe",
        "..\czenglish\setup.exe"
    )

    $setupFound = $false
    $setupPath = ""
    foreach ($path in $setupPaths) {
        if (Test-Path $path) {
            $setupFound = $true
            $setupPath = $path
            Write-Host "[OK] Setup package found at: $path" -ForegroundColor Green
            break
        }
    }

    if ($setupFound) {
        Write-Host ""
        Write-Host "Installing keyboard layout..." -ForegroundColor Yellow
        try {
            Start-Process -FilePath $setupPath -Wait -Verb RunAs
            Write-Host "[OK] Installation completed!" -ForegroundColor Green
        }
        catch {
            Write-Host "[ERROR] Installation failed: $_" -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host ""
        Write-Host "[INFO] Setup package not found. Please compile the layout first:" -ForegroundColor Yellow
        Write-Host "  1. Open MSKLC" -ForegroundColor White
        Write-Host "  2. Load czenglish.klc (File -> Load Source File)" -ForegroundColor White
        Write-Host "  3. Build DLL and Setup (Project -> Build DLL and Setup Package)" -ForegroundColor White
        Write-Host "  4. Run the generated setup.exe from the output folder" -ForegroundColor White
        Write-Host ""
        
        # Try to add language manually
        Write-Host "Attempting to add Czech language support..." -ForegroundColor Yellow
        try {
            $languageList = Get-WinUserLanguageList
            $czechExists = $languageList | Where-Object { $_.LanguageTag -eq "cs-CZ" }
            
            if (-not $czechExists) {
                $languageList.Add("cs-CZ")
                Set-WinUserLanguageList $languageList -Force
                Write-Host "[OK] Czech language added to system" -ForegroundColor Green
            }
            else {
                Write-Host "[INFO] Czech language already installed" -ForegroundColor Cyan
            }
        }
        catch {
            Write-Host "[WARNING] Could not add language: $_" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart your computer (or log out and log back in)" -ForegroundColor White
    Write-Host "  2. Go to Settings -> Time & Language -> Language & region" -ForegroundColor White
    Write-Host "  3. Click on Czech -> Options -> Add a keyboard" -ForegroundColor White
    Write-Host "  4. Select 'Czech (czenglish)'" -ForegroundColor White
    Write-Host "  5. Use Windows + Space to switch between layouts" -ForegroundColor White
    Write-Host ""
}

function Uninstall-Layout {
    Write-Host "Czech (czenglish) Keyboard Layout Uninstaller" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Removing layout from user language list..." -ForegroundColor Yellow
    
    try {
        $languageList = Get-WinUserLanguageList
        $filtered = $languageList | Where-Object { 
            $_.InputMethodTips -notlike "*czenglish*" 
        }
        
        if ($languageList.Count -ne $filtered.Count) {
            Set-WinUserLanguageList $filtered -Force
            Write-Host "[OK] Layout removed from user preferences" -ForegroundColor Green
        }
        else {
            Write-Host "[INFO] Layout not found in user preferences" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "[ERROR] Could not remove layout: $_" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "To completely uninstall:" -ForegroundColor Cyan
    Write-Host "  1. Open Control Panel -> Programs -> Programs and Features" -ForegroundColor White
    Write-Host "  2. Find 'Czech (czenglish)' and uninstall" -ForegroundColor White
    Write-Host "  OR" -ForegroundColor Yellow
    Write-Host "  Run the setup.exe from the compiled package again and choose uninstall" -ForegroundColor White
    Write-Host ""
}

# Main script execution
if ($Help) {
    Show-Help
    exit 0
}

if (-not (Test-Administrator)) {
    Write-Host "[ERROR] This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

if ($Uninstall) {
    Uninstall-Layout
}
else {
    Install-Layout
}

Write-Host "Script completed." -ForegroundColor Green
