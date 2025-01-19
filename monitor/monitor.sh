#!/bin/bash
# Diyar Parwana
# Linux och Data Säkerhet 

# Script för att övervaka internetanslutning och återansluta vid behov.

while true; do
    # Rensa tidigare output
    clear

    # Kontrollera UFW-status
    echo "Kontrollerar UFW-status..."
    sudo ufw status

    # Kontrollera internetstatus
    if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
        echo "Internetanslutning är aktiv."
    else
        echo "Ingen internetanslutning. Försöker återansluta..."
        bash wifi.sh
    fi

    # Vänta i 5 sekunder innan nästa loop
    sleep 5
done
