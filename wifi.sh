#!/bin/bash

# Wi-Fi-nätverk och lösenord
WIFI_SSIDS=("wifi1" "wifi2" "wifi3")
WIFI_PASSWORD="DemoPass"

# Kontrollera om 'nmcli' finns, installera om inte
if ! command -v nmcli &> /dev/null; then
    echo "'nmcli' saknas, installerar..."
    if sudo snap install network-manager; then
        echo "Installerat. Startar om..."
        sudo reboot
    else
        echo "Installationen misslyckades."
        exit 1
    fi
fi

# Anslut till Wi-Fi
connect_to_wifi() {
    local ssid="$1"
    echo "Ansluter till: $ssid"
    if nmcli connection show "$ssid" &> /dev/null; then
        nmcli connection up "$ssid"
    else
        nmcli dev wifi connect "$ssid" password "$WIFI_PASSWORD"
    fi
    [ $? -eq 0 ] && echo "Ansluten!" && exit 0 || echo "Misslyckades!"
}

# Kontrollera internetanslutning
check_internet() {
    ping -c 1 -W 2 8.8.8.8 &> /dev/null
    return $?
}

# Kolla om internet redan finns
if check_internet; then
    echo "Internet aktivt."
    exit 0
fi

# Skanna nätverk och anslut
echo "Söker Wi-Fi..."
AVAILABLE_NETWORKS=$(nmcli -t -f SSID dev wifi | sort -u)

for ssid in "${WIFI_SSIDS[@]}"; do
    echo "$AVAILABLE_NETWORKS" | grep -qw "$ssid" && connect_to_wifi "$ssid"
done

echo "Inga kända nätverk hittades."
exit 1
