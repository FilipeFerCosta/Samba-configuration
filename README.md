# 🖥️ Samba 4 Domain Controller Setup (Debian)

This repository provides a **ready-to-use script** to configure a Samba 4 Domain Controller, GPO and file server on a **Debian-based system**.
The configuration it is still being built.

---

## 📋 Requirements

- Debian 11 or higher (Ubuntu Server also works)
- Static IP address configured
- Internet connection for package installation

---

## ⚙️ Overview

This script automates the setup of **Samba 4 as an Active Directory Domain Controller (DC)**.

You only need to:
1. Adjust your **IP address**
2. Set your **domain name**

---

## 🚀 How to Use

### 1️⃣ Download or create the script file

Either copy the content of the script manually or download it directly:

```bash
nano install_samba_dc_debian.sh
```

Paste the full content of the script, then save and close.

### 2️⃣ Make it executable

```bash
chmod +x install_samba_dc_debian.sh
```

### 3️⃣ Run the script with sudo privileges

```bash
sudo ./install_samba_dc_debian.sh
```
