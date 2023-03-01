#Copyright (c) 2023, Antonios Gkougkoulis / Robert Rudik
#All rights reserved.

#This source code is licensed under the GPL-3.0 license found in the
#LICENSE file in the root directory of this source tree.

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][string]$LogPath,
    [Parameter(Mandatory = $true)][string]$ErrorString,
    [Parameter(Mandatory = $true)][string]$OkString
)

# VARIABLES
[int]$statusOk = 0
[int]$statusWarning = 1
[int]$statusCritical = 2
[int]$statusUnknown = 3


# Validate path
if (!(Test-Path -Path $LogPath -PathType Leaf)){
    Write-Output "$LogPath does not exist or is not a file!"
    exit $statusWarning
}

# Validate file type
$validExtensions = @(".log", ".txt")
$extension = [System.IO.Path]::GetExtension($LogPath)
if ($extension -notin $validExtensions){
    Write-Output "$LogPath is not a valid file type (.log or .txt)!"
    exit $statusWarning
}

# Load content
try {
    $logContent = [System.IO.File]::ReadAllText($LogPath)
}
catch {
    Write-Output "Failed to read $LogPath! Error: $_"
    exit $statusUnknown
}

# Break if empty file
if ([string]::IsNullOrWhiteSpace($logContent)){
    Write-Output "$LogPath is empty!"
    exit $statusWarning
}

# Parse last string and write message
$selStrings = [regex]::Matches($logContent, "$ErrorString|$OkString")
if ($selStrings.Count -ne 0){
    $lastString = $selStrings | Select-Object -Last 1
    if ($lastString.Value -eq $ErrorString){[int]$status = $statusCritical}
    if ($lastString.Value -eq $OkString){[int]$status = $statusOk}
    Write-Output "$status - $($lastString.Value)"
    exit $status
}
else{
    Write-Output "Log check OK - 0 pattern matches found."
    exit $statusOk
}
