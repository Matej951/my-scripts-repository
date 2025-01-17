# Setting common variables
$basePath = "C:\Develop\_compressRefLogs"
$logPath = "C:\Develop\_compressRefLogs\logs"
$archiveBasePath = "C:\Develop\deployment_logs\_archive"
$timestampArchive = Get-Date -Format "yyyyMMdd_HHmmss"

# Log rotation settings
$maxLogSizeMB = 10 # Maximum log file size in MB
$logFile = "$logPath\compress_old_logs.log"

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

# Perform log size check and deletion if needed
Delete-LogFileIfTooBig

# Initialize an empty string for log content
$logContent = ""

# List of directories to process
$sourceDirs = @(
    "C:\Develop\deployment_logs\client",
    "C:\Develop\deployment_logs\client1",
    "C:\Develop\deployment_logs\client2",
    "C:\Develop\deployment_logs\client3",
    "C:\Develop\deployment_logs\client4"
)

# Loop through each directory
foreach ($sourceDir in $sourceDirs) {
    $currentTimestamp = Get-Timestamp
    Write-Output "$currentTimestamp Processing directory: $sourceDir"
    $logContent += "[$currentTimestamp] Processing directory: $sourceDir`n"
    
    # Filter .log files older than 5 days
    $filesToCompress = Get-ChildItem -Path $sourceDir -File -Filter *.log | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-5) }

    # Check if there are files to compress
    if ($filesToCompress) {
        # Extract folder name from sourceDir
        $folderName = Split-Path $sourceDir -Leaf
        
        # Set the archive directory
        $archiveDir = Join-Path -Path $archiveBasePath -ChildPath $folderName
        
        # Create the archive directory if it doesn't exist
        if (-Not (Test-Path -Path $archiveDir)) {
            New-Item -ItemType Directory -Path $archiveDir | Out-Null
            Write-Output "$currentTimestamp Created directory: $archiveDir"
            $logContent += "[$currentTimestamp] Created directory: $archiveDir`n"
        }
        
        # Set the zip file name
		$zipFileName = "${folderName}_LOGS_${timestampArchive}.zip"
        $zipFile = Join-Path -Path $archiveDir -ChildPath $zipFileName
		Write-Output "$currentTimestamp Created archive: $zipFileName"
        $logContent += "[$currentTimestamp] Created directory: $zipFileName`n"
        
        # Create the zip archive
        $filesToCompress | Compress-Archive -DestinationPath $zipFile
        Write-Output "$currentTimestamp Compression completed for directory: $sourceDir"
        $logContent += "[$currentTimestamp] Compression completed for directory: $sourceDir`n"
        
        # Delete the original .log files
        foreach ($file in $filesToCompress) {
            Remove-Item -Path $file.FullName -Force
            Write-Output "$currentTimestamp Deleted file: $($file.FullName)"
            $logContent += "[$currentTimestamp] Deleted file: $($file.FullName)`n"
        }
    } else {
        Write-Output "$currentTimestamp No .log files older than 5 days found in directory: $sourceDir"
        $logContent += "[$currentTimestamp] No .log files older than 5 days found in directory: $sourceDir`n"
    }
}

# Write log content to log file
$logContent | Out-File -FilePath $logFile -Append -Encoding utf8

Write-Output "Logging completed."

# Call script for deleting old .zip files
& "$basePath\deleteZippedDeployLogsREF.ps1"
