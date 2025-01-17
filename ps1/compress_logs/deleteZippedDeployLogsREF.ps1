# Setting variables
$logPath = "C:\Develop\_compressRefLogs\logs"

# Log rotation settings
$maxLogSizeMB = 10 # Maximum log file size in MB
$logFile = "$logPath\delete_log_archives.log"

# Function to get the current timestamp
function Get-Timestamp {
    return (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
}

# Function to delete log file if it exceeds the maximum size
function Delete-LogFileIfTooBig {
    if (Test-Path $logFile) {
        $logFileSizeMB = (Get-Item $logFile).length / 1MB
        if ($logFileSizeMB -gt $maxLogSizeMB) {
            Remove-Item -Path $logFile -Force
            Write-Output "$(Get-Timestamp) Log file deleted: $logFile"
        }
    }
}

# Function to delete old zip files
function DeleteOldZipFiles {
    param(
        [string]$sourceDir
    )

    $timestamp = Get-Timestamp
    Write-Output "$timestamp Processing directory: $sourceDir"
    $logContent = "[$timestamp] Processing directory: $sourceDir`n"

    # Filter .zip files older than 365 days
    $existingZips = Get-ChildItem -Path $sourceDir -File -Filter *.zip | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-365) }

    # Check if there are .zip files to delete
    if ($existingZips) {
        foreach ($zipFile in $existingZips) {
            Remove-Item -Path $zipFile.FullName -Force
            $logContent += "[$timestamp] Deleted old zip file: $($zipFile.FullName)`n"
            Write-Output "$timestamp Deleted old zip file: $($zipFile.FullName)"
        }
    } else {
        $logContent += "[$timestamp] No .zip files older than 365 days found in directory: $sourceDir`n"
        Write-Output "$timestamp No .zip files older than 365 days found in directory: $sourceDir"
    }

    # Append the log content to the log file
    $logContent | Out-File -FilePath $logFile -Append -Encoding utf8
}

# Delete old log file if it exceeds the maximum size
Delete-LogFileIfTooBig

# List of directories to process
$sourceDirs = @(
    "C:\Develop\deployment_logs\client",
    "C:\Develop\deployment_logs\client1",
    "C:\Develop\deployment_logs\client2",
    "C:\Develop\deployment_logs\client3",
    "C:\Develop\deployment_logs\client4"
)

# Process each directory
foreach ($sourceDir in $sourceDirs) {
    if (Test-Path $sourceDir) {
        DeleteOldZipFiles -sourceDir $sourceDir
    } else {
        $timestamp = Get-Timestamp
        $logContent = "[$timestamp] Directory does not exist: $sourceDir`n"
        Write-Output "$timestamp Directory does not exist: $sourceDir"
        $logContent | Out-File -FilePath $logFile -Append -Encoding utf8
    }
}

Write-Output "$(Get-Timestamp) Script completed."