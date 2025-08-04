# New-McbeServer.ps1
param (
    [string]$InstallPath,
    [string]$ServerName
)

if (-not $InstallPath) {
    $InstallPath = "C:\McbeServers"
}
if (-not $ServerName) {
    $ServerName = "DefaultServer"
}
if (-not (Test-Path -Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath
}

# TODO: Come up with a better way to get the latest version of the server software
# For now, we will use a hardcoded URL for the latest version
# This URL should be updated when a new version is released
# Example: https://www.minecraft.net/bedrockdedicatedserver/bin-win/bedrock-server-x.x.x.zip
Write-Host "Installing Mcbe Server '$ServerName' to '$InstallPath'..."
$downloadUrl = "https://www.minecraft.net/bedrockdedicatedserver/bin-win/bedrock-server-1.21.95.1.zip"
$zipFile = "$env:TEMP\bedrock_server.zip"
$extractPath = Join-Path -Path $InstallPath -ChildPath "Mcbe Server - $ServerName"

# Create the directory if it doesn't exist
if (-Not (Test-Path -Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath
}

# Download the latest server software
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile

# Extract the downloaded zip file
Expand-Archive -Path $zipFile -DestinationPath $extractPath -Force

# Clean up
Remove-Item -Path $zipFile