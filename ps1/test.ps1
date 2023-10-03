#Requires -Version 2.0

# Soli Deo gloria

# Run this in a PowerShell window:
# 
# cd $Env:UserProfile\Documents\GitHub\align-system\ps1
# .\test.ps1

cls

# Set up global variables
$DisplayName = "ALIGN System"
$RepositoryName = "align-system"
$EnvironmentName = "align_system"

$HomeDirectory = $Env:UserProfile
$EnvironmentsDirectory = "${HomeDirectory}\anaconda3\envs"
$RepositoriesDirectory = "${HomeDirectory}\Documents\GitHub"
$RepositoryPath = "${RepositoriesDirectory}\${RepositoryName}"
$PowerScriptsDirectory = "${RepositoryPath}\ps1"
$EnvironmentPath = "${EnvironmentsDirectory}\${EnvironmentName}"
$OldPath = Get-Location

conda activate $EnvironmentName
."${PowerScriptsDirectory}\function_definitions.ps1"
$ActiveEnvironment = Get-Active-Conda-Environment
Write-Host "${ActiveEnvironment}"
