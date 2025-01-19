#!/bin/bash
# Diyar Parwana
# Linux och Data säkerhet

# Script to monitor internet connectivity and reconnect if needed.

while true; do
    # Kontrollera UFW status
    echo "Checking UFW status..."
    sudo ufw status

    # Kontrollera Internet status
    if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
        echo "Internet is working."
    else
        echo "No internet connection. Attempting to reconnect..."
        bash wifi.sh
    fi

    # Köra skriptet igen om 5 skunder
    sleep 5
done

