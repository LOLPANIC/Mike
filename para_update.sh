#!/bin/bash

# para_update.sh

# Variables
TARGET_DIR="/root/ceremonyclient/node"
NODE_RELEASE_URL="https://releases.quilibrium.com"
RELEASE_LIST_URL="https://releases.quilibrium.com/release"
QCLIENT_RELEASE_URL="https://releases.quilibrium.com/qclient-release"
SERVICE_FILE="/etc/systemd/system/para.service"

# Fetch available node files
fetch_node_files() {
    curl -s $RELEASE_LIST_URL | grep 'linux-amd64' | grep -E '^(node-.*-linux-amd64$|node-.*-linux-amd64\.dgst$|node-.*-linux-amd64\.dgst\.sig\.[0-9]+$)'
}

# Fetch available qclient files
fetch_qclient_files() {
    curl -s $QCLIENT_RELEASE_URL | grep 'linux-amd64' | grep -E '^(qclient-.*-linux-amd64$|qclient-.*-linux-amd64\.dgst$|qclient-.*-linux-amd64\.dgst\.sig\.[0-9]+$)'
}

# Download new file if not exists
download_and_prepare_file() {
    local file_name=$1
    local file_url="$NODE_RELEASE_URL/$file_name"

    if [[ ! -f "$TARGET_DIR/$file_name" ]]; then
        echo "Downloading new file: $file_name"
        wget -q "$file_url" -O "$TARGET_DIR/$file_name"
        if [[ "$file_name" == node-*linux-amd64 || "$file_name" == qclient-*linux-amd64 ]]; then
            chmod +x "$TARGET_DIR/$file_name"  # Ensure the main binary is executable
        fi
    else
        echo "$file_name already exists, skipping download."
    fi
}

# Update the para.service file
update_service_file() {
    local new_version=$1

    echo "Updating para.service to version $new_version..."
    sed -i "s/\(ExecStart=.*para\.sh .*\) [0-9]\+\.[0-9]\+\.[0-9]\+\(\.[0-9]\+\)\?/\1 $new_version/" "$SERVICE_FILE"
    systemctl daemon-reload
    systemctl restart para.service
    echo "para.service updated and restarted."
}

# Main logic
main() {
    echo "Checking for Node updates..."

    cd "$TARGET_DIR" || { echo "Target directory $TARGET_DIR does not exist."; exit 1; }

    local node_files=$(fetch_node_files)
    if [[ ! -z "$node_files" ]]; then
        # Download all necessary Node files
        for file in $node_files; do
            download_and_prepare_file $file
        done

        # Determine the latest Node version
        local latest_version=$(echo "$node_files" | grep -oP '(?<=node-)[0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?' | sort -V | tail -n 1)

        # Extract current version from the service file
        local current_version=$(grep -oP '(?<=ExecStart=.*para\.sh .* )[0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?' "$SERVICE_FILE")

        if [[ "$latest_version" != "$current_version" ]]; then
            echo "New Node version found: $latest_version (current: $current_version)"
            update_service_file "$latest_version"
        else
            echo "No Node update required. Current version: $current_version."
        fi
    else
        echo "No new Node files found."
    fi

    echo "Checking for Qclient updates..."

    local qclient_files=$(fetch_qclient_files)
    if [[ ! -z "$qclient_files" ]]; then
        # Download all necessary Qclient files
        for file in $qclient_files; do
            download_and_prepare_file $file
        done

        echo "Qclient files updated."
    else
        echo "No new Qclient files found."
    fi
}

main
