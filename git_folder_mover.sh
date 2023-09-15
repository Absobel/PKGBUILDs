#!/bin/bash

# Check for arguments
if [[ "$#" -ne 3 ]]; then
    echo "Usage: $0 <forward|reverse> <source_folder> <destination_folder>"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (sudo). Exiting."
    exit 1
fi

operation="$1"
src_folder=$(realpath "$2")
dest_folder=$(realpath "$3")
backup_folder="$dest_folder/$(basename $src_folder).backup"

# Backup src_folder to tmp
cp -r "$src_folder" "$HOME/tmp"
mv "$HOME/tmp/$(basename $src_folder)" "$HOME/tmp/$(basename $src_folder).tmp"

if [[ "$operation" == "forward" ]]; then
    # Create backup_folder
    mkdir -p "$backup_folder"
    # Move .git directories from src_folder's subdirectories to backup_folder
    fd -H -t d -d 1 -x bash -c '[ -d "$0/.git" ] && mkdir -p "'"$backup_folder"'/$0" && mv "$0/.git" "'"$backup_folder"'/$0/"' -- "$src_folder"
elif [[ "$operation" == "reverse" ]]; then
    # Move .git directories from backup_folder's subdirectories back to src_folder
    fd -H -t d -d 1 -x bash -c '[ -d "'"$backup_folder"'/$0/.git" ] && mv "'"$backup_folder"'/$0/.git" "$0/" && rmdir "'"$backup_folder"'/$0"' -- "$src_folder"
else
    echo "Invalid operation. Use 'forward' or 'reverse'."
    exit 1
fi

echo "Operation '$operation' completed."

