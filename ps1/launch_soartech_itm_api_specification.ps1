#Requires -Version 2.0

# Soli Deo gloria

# Run this in a PowerShell window:
# 
# cd $Env:UserProfile\Documents\GitHub\notebooks\ps1
# cls
# .\launch_soartech_itm_api_specification.ps1

# Set up global variables
$RepositoryName = "itm-api"
$EnvironmentName = "align_system"
$HomeDirectory = $Env:UserProfile
$RepositoriesDirectory = "${HomeDirectory}\Documents\GitHub"

# Get the folder path of the repository
$RepositoryPath = "${RepositoriesDirectory}\${RepositoryName}"

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

# Navigate to http://localhost:8000
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                       Opening a Windows Edge browser tab" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" `
  -ArgumentList "http://localhost:8000"

# Activate the environment
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                       Activating the ${EnvironmentName} environment" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
conda activate $EnvironmentName
conda info --envs

Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "       Running the Server from the ${RepositoryName} repository" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Set-Location $RepositoryPath
python -m http.server