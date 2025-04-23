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

for i in {1..3}; do
    echo -n "."
    sleep 0.5
done
echo -e "\n"

# ASN al
read -p "Kaldırmak istediğiniz AS numarasını girin (örn: AS60068): " ASN

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

# IPv4 kuralları sil
if [ -n "$IPV4_BLOCKS" ]; then
    echo -e "\n${GREEN}[+] IPv4 engelleri kaldırılıyor...${NC}"
    for block in $IPV4_BLOCKS; do
        echo "  -> $block"
        sudo iptables -D INPUT -s $block -j DROP 2>/dev/null
        sudo iptables -D OUTPUT -d $block -j DROP 2>/dev/null
    done
fi

# IPv6 kuralları sil
if [ -n "$IPV6_BLOCKS" ]; then
    echo -e "\n${GREEN}[+] IPv6 engelleri kaldırılıyor...${NC}"
    for block in $IPV6_BLOCKS; do
        echo "  -> $block"
        sudo ip6tables -D INPUT -s $block -j DROP 2>/dev/null
        sudo ip6tables -D OUTPUT -d $block -j DROP 2>/dev/null
    done
fi

# Kalıcılaştır
echo -e "\n[+] Güncellenen kurallar kaydediliyor..."
sudo netfilter-persistent save

echo -e "\n${GREEN}[✓] $ASN IP blokları başarıyla kaldırıldı.${NC}"
