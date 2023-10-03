#Requires -Version 2.0

# Soli Deo gloria

# Run this in a PowerShell window:
# 
# cd $Env:UserProfile\Documents\GitHub\align-system\ps1
# cls
# .\launch_soartech_ta1_server_mvp.ps1

# Set up global variables
$RepositoryName = "ta1-server-mvp"
$EnvironmentName = "align_system"
$HomeDirectory = $Env:UserProfile
$RepositoriesDirectory = "${HomeDirectory}\Documents\GitHub"
$RepositoryPath = "${RepositoriesDirectory}\${RepositoryName}"
$EnvironmentLocation = "${HomeDirectory}\anaconda3\envs\${EnvironmentName}"

# Update the repository
if (Test-Path $RepositoryPath) {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "                       Updating the ${RepositoryName} repository" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Set-Location $RepositoryPath
	git pull
}

# Clone the repository
else {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "                       Cloning the ${RepositoryName} repository" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	$WebUrl = "https://github.com/ITM-Soartech/${RepositoryName}.git"
	git clone $WebUrl $RepositoryPath
}

# Activate the environment
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                       Activating the ${EnvironmentName} environment" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
conda activate $EnvironmentName
conda info --envs

# Install the required dependencies
$FilePath = "${EnvironmentLocation}\Lib\site-packages\uvicorn\__init__.py"
if (Test-Path $FilePath) {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "    Required dependencies already installed in the ${EnvironmentName} environment" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
} else {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "  Installing the required dependencies in the ${EnvironmentName} environment" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	cd $RepositoryPath
	python -m pip install -r requirements.txt
}

# Install the MVP App for TA1
$FilePath = "${EnvironmentLocation}\Lib\site-packages\itm-app.egg-link"
if (Test-Path $FilePath) {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "             The MVP App for TA1 is already installed" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
} else {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "       Installing the MVP App for TA1 from the ${RepositoryName} repository" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	cd $RepositoryPath
	python -m pip install -e .
}

# Run the TA1 Server
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "       Running the TA1 Uvicorn Server from the ${RepositoryName} repository" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
cd $RepositoryPath
$OriginalProcesses = Get-Process | Where-Object {$_.Name -eq "python"} | Select-Object Id
python -m itm_app
$StartedProcesses = Get-Process | Where-Object {$_.Name -eq "python"} | Select-Object Id
$NewProcess = $StartedProcesses | Where-Object { !($OriginalProcesses -contains $_) }
if ($NewProcess) {
  Write-Host "To stop this programmatically, you could do taskkill /F /PID $NewProcess."
}

# Open the webpage in Edge
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                      Opening the kickoff scenario in Edge" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList "http://localhost:8084/api/v1/scenario/kickoff-demo-scenario-1/	"