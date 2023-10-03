#Requires -Version 2.0

# Soli Deo gloria

# Run this in an Admin PowerShell window:
# 
# cd $Env:UserProfile\Documents\GitHub\notebooks\ps1
# cls
# .\install_ncc_itm_mvp.ps1

# Set up global variables
$RepositoryName = "itm-mvp"
$EnvironmentName = "align_system"
$HomeDirectory = $Env:UserProfile
$RepositoriesDirectory = "${HomeDirectory}\Documents\GitHub"
$EnvironmentLocation = "${HomeDirectory}\anaconda3\envs\${EnvironmentName}"

conda activate base

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
	$WebUrl = "https://github.com/NextCenturyCorporation/${RepositoryName}.git"
	git clone $WebUrl $RepositoryPath
}

# Create the environment
# Write-Host ""
# Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
# if (conda env list | findstr $EnvironmentName) {
	# Write-Host "                       Updating the ${EnvironmentName} environment" -ForegroundColor Green
	# Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	# conda update --all --yes --quiet --name $EnvironmentName
# } else {
	# Write-Host "                       Creating the ${EnvironmentName} environment" -ForegroundColor Green
	# Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	# conda create --yes --quiet --name $EnvironmentName python=3.10
# }

# Activate the environment
."${PowerScriptsDirectory}\function_definitions.ps1"
$ActiveEnvironment = Get-Active-Conda-Environment
# Write-Host "${ActiveEnvironment} -contains ${EnvironmentName}"
if (-not ($ActiveEnvironment -contains $EnvironmentName)) {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "                       Activating the ${EnvironmentName} environment" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	conda activate $EnvironmentName
	conda info --envs
}

# Install the TA3 ITM MVP client module
$FilePath = "${EnvironmentLocation}\Lib\site-packages\swagger-client.egg-link"
if (Test-Path $FilePath) {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "             The TA3 ITM MVP client module is already installed" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
} else {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "       Installing the TA3 ITM MVP client module from the ${RepositoryName} repository" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	cd "${RepositoriesDirectory}\${RepositoryName}\itm_client"
	pip install -e .
}

# Install the TA3 ITM MVP server module
$FilePath = "${EnvironmentLocation}\lib\site-packages\swagger_ui_bundle\__init__.py"
if (Test-Path $FilePath) {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "             The TA3 ITM MVP server module is already installed" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
} else {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "       Installing the TA3 ITM MVP server module from the ${RepositoryName} repository" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	cd "${RepositoriesDirectory}\${RepositoryName}\itm_server"
	pip install -r requirements.txt
}