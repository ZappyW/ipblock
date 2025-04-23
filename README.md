# Hostingkirala - ASN Bloklama Scripti

Bu proje, **Hostingkirala** için geliştirilen bir **ASN Bloklama** scriptidir. Belirli bir **Autonomous System Number (ASN)** ile ilişkilendirilmiş IP adreslerini engellemek için kullanılır. Script, hem IPv4 hem de IPv6 adresleri engellemeye destek verir.

## Özellikler

- **ASN Bloklama:** Belirtilen bir ASN için IPv4 ve IPv6 adres bloklarını engeller.
- **Engellemeyi Kaldırma:** Aynı ASN için daha önce yapılmış engellemeleri kaldırmak mümkündür.
- **Basit Kullanım:** Kolayca çalıştırılabilir ve net bir çıktı sağlar.
- **Kalıcı Kurallar:** Engellemeler `iptables` ve `ip6tables` ile yapılır ve kalıcı hale getirilir.

## Kurulum

### Prerequisites

Bu script'i çalıştırabilmek için aşağıdaki araçların kurulu olması gerekir:

- `iptables` (IPv4 engelleme için)
- `ip6tables` (IPv6 engelleme için)
- `whois` (ASN bilgilerini almak için)

### Adımlar

1. Projeyi klonlayın:
   ```bash
   git clone https://github.com/ZappyW/ipblock.git
   cd hostingkirala
