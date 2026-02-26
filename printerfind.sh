#!/bin/bash
# PRINTER-FIND: IoT/Printer Discovery
OUTPUT_FILE="impresoras_encontradas.txt"
WEB_PORTS=(631 9100 515)
PORTS_TO_SCAN=$(IFS=, ; echo "${WEB_PORTS[*]}")
scan_ip() {
    local ip="$1"
    if ping -c 1 -W 1 "$ip" &>/dev/null; then
        nmap -Pn -n -T4 -p $PORTS_TO_SCAN --open -oG - "$ip" 2>/dev/null | grep "/open/" && \
        echo "Found potential printer at $ip" | tee -a "$OUTPUT_FILE"
    fi
}
trap "wait; exit" INT TERM
while true; do
    ip="$((RANDOM%254+1)).$((RANDOM%254+1)).$((RANDOM%254+1)).$((RANDOM%254+1))"
    scan_ip "$ip" &
    sleep 0.01
done
