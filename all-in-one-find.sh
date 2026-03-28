#!/bin/bash

# --- CONFIGURACIÓN ---
# Puertos: FTP(21), SSH(22), TELNET(23), SMB(445), RDP(3389), MYSQL(3306), POSTGRES(5432), MONGODB(27017)
TARGET_PORTS="21,22,23,445,3389,3306,5432,27017"
LOG_FILE="scan_results.log"
CONF_FILE="paused.conf"
RATE=10000

# --- FUNCIÓN DE ANÁLISIS DE VULNERABILIDADES ---
check_vuln() {
    local ip=$1
    local port=$2
    
    # Evitar re-analizar si el host parece un honeypot (puerto 666 abierto suele ser trampa)
    if nmap -p 666 --open -Pn --host-timeout 800ms $ip | grep -q "open"; then
        return
    fi

    case $port in
        21) # FTP - Verificación de acceso anónimo
            nmap -p 21 --script ftp-anon -Pn $ip | grep -q "Allowed" && \
            echo "[VULN][FTP] Anonymous access enabled: $ip" >> $LOG_FILE ;;
        
        22) # SSH - Captura de Banner
            BANNER=$(timeout 3 nc -v -w 3 $ip 22 2>&1 | grep "SSH-")
            [ ! -z "$BANNER" ] && echo "[INFO][SSH] Banner ($ip): $BANNER" >> $LOG_FILE ;;
        
        23) # TELNET - Verificación de acceso sin clave (más estricta)
            OUT=$( (echo " "; sleep 2) | timeout 4 telnet $ip 23 2>&1 )
            if ! echo "$OUT" | grep -qiE "Login|Password|User|Acceso|Autenticaci"; then
                if echo "$OUT" | grep -qiE "Welcome|#|>|$"; then
                    echo "[VULN][TELNET] No authentication required: $ip" >> $LOG_FILE
                fi
            fi ;;
        
        445) # SMB - Carpetas compartidas sin clave
            nmap -p 445 --script smb-enum-shares -Pn $ip | grep -qE "Anonymous|Guest" && \
            echo "[VULN][SMB] Guest access enabled: $ip" >> $LOG_FILE ;;
        
        3389) # RDP - Información del sistema Windows
            OS_INFO=$(nmap -p 3389 --script rdp-ntlm-info -Pn $ip | grep "Target_Name" | cut -d: -f2)
            [ ! -z "$OS_INFO" ] && echo "[INFO][RDP] Windows Target ($ip): $OS_INFO" >> $LOG_FILE ;;

        3306) # MYSQL - Acceso root sin password
            nmap -p 3306 --script mysql-empty-password -Pn $ip | grep -q "root" && \
            echo "[VULN][MYSQL] No password for root: $ip" >> $LOG_FILE ;;

        5432) # POSTGRES - Acceso abierto
            nmap -p 5432 --script pgsql-brute --script-args userdb=/dev/null -Pn $ip | grep -q "Success" && \
            echo "[VULN][POSTGRES] Open access: $ip" >> $LOG_FILE ;;

        27017) # MONGODB - Bases de datos expuestas
            nmap -p 27017 --script mongodb-databases -Pn $ip | grep -q "Ok" && \
            echo "[VULN][MONGODB] No authentication required: $ip" >> $LOG_FILE ;;
    esac
}

# --- INICIO DEL PROGRAMA ---
echo "[*] Shodan-Script Pro iniciado."
echo "[*] Puertos: $TARGET_PORTS | Velocidad: $RATE pps"
echo "[*] Guardando resultados en: $LOG_FILE"

# Comprobar si hay una sesión previa para resumir
if [ -f "$CONF_FILE" ]; then
    echo "[+] Resumiendo sesión anterior..."
    SCAN_CMD="sudo stdbuf -oL masscan --resume $CONF_FILE --rate $RATE -oL -"
else
    echo "[+] Iniciando nuevo escaneo global..."
    SCAN_CMD="sudo stdbuf -oL masscan 0.0.0.0/0 -p$TARGET_PORTS,666 --rate $RATE --exclude 255.255.255.255 -oL -"
fi

# Ejecutar Masscan y pasar resultados a la función de vulnerabilidades
$SCAN_CMD 2>/dev/null | grep -a -v "^#" | while read -r status proto port ip time; do
    if [ "$status" == "open" ]; then
        # Ignorar puerto 666 (marcador de trampa)
        [ "$port" == "666" ] && continue
        
        echo "[+] Detectado puerto $port abierto en $ip. Analizando..."
        check_vuln $ip $port &
    fi
done
