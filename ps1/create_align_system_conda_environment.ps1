#Requires -Version 2.0

# Soli Deo gloria

# You have to manually stop the jupyter server before you run this in a PowerShell window
# if you are deleting the environment before recreating it:
# Run this in a PowerShell window:
# 
# cd $Env:UserProfile\Documents\GitHub\align-system\ps1
# cls
# .\create_align_system_conda_environment.ps1

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

conda activate base

# Delete environment folder
# ."${PowerScriptsDirectory}\delete_conda_environment.ps1"

# Create environment folder
# ."${PowerScriptsDirectory}\create_conda_environment.ps1"
# ."${PowerScriptsDirectory}\update_conda_environment.ps1"

# Bring up the workspace in Edge
."${PowerScriptsDirectory}\view_lab_in_edge.ps1"

# Launch the SoarTech ITM API specification
# ."${PowerScriptsDirectory}\launch_soartech_itm_api_specification.ps1"

# Launch the Kitware ALIGN system
# ."${PowerScriptsDirectory}\launch_kitware_align_system.ps1"

cd $OldPath