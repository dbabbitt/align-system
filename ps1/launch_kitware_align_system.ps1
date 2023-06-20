#Requires -Version 2.0

# Soli Deo gloria

# Run this in a PowerShell window:
# 
# cd $Env:UserProfile\Documents\GitHub\align-system\ps1
# cls
# .\launch_kitware_align_system.ps1

# Set up global variables
$RepositoryName = "align-system"
$EnvironmentName = "align_system"
$HomeDirectory = $Env:UserProfile
$RepositoriesDirectory = "${HomeDirectory}\Documents\GitHub"
$RepositoryPath = "${RepositoriesDirectory}\${RepositoryName}"
$PowerScriptsDirectory = "${RepositoryPath}\ps1"
$EnvironmentLocation = "${HomeDirectory}\anaconda3\envs\${EnvironmentName}"

conda activate base

# Set Conda to fixed
$IsCondaFixed = $true
if ($IsCondaFixed -eq $false) {
	
	# Allow downgrades
	conda config --set channel_priority flexible
	conda config --remove channels conda-forge
	conda config --add channels conda-forge
	conda config --set allow_conda_downgrades true
	
	# Find and download the standalone conda executable you want here:
	# https://repo.anaconda.com/pkgs/misc/conda-execs/
	# Assuming conda 23.5.0 needs to be replaced
	$CondaVersion = "4.10.3"
	
	# Get the path to the installer
	$DownloadPath = "${env:TEMP}\conda-installer.exe"
	
	# Download the Conda installer
	$DownloadUrl = "https://repo.anaconda.com/pkgs/misc/conda-execs/conda-${CondaVersion}-win-64.exe"
	if (Test-Path $DownloadPath) {
		Write-Host ""
		Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
		Write-Host "                 Conda installer already downloaded" -ForegroundColor Green
		Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	} else {
		Write-Host ""
		Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
		Write-Host "  Downloading ${DownloadUrl} to ${DownloadPath}" -ForegroundColor Green
		Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
		Invoke-WebRequest -Uri $DownloadUrl -OutFile $DownloadPath
	}
	
	# Set additional command parameters
	$CondaFolder = Split-Path -Parent (Get-Command conda.exe).Path
	$CommandParameters = "install -p ${CondaFolder} conda=${CondaVersion}"
	$OutputFile = "$Env:UserProfile\Downloads\installer_output.txt"
	
	# Run the installer with command parameters and redirect its output to a file
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "  Installing ${DownloadPath} ${CommandParameters}" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	$ProcessOutput = Start-Process -FilePath $DownloadPath -ArgumentList $CommandParameters -RedirectStandardOutput $OutputFile -NoNewWindow -Wait
	
	# Read and display the captured output from the file
	$OutputContent = Get-Content -Path $OutputFile
	# Write-Host $OutputContent
	# Write-Host "Process ID: $($ProcessOutput.Id)"
	# Write-Host "Process Exit Code: $($ProcessOutput.ExitCode)"
	# Write-Host "${ProcessOutput}"

	# Prohibit auto updates
	conda config --set auto_update_conda false
	
	# Reinstall Jupyter Lab
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "                                Installing Jupyter Lab" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	conda install --yes --quiet --channel conda-forge jupyterlab
	
}

# Update Conda (this might just break it again)
# conda update --yes --quiet --name base --channel defaults conda

# Create the environment
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
if (conda env list | findstr $EnvironmentName) {
	Write-Host "                       Updating the ${EnvironmentName} environment" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	conda update --all --yes --quiet --name $EnvironmentName
} else {
	Write-Host "                       Creating the ${EnvironmentName} environment" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	conda create --yes --quiet --name $EnvironmentName python=3.10
}

# Activate the environment
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                       Activating the ${EnvironmentName} environment" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
conda activate $EnvironmentName
conda info --envs

# Install the required dependencies
$FilePath = "${EnvironmentLocation}\Lib\site-packages\torch\__init__.py"
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
	pip install -r requirements.txt
}

# Install the TA3 ITM MVP modules
."${PowerScriptsDirectory}\install_ncc_itm_mvp.ps1"

# Run the Server
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "       Running the Server from the ${RepositoryName} repository" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
cd "${RepositoriesDirectory}\itm-mvp\itm_server"
python -m swagger_server