#Requires -Version 2.0

# Soli Deo gloria

# Run this in a PowerShell window:
# 
# cd $Env:UserProfile\Documents\GitHub\notebooks\ps1
# .\test.ps1

cls

# Open a Windows Edge browser tab
Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" `
  -ArgumentList "http://localhost:8000"

# Do something else
Write-Host "The browser tab is loading..."
