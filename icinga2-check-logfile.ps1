#Copyright (c) 2022, Antonios Gkougkoulis / Robert Rudik
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
if (!(Test-Path -Path $LogPath)){
    Write-Output "$LogPath does not exist!"
    exit $statusWarning
}

# Brake if not a file
$fileProps = Get-Item -Path $LogPath
if ($fileProps.PSIsContainer -eq $true){
    Write-Output "$LogPath is directory! Provide file!"
    exit $statusWarning
}

# Break if not .log or .txt file type
if ('.log','.txt' -notcontains $fileProps.Extension){
    Write-Output "$LogPath is not .log or .txt file type!"
    exit $statusWarning
}

# Load content
$logContent = Get-Content -Path $LogPath

# Break if empty file
if (($fileProps.Length -eq 0) -or ($logContent.Count -eq 0)){
    Write-Output "$LogPath is empty!"
    exit $statusWarning
}

# Parse last string and write message
$selStrings = $logContent |Select-String -Pattern "$ErrorString|$OkString" -CaseSensitive
if ($selStrings.Line.Count -ne 0){
    $lastString = $selStrings |Select-Object -Last 1
    if ($lastString.Matches.Value -eq $ErrorString){[int]$status = $statusCritical}
    if ($lastString.Matches.Value -eq $OkString){[int]$status = $statusOk}
    Remove-Variable -Name LogPath, ErrorString, OkString, fileProps, logContent, selStrings -ErrorAction SilentlyContinue
    Write-Output "$status - $($lastString.Line)"
    exit $status
}
else{
    Remove-Variable -Name LogPath, ErrorString, OkString, fileProps, logContent, selStrings -ErrorAction SilentlyContinue
    Write-Output "Log check OK - 0 pattern matches found."
    exit $statusOk
}
