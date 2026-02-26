#!/bin/bash
# TELNET-FIND: Legacy Protocol Discovery
OUTPUT_FILE="telnet_found.txt"
scan_ip() {
    local ip="$1"
    if ping -c 1 -W 1 "$ip" &>/dev/null; then
        nmap -sT -Pn -n -p 23 --open -oG - "$ip" 2>/dev/null | grep "/open/" && \
        echo "[+] Telnet Open: $ip" | tee -a "$OUTPUT_FILE"
    fi
}
trap "wait; exit" INT TERM
while true; do
    ip="$((RANDOM%254+1)).$((RANDOM%254+1)).$((RANDOM%254+1)).$((RANDOM%254+1))"
    scan_ip "$ip" &
    sleep 0.01
done
