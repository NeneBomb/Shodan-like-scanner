🌐 Network Discovery & Enumeration Suite

Un conjunto de herramientas en Bash diseñadas para la exploración y auditoría de redes mediante la generación aleatoria de objetivos IPv4.

Estas herramientas aprovechan que la gran mayoría del espacio de direcciones IPv4 está asignado y en uso. Estadísticamente, al generar direcciones aleatorias, existe una alta probabilidad de encontrar hosts activos, incluso si estos no responden a paquetes ICMP (ping) debido a configuraciones de firewall.
🛠 Herramientas incluidas:

    ipfind.sh: Motor de descubrimiento general. Utiliza pings rápidos seguidos de escaneos agresivos con Nmap para identificar hosts activos y servicios detallados.

    webfind2.sh: Escáner multihilo especializado en activos web. Identifica puertos HTTP/S comunes y verifica el estado de respuesta (200 OK, etc.) en tiempo real.

    printerfind.sh: Herramienta de auditoría IoT enfocada en protocolos de impresión (JetDirect, IPP, LPD).

    telnetfind2.sh: Escáner de protocolos legacy para detectar servicios Telnet abiertos en dispositivos antiguos.

🌍 English Version: Shodan-style IP Scanner

This suite is a collection of Bash-based tools designed for network reconnaissance and auditing. By generating random IPv4 addresses, the tools attempt to discover live hosts and open services across the internet.
Key Features:

    Efficient Discovery: Targets the vast public IPv4 space where most addresses are active.

    Service-Specific Scanning: Dedicated scripts for Web (HTTP/S), Printing protocols (IoT), and Legacy services (Telnet).

    Nmap Integration: Leverages the power of Nmap for deep packet inspection and service versioning.

⚠️ Disclaimer / Aviso Legal

Este proyecto ha sido desarrollado exclusivamente con fines educativos y de seguridad ética. El autor no se hace responsable del mal uso de estas herramientas. Realizar escaneos sobre redes sin autorización previa puede tener implicaciones legales.

This project was developed for educational and ethical security purposes only. The author is not responsible for any misuse. Unauthorized network scanning may be illegal in your jurisdiction.
🚀 Uso / Usage
Bash

chmod +x *.sh
# El escaneo de red suele requerir privilegios de root para paquetes RAW
sudo ./ipfind.sh
