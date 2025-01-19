#!/bin/bash

# Lista på SSDIDS
WIFI_SSIDS=("silviaWIFI" "liviaWIFI" "liamWIFI")
WIFI_PASSWORD="DemoPass"

# Check if nmcli is installed
if ! command -v nmcli &> /dev/null; then
    echo "nmcli hittas inte."
    exit 1
fi

# Funtion för att ansluta till wifi
connect_to_wifi() {
    local ssid=$1
    echo "Trying to connect to Wi-Fi network: $ssid"

    # Check if the connection profile already exists
    if nmcli connection show "$ssid" &> /dev/null; then
        echo "Found existing profile for $ssid. Activating connection..."
        nmcli connection up "$ssid"
    else
        echo "No profile found for $ssid. Creating and connecting..."
        nmcli dev wifi connect "$ssid" password "$WIFI_PASSWORD"
    fi

    # Kontrollera om anslutning lyckas
    if [ $? -eq 0 ]; then
        echo "Successfully connected to $ssid."
        exit 0
    else
        echo "Failed to connect to $ssid."
    fi
}

# Check for internet connection
check_internet() {
    ping -c 1 -W 2 8.8.8.8 &> /dev/null
    return $?
}

# Verify internet connection
if check_internet; then
    echo "Internet is already connected."
    exit 0
fi

# Scan for available Wi-Fi networks
echo "Scanning for available Wi-Fi networks..."
AVAILABLE_NETWORKS=$(nmcli -t -f SSID dev wifi | sort -u)

# Attempt to connect to one of the predefined SSIDs
for ssid in "${WIFI_SSIDS[@]}"; do
    if echo "$AVAILABLE_NETWORKS" | grep -q "$ssid"; then
        connect_to_wifi "$ssid"
    fi
done

# If no predefined SSID is found
echo "No predefined Wi-Fi networks found."
exit 1
