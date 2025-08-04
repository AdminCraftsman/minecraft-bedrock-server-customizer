# Set-McbeServerProperties.ps1
param(
    [Parameter(Mandatory = $true)]
    [string]$propertiesFile
)

if (!(Test-Path $propertiesFile)) {
    Write-Host "File '$propertiesFile' not found."
    exit 1
}

# Read properties, ignoring comments and blank lines
$lines = Get-Content $propertiesFile
$props = @()
foreach ($line in $lines) {
    if ($line -match '^\s*#' -or $line -match '^\s*$') {
        $props += @{ Raw = $line; IsSetting = $false }
    } elseif ($line -match '^\s*([^=]+)\s*=\s*(.*)$') {
        $props += @{
            Raw = $line
            IsSetting = $true
            Key = $matches[1].Trim()
            Value = $matches[2].Trim()
        }
    } else {
        $props += @{ Raw = $line; IsSetting = $false }
    }
}

# Show settings enumerated
$settings = $props | Where-Object { $_.IsSetting }
for ($i = 0; $i -lt $settings.Count; $i++) {
    Write-Host "$($i+1). $($settings[$i].Key) = $($settings[$i].Value)"
}

# Prompt user for selection
$selection = Read-Host "Enter the number of the setting to change"
if (-not ($selection -match '^\d+$') -or $selection -lt 1 -or $selection -gt $settings.Count) {
    Write-Host "Invalid selection."
    exit 1
}

$selectedSetting = $settings[$selection - 1]
$newValue = Read-Host "Enter new value for '$($selectedSetting.Key)' (current: $($selectedSetting.Value))"

# Update value in props
$settingIndex = ($props | Where-Object { $_.IsSetting }) | Select-Object -Index ($selection - 1)
for ($i = 0; $i -lt $props.Count; $i++) {
    if ($props[$i].IsSetting -and $props[$i].Key -eq $selectedSetting.Key) {
        $props[$i].Raw = "$($selectedSetting.Key)=$newValue"
        $props[$i].Value = $newValue
        break
    }
}

# Write back to file
Set-Content $propertiesFile ($props | ForEach-Object { $_.Raw })

Write-Host "Setting updated and saved to '$propertiesFile'."