#!/bin/bash
# ============================================================
# Samba 4 Active Directory Domain Controller Installer
# Production-ready for Debian 11/12
# Domain: samba.local.techlabhub.com
# Hostname: ad01
# IP: 10.0.0.73
# Gateway: 10.0.0.1
# ============================================================
# Variables
IP="10.0.0.73"
GATEWAY="10.0.0.1"
HOSTNAME="ad01"
DOMAIN="samba.local.techlabhub.com"
NETBIOS="SAMBA"

# ===============================
# 1️⃣ Set Hostname and Hosts file
# ===============================
echo "[1/12] Setting hostname and /etc/hosts..."
sudo hostnamectl set-hostname $HOSTNAME

sudo bash -c "cat > /etc/hosts <<EOF
127.0.0.1       localhost
$IP $HOSTNAME.$DOMAIN $HOSTNAME
EOF"

# ===============================
# 2️⃣ Configure Network Interface
# ===============================
echo "[2/12] Configuring network interface..."
sudo bash -c "cat > /etc/network/interfaces <<EOF
# Loopback interface
auto lo
iface lo inet loopback

# Static network interface
auto enp0s3
iface enp0s3 inet static
    address $IP
    netmask 255.255.255.0
    gateway $GATEWAY
    dns-nameservers 127.0.0.1 8.8.8.8
    dns-search $DOMAIN
EOF"

# ===============================
# 3️⃣ Configure /etc/resolv.conf
# ===============================
echo "[3/12] Configuring resolv.conf..."
sudo bash -c "cat > /etc/resolv.conf <<EOF
nameserver $IP
nameserver $GATEWAY
search $DOMAIN
domain $DOMAIN
EOF"

# ===============================
# 4️⃣ Update System
# ===============================
echo "[4/12] Updating system..."
sudo apt update && sudo apt upgrade -y

# ===============================
# 5️⃣ Install Required Packages
# ===============================
echo "[5/12] Installing required packages..."
sudo apt install samba winbind krb5-user dnsutils acl attr libpam-winbind libnss-winbind -y

# ===============================
# 6️⃣ Stop/Disable old services
# ===============================
echo "[6/12] Stopping and disabling old services..."
sudo systemctl stop samba-ad-dc.service smb.service nmbd.service winbind.service
sudo systemctl disable samba-ad-dc.service smb.service nmbd.service winbind.service

# ===============================
# 7️⃣ Backup smb.conf
# ===============================
echo "[7/12] Backing up smb.conf..."
sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bak

# ===============================
# 8️⃣ Provision the Domain
# ===============================
echo "[8/12] Provisioning Samba AD DC domain..."
sudo samba-tool domain provision --use-rfc2307 --interactive <<EOF
$DOMAIN
$NETBIOS
$GATEWAY
EOF

# ===============================
# 9️⃣ Configure Kerberos
# ===============================
echo "[9/12] Configuring Kerberos..."
sudo mv /etc/krb5.conf /etc/krb5.conf.bkp
sudo ln -s /var/lib/samba/private/krb5.conf /etc/

# ===============================
# 🔟 Enable and Start Samba Service
# ===============================
echo "[10/12] Enabling and starting Samba AD DC service..."
sudo systemctl unmask samba-ad-dc.service
sudo systemctl start samba-ad-dc.service
sudo systemctl enable samba-ad-dc.service
sudo systemctl status samba-ad-dc.service

# ===============================
# 1️⃣1️⃣ Connectivity and DNS tests
# ===============================
echo "[11/12] Testing connectivity and DNS resolution..."
ping -c 3 $DOMAIN
ping -c 3 $HOSTNAME.$DOMAIN
ping -c 3 $HOSTNAME

host -t A $DOMAIN
host -t A $HOSTNAME.$DOMAIN
host -t SRV _kerberos._udp.$DOMAIN
host -t SRV _ldap._tcp.$DOMAIN

sudo samba-tool domain level show

# ===============================
# 1️⃣2️⃣ Kerberos Authentication Test
# ===============================
echo "[12/12] Testing Kerberos authentication..."
kinit Administrator@$DOMAIN
klist

echo "✅ Provisioning completed!"
