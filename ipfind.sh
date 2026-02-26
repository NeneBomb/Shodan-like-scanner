#!/bin/bash
# IPFIND - Random Host Discovery
# Disclaimer: Educational and ethical use only.
echo "--- Iniciando búsqueda de hosts activos (Random Mode) ---"
while true; do
    ip="$(( RANDOM % 254 + 1 )).$(( RANDOM % 254 + 1 )).$(( RANDOM % 254 + 1 )).$(( RANDOM % 254 + 1 ))"
    if ping -c 1 -W 1 $ip &> /dev/null; then
        echo -e "\n[+] Host activo: $ip"
        nmap -vvv -sV -sC -sS -Pn -n -A --top-ports 1000 -T4 $ip 2>&1 | tee /dev/tty | grep -qE '^[0-9]+/tcp\s+open'
    else
        echo "No responde: $ip"
    fi
done
