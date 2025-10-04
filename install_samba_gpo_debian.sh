#!/bin/bash
# ============================================================
# Samba 4 Active Directory Domain Controller Installer
# Production-ready for Debian 11/12
# Domain: samba.local.techlabhub.com
# Hostname: ad02
# IP: 10.0.0.72
# Gateway: 10.0.0.1
# ============================================================
# Variables

IP="10.0.0.72"
GATEWAY="10.0.0.1"
HOSTNAME="ad02"
DOMAIN="samba.local.techlabhub.com"
MAIN_DC="ad01.$DOMAIN"
NETBIOS="SAMBA"
ADMIN_PASS="YourAdminPasswordHere"

# ===============================
# 1️⃣ Set Hostname and Hosts file
# ===============================
echo "[1/10] Setting hostname and /etc/hosts..."
sudo hostnamectl set-hostname $HOSTNAME

sudo bash -c "cat > /etc/hosts <<EOF
127.0.0.1       localhost
$IP $HOSTNAME.$DOMAIN $HOSTNAME
$MAIN_DC
EOF"

# ===============================
# 2️⃣ Configure Network Interface
# ===============================
echo "[2/10] Configuring network interface..."
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
    dns-nameservers 127.0.0.1 $MAIN_DC
    dns-search $DOMAIN
EOF"

# ===============================
# 3️⃣ Update System and Install Packages
# ===============================
echo "[3/10] Updating system and installing packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install samba winbind krb5-user dnsutils acl attr libpam-winbind libnss-winbind -y

# ===============================
# 4️⃣ Stop old Samba services
# ===============================
echo "[4/10] Stopping any old Samba services..."
sudo systemctl stop samba-ad-dc.service smb.service nmbd.service winbind.service
sudo systemctl disable samba-ad-dc.service smb.service nmbd.service winbind.service

# ===============================
# 5️⃣ Join existing domain as Additional DC
# ===============================
echo "[5/10] Joining domain as Additional Domain Controller..."
sudo samba-tool domain join $DOMAIN DC -U"Administrator@$DOMAIN" --realm=$DOMAIN --server=$MAIN_DC <<EOF
$ADMIN_PASS
EOF

# ===============================
# 6️⃣ Configure Kerberos
# ===============================
echo "[6/10] Configuring Kerberos..."
sudo mv /etc/krb5.conf /etc/krb5.conf.bkp
sudo ln -s /var/lib/samba/private/krb5.conf /etc/

# ===============================
# 7️⃣ Enable and start Samba
# ===============================
echo "[7/10] Starting Samba AD DC service..."
sudo systemctl unmask samba-ad-dc.service
sudo systemctl start samba-ad-dc.service
sudo systemctl enable samba-ad-dc.service
sudo systemctl status samba-ad-dc.service

# ===============================
# 8️⃣ Test replication and DNS
# ===============================
echo "[8/10] Testing replication and DNS..."
sudo samba-tool drs showrepl
ping -c 3 $MAIN_DC
host -t A $DOMAIN
host -t A $HOSTNAME.$DOMAIN
host -t SRV _ldap._tcp.$DOMAIN
host -t SRV _kerberos._udp.$DOMAIN

# ===============================
# 9️⃣ Test Kerberos authentication
# ===============================
echo "[9/10] Testing Kerberos authentication..."
kinit Administrator@$DOMAIN
klist

# ===============================
# 🔟 Finished
# ===============================
echo "✅ Additional Domain Controller for GPO / redundancy is ready!"
