#Requires -Version 2.0

# Soli Deo gloria

# Run this in a PowerShell window:
# 
# cd $Env:UserProfile\Documents\GitHub\align-system\ps1
# .\test.ps1

cls

# Open a Windows Edge browser tab
$EnvironmentName = "align_system"
$TokenString = "c5609a9b73cb0d7d1e7c93ad51cc8d62333cca248c7d2696"
	Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList "http://localhost:8888/lab/workspaces/${EnvironmentName}&token=${TokenString}"

# Do something else
Write-Host "The browser tab is loading..."
