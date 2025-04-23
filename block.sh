#!/bin/bash

# Renkler
RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

# ASCII Logo
clear
echo -e "${RED}"
echo "██╗  ██╗██╗  ██╗"
echo "██║ ██╔╝██║ ██╔╝"
echo "█████╔╝ █████╔╝ "
echo "██╔═██╗ ██╔═██╗ "
echo "██║  ██╗██║  ██╗"
echo "╚═╝  ╚═╝╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "${GREEN}Hostingkirala script başlatılıyor...${NC}"

# Loading
for i in {1..3}; do
    echo -n "."
    sleep 0.5
done
echo -e "\n"

# AS numarası al
read -p "Engellemek istediğiniz AS numarasını girin (örn: AS60068): " ASN

if [[ ! "$ASN" =~ ^AS[0-9]+$ ]]; then
    echo "[!] Geçersiz AS numarası formatı. Örnek format: AS60068"
    exit 1
fi

WHOIS_SERVER="whois.radb.net"

echo "[+] $ASN IPv4 blokları alınıyor..."
IPV4_BLOCKS=$(whois -h $WHOIS_SERVER -- "-i origin $ASN" | grep '^route:' | awk '{print $2}' | sort -u)

echo "[+] $ASN IPv6 blokları alınıyor..."
IPV6_BLOCKS=$(whois -h $WHOIS_SERVER -- "-i origin $ASN" | grep '^route6:' | awk '{print $2}' | sort -u)

if [[ -z "$IPV4_BLOCKS" && -z "$IPV6_BLOCKS" ]]; then
    echo "[!] Hiçbir IP bloğu bulunamadı. Çıkılıyor."
    exit 1
fi

# IPv4 blokları engelle
if [ -n "$IPV4_BLOCKS" ]; then
    echo -e "\n${GREEN}[+] IPv4 blokları engelleniyor...${NC}"
    for block in $IPV4_BLOCKS; do
        echo "  -> $block"
        sudo iptables -A INPUT -s $block -j DROP
        sudo iptables -A OUTPUT -d $block -j DROP
    done
fi

# IPv6 blokları engelle
if [ -n "$IPV6_BLOCKS" ]; then
    echo -e "\n${GREEN}[+] IPv6 blokları engelleniyor...${NC}"
    for block in $IPV6_BLOCKS; do
        echo "  -> $block"
        sudo ip6tables -A INPUT -s $block -j DROP
        sudo ip6tables -A OUTPUT -d $block -j DROP
    done
fi

# Kalıcı yap
echo -e "\n[+] Kurallar kalıcı hale getiriliyor..."
sudo netfilter-persistent save

echo -e "\n${GREEN}[✓] $ASN IP blokları (IPv4 + IPv6) başarıyla engellendi.${NC}"
