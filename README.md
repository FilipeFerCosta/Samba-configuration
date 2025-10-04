# 🖥️ Samba 4 Domain Controller Setup (Debian)

This repository provides **ready-to-use scripts** to configure **Samba 4 Active Directory Domain Controllers** on a **Debian-based system**, including:

- Primary DC setup
- Additional DC for **GPO replication and redundancy**
- Optional file server integration

> ⚠️ **Security warning:** Never commit private keys or secrets to this repository. All `.ssh` or credential files should be ignored with `.gitignore`.

---

## 📋 Requirements

- Debian 11 or higher (Ubuntu Server also works)  
- Static IP address configured  
- Internet connection for package installation  
- Access to an existing primary DC if configuring an additional DC  

---

## ⚙️ Overview

These scripts automate the setup of **Samba 4 as an Active Directory Domain Controller (AD DC)**.

There are two scripts in this repository:

| Script | Purpose |
|--------|---------|
| `install_samba_dc_debian.sh` | Sets up a **primary DC** with a new domain |
| `install_samba_gpo_debian.sh` | Sets up an **additional DC** for **GPO replication / redundancy** |

**Before running the scripts**, update:

1. IP addresses for each server
2. Hostnames
3. Domain name

---

## 🚀 How to Use

### 1️⃣ Download or create the script file

Copy the content of the script or download it directly:

```bash
nano install_samba_dc_debian.sh
nano install_samba_gpo_debian.sh
```

Paste the full content of the script, then save and close.

---

### 2️⃣ Make the script executable

```bash
chmod +x install_samba_dc_debian.sh
chmod +x install_samba_gpo_debian.sh
```

---

### 3️⃣ Run the script with sudo privileges

- **Primary DC**:

```bash
sudo ./install_samba_dc_debian.sh
```

- **Additional DC / GPO redundancy**:

```bash
sudo ./install_samba_gpo_debian.sh
```

---

## 🔐 Important Notes

- **Private keys** (`.ssh/id_rsa`) must **never be committed** to the repository. Add `.ssh/` to `.gitignore`.  
- If a secret was accidentally committed, **purge it from Git history** using `git filter-repo` before pushing.  
- After provisioning an additional DC, **verify replication** and that **GPOs are synchronized** from the primary DC.  

---
