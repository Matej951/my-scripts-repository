#!/bin/bash
# Define variables
services=("certis-gateway-cm" "certis-gateway-bp" "certis-gateway-ip")
homeFolder=/home/ext_mcihlar@creditas.cz/release
deployFolder=/opt/certis-gateway
bpFolder=$deployFolder/bp
cmFolder=$deployFolder/cm
ipFolder=$deployFolder/ip

# Check if there are any files in the homeFolder
if [ -z "$(ls -A $homeFolder)" ]; then
    echo "No files found in $homeFolder. Exiting."
    exit 1
fi

# Stop the services
for service in "${services[@]}"; do
    systemctl stop ${service}.service
done

# Validate the services have stopped
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service.service; then
        echo "$service.service is still running. Exiting."
        exit 1
    else
        echo "$service.service has been stopped."
    fi
done

# Determine which patterns to look for in homeFolder
patterns=("bp" "cm" "ip")
declare -A filesToRename
for pattern in "${patterns[@]}"; do
    # Check for files matching the pattern in the homeFolder
    if ls $homeFolder/*$pattern*-service-*.jar 1> /dev/null 2>&1; then
        filesToRename[$pattern]="true"
    else
        filesToRename[$pattern]="false"
    fi
done

# Process the files in the deployment folders
folders=("bp" "cm" "ip")
for folder in "${folders[@]}"; do
    # Check if files need to be renamed based on the patterns found
    if [ "${filesToRename[$folder]}" == "true" ]; then
        echo "Processing $folder folder."

        # Delete any existing _old files
        for old_file in $deployFolder/$folder/*_old.jar; do
            if [ -f "$old_file" ]; then
                rm "$old_file"
                echo "Deleted old file $old_file"
            fi
        done

        # Rename current files to *_old.jar
        for file in $deployFolder/$folder/certis-*-service-*.jar; do
            if [ -f "$file" ]; then
                mv "$file" "${file%.jar}_old.jar"
                echo "Renamed $file to ${file%.jar}_old.jar"
            fi
        done
    else
        echo "No matching files found in $homeFolder for pattern $folder. Skipping renaming."
    fi
done

# Move new files to respective folders
for file in $homeFolder/certis-*-service-*.jar; do
    if [ -e "$file" ]; then
        if [[ $file == *bp* ]]; then
            mv "$file" $bpFolder/
            echo "Moved $file to $bpFolder/"
        elif [[ $file == *cm* ]]; then
            mv "$file" $cmFolder/
            echo "Moved $file to $cmFolder/"
        elif [[ $file == *ip* ]]; then
            mv "$file" $ipFolder/
            echo "Moved $file to $ipFolder/"
        else
            echo "No matching folder found for $file."
        fi
    else
        echo "No files found in $homeFolder matching pattern."
    fi
done

# Start the services
for service in "${services[@]}"; do
    systemctl start ${service}.service
done

# Validate the services are running
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service.service; then
        echo "$service.service is running."
    else
        echo "$service.service failed to start. Exiting."
        exit 1
    fi
done

echo "All tasks completed successfully."
