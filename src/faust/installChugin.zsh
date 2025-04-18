#!/bin/zsh

# Specify the destination directory
DEST_DIR="/Library/Application Support/ChucK/chugins"

# Ensure the destination directory exists
mkdir -p "$DEST_DIR"

# Check if a file argument is supplied
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <file-to-copy>"
    exit 1
fi

# Get the filename from the argument
FILE_TO_COPY="$1chug"

# Check if the file exists
if [[ ! -f "$FILE_TO_COPY" ]]; then
    echo "Error: File '$FILE_TO_COPY' does not exist."
    exit 1
fi

# Copy the file to the destination directory
cp "$FILE_TO_COPY" "$DEST_DIR" && echo "File copied to $DEST_DIR"
