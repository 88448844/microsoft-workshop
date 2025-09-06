# Define color codes for PowerShell
$Green = [System.ConsoleColor]::Green
$DefaultColor = [System.ConsoleColor]::White

# Store initial directory
$InitialDir = Get-Location

# Check if we're in scripts directory and navigate accordingly
if ((Split-Path -Path (Get-Location) -Leaf) -eq "scripts") {
    Set-Location ..
}

Write-Host "Starting API (Flask) server..."

# Create and activate virtual environment
if (-not (Test-Path venv)) {
    python -m venv venv
}
if ($IsWindows) {
    & ./venv/Scripts/Activate.ps1
} else {
    & bash -c "source ./venv/bin/activate"
}

Set-Location server -ErrorAction Stop
pip install -r requirements.txt
Set-Location ..
$env:FLASK_DEBUG = 1
$env:FLASK_PORT = 5100


# Start Python server
$pythonProcess = Start-Process python `
    -WorkingDirectory (Join-Path $PSScriptRoot "..\server") `
    -ArgumentList "app.py" `
    -PassThru `
    -NoNewWindow

Write-Host "Starting client (Astro)..."
Set-Location client -ErrorAction Stop
npm install
cd ..
if ($IsWindows) {
    $npcCmd = "npm.cmd"
} else {
    $npcCmd = "npm"
}

$clientProcess = Start-Process "$npcCmd" `
    -WorkingDirectory (Join-Path $PSScriptRoot "..\client") `
    -ArgumentList "run", "dev", "--", "--no-clearScreen" `
    -PassThru `
    -NoNewWindow

# Sleep for 5 seconds
Start-Sleep -Seconds 5

# Display the server URLs
Write-Host "`nServer (Flask) running at: http://localhost:5100" -ForegroundColor $Green
Write-Host "Client (Astro) server running at: http://localhost:4321`n" -ForegroundColor $Green
Write-Host "Ctrl+C to stop the servers"

# Function to handle cleanup
function Cleanup {
    Write-Host "Shutting down servers..."
    
    # Kill processes and their child processes
    if ($pythonProcess) { Stop-Process -Id $pythonProcess.Id -Force -ErrorAction SilentlyContinue }
    if ($clientProcess) { Stop-Process -Id $clientProcess.Id -Force -ErrorAction SilentlyContinue }

    # Deactivate virtual environment if it exists
    if (Test-Path Function:\deactivate) {
        deactivate
    }

    # Return to initial directory
    Set-Location $InitialDir
    exit
}

# Register cleanup for script termination
$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action { Cleanup }

try {
    # Keep the script running until Ctrl+C
    Wait-Process -Id $pythonProcess.Id
} finally {
    Cleanup
}
