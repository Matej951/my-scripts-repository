#!/bin/bash

# Get the current user
CURRENT_USER=$(whoami)

# Define directories
WEBOFFICE_OLD_DIR=""
WEBOFFICE_OLD_REP_TEMPLATES=""
PREPARED_TEMPLATES_DIR=""
CURRENT_TEMPLATES_DIR=""
NEW_TEMPLATES_DIR=""
BACKUP_DIR=""
LOG_DIR=""
LOG_FILE=""
CLEANUP_PREPARED_DIR=${CLEANUP_PREPARED_DIR:-true}  # Default to true, can be overridden

# Function for logging
echo_log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Start logging
echo_log "Script execution started by user $CURRENT_USER."

# Ensure LOG_DIR exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Creating log directory $LOG_DIR."
    mkdir -p "$LOG_DIR"
else
    echo_log "Directory $LOG_DIR already exists."
fi

echo "#########################################################" | tee -a "$LOG_FILE"
echo "############ THIS SCRIPT MUST BE RUN AS ROOT ############" | tee -a "$LOG_FILE"
echo "#########################################################" | tee -a "$LOG_FILE"

# Ensure the script is run as root
if [ "$CURRENT_USER" != "root" ]; then
    echo "Error: This script must be run as root. Exiting."
    exit 1
fi

# Check if WEBOFFICE_OLD_REP_TEMPLATES exists
if [ ! -d "$WEBOFFICE_OLD_REP_TEMPLATES" ]; then
    echo_log "Error: Directory $WEBOFFICE_OLD_REP_TEMPLATES does not exist. You must do the back up first. Exiting."
    exit 1
fi

echo_log "Directory $WEBOFFICE_OLD_REP_TEMPLATES exists."

# Check if CURRENT_TEMPLATES_DIR exists
if [ ! -d "$CURRENT_TEMPLATES_DIR" ]; then
    echo_log "Error: Directory $CURRENT_TEMPLATES_DIR does not exist. You must copy new WebOffice folder first. Exiting."
    exit 1
fi

echo_log "Directory $CURRENT_TEMPLATES_DIR exists."

# Ensure PREPARED_TEMPLATES_DIR exists
if [ ! -d "$PREPARED_TEMPLATES_DIR" ]; then
    echo_log "Creating directory $PREPARED_TEMPLATES_DIR."
    mkdir -p "$PREPARED_TEMPLATES_DIR"
else
    echo_log "Directory $PREPARED_TEMPLATES_DIR already exists."
fi

# Copy RepTemplates to PREPARED_TEMPLATES_DIR
echo_log "Copying RepTemplates from $WEBOFFICE_OLD_DIR/data/merreports/RepTemplates to $PREPARED_TEMPLATES_DIR."
#cp -r "$WEBOFFICE_OLD_DIR/data/merreports/RepTemplates/"* "$PREPARED_TEMPLATES_DIR"
cp -r "$WEBOFFICE_OLD_REP_TEMPLATES/"* "$PREPARED_TEMPLATES_DIR"

echo_log "RepTemplates copied to $PREPARED_TEMPLATES_DIR."

# Rename existing CURRENT_TEMPLATES_DIR to BACKUP_DIR
if [ -d "$CURRENT_TEMPLATES_DIR" ]; then
    echo_log "Renaming $CURRENT_TEMPLATES_DIR to $BACKUP_DIR."
    mv "$CURRENT_TEMPLATES_DIR" "$BACKUP_DIR" || {
        echo_log "Failed to rename $CURRENT_TEMPLATES_DIR to $BACKUP_DIR. Exiting."
        exit 1
    }
    echo_log "Renamed $CURRENT_TEMPLATES_DIR to $BACKUP_DIR."
else
    echo_log "$CURRENT_TEMPLATES_DIR does not exist. Exiting."
    exit 1
fi

# Copy content from PREPARED_TEMPLATES_DIR to NEW_TEMPLATES_DIR
echo_log "Copying content from $PREPARED_TEMPLATES_DIR to $NEW_TEMPLATES_DIR."
mkdir -p "$NEW_TEMPLATES_DIR"
cp -r "$PREPARED_TEMPLATES_DIR/"* "$NEW_TEMPLATES_DIR"

echo_log "Content copied to $CURRENT_TEMPLATES_DIR."

# Check and set permissions and ownership
OWNER="root:apache"
PERMISSIONS="775"

echo_log "Setting ownership to $OWNER and permissions to $PERMISSIONS for $CURRENT_TEMPLATES_DIR."

# Update permissions and ownership for CURRENT_TEMPLATES_DIR
chown -R $OWNER "$CURRENT_TEMPLATES_DIR"
chmod -R $PERMISSIONS "$CURRENT_TEMPLATES_DIR"

echo_log "Ownership and permissions updated for $CURRENT_TEMPLATES_DIR."

# Validate permissions and ownership
INVALID_FILES=$(find "$CURRENT_TEMPLATES_DIR" \! -user "root" -o \! -group "apache" -o \! -perm $PERMISSIONS)
if [ -n "$INVALID_FILES" ]; then
    echo_log "Error: Some files in $CURRENT_TEMPLATES_DIR have incorrect permissions or ownership."
    exit 1
else
    echo_log "Permissions and ownership for $CURRENT_TEMPLATES_DIR are correctly set."
fi

# Optional cleanup of prepared directory, change boolean at the beginning
if  [ "$CLEANUP_PREPARED_DIR" = true ]; then
    echo_log "Cleaning up prepared directory $PREPARED_TEMPLATES_DIR"
    rm -rf "$PREPARED_TEMPLATES_DIR"
    echo_log "Prepared directory cleaned up."
fi

echo_log "Script execution completed successfully."

exit 0