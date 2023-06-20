
."${PowerScriptsDirectory}\function_definitions.ps1"

$TokenString = Get-Token-String
If ($TokenString -Eq "") {
	
	# Launch the server with command parameters and redirect its output to a file
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "             Launching the Jupyter server in its own window" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	$ExePath = "${EnvironmentPath}\Scripts\jupyter-lab.exe"
	$CommandParameters = "--no-browser --config=${HomeDirectory}\.jupyter\jupyter_notebook_config.py --notebook-dir=${RepositoriesDirectory}"
	$OutputFile = "$Env:UserProfile\Downloads\lab_output.txt"
	# $ProcessOutput = Start-Process -FilePath $ExePath -ArgumentList $CommandParameters -RedirectStandardOutput $OutputFile
	$ArgList = "${ExePath} ${CommandParameters}"
	$ProcessOutput = Start-Process PowerShell -ArgumentList $ArgList -RedirectStandardOutput $OutputFile
	
	# Read and display the captured output from the file
	# $OutputContent = Get-Content -Path $OutputFile
	# Write-Host $OutputContent
	# Write-Host "Process ID: $($ProcessOutput.Id)"
	# Write-Host "Process Exit Code: $($ProcessOutput.ExitCode)"
	# Write-Host "${ProcessOutput}"
	
	Read-Host "Verify the Jupyter server is running, then press ENTER to continue..."
}

Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                          Getting the Jupyter Lab token" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
$ListResults = (jupyter server list) | Out-String
Write-Host $ListResults

# Open the webpage in Edge
$TokenRegex = [regex] '(?m)http://localhost:8888/\?token=([^ ]+) :: '
$TokenString = $TokenRegex.Match($ListResults).Groups[1].Value
If ($TokenString -Ne "") {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "                          Opening the workspace in Edge" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	# All other workspaces have a name that is part of the URL:
	# http(s)://<server:port>/<lab-location>/lab/workspaces/foo
	Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList "http://localhost:8888/lab/workspaces/${EnvironmentName}/tree/align-system/explorations/ITM%20Align%20System%20Exploration.ipynb"
}

# Add a workspace file for bookmarking. You can create a temporary workspace file in the 
# $Env:UserProfile\.jupyter\lab\workspaces folder by going to this URL:
# http://localhost:8888/lab/?clone=$EnvironmentName
# Get the path to the Jupyter workspaces folder
$WorkspacesFolder = "$Env:UserProfile\.jupyter\lab\workspaces"

# Check if the folder exists
if (Test-Path $WorkspacesFolder) {
	
	# Empty the folder
	Remove-Item $WorkspacesFolder -Recurse -Force
	
	# Create the workspace
	Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList "http://localhost:8888/lab/?clone=${EnvironmentName}"
	
	# Get the list of files in the folder
	$FilesList = Get-ChildItem $WorkspacesFolder
	
	# Get the path to the only file in the folder
	$FilePath = $FilesList[0].FullName
	Write-Host "${FilePath}"
	
}
