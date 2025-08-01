# 📦 Passbolt CE Backup and Restore Guide (v5.3)

This document outlines the **backup** and **restore** procedures for a Passbolt CE v5.3 instance running on Ubuntu with MySQL and NGINX on the same server.

---

## 🧩 Components to Backup

- ✅ MySQL database (`passbolt`)
- ✅ Passbolt configuration file (`/etc/passbolt/passbolt.php`)
- ✅ GPG keyring (`/var/lib/gnupg`)
- ✅ (Optional) NGINX configuration
- ✅ (Optional) Let's Encrypt certificates

---

## 🛡️ Backup Procedure

### 1. Create Backup Directory
```bash
sudo mkdir -p /opt/backups
```

### 2. Backup MySQL Database
```bash
sudo mysqldump -u root -p passbolt > /opt/backups/passbolt_db_$(date +%F).sql
```

> Replace `passbolt` with your actual database name if different.

### 3. Backup Passbolt Configuration
```bash
sudo mkdir -p /opt/backups/passbolt_files_$(date +%F)
sudo cp /etc/passbolt/passbolt.php /opt/backups/passbolt_files_$(date +%F)/
```

### 4. Backup GPG Keyring
```bash
sudo cp -r /var/lib/gnupg /opt/backups/passbolt_files_$(date +%F)/gnupg
sudo chown -R $USER:$USER /opt/backups/passbolt_files_$(date +%F)/gnupg
```

### 5. (Optional) Backup NGINX and SSL Configs
```bash
sudo cp /etc/nginx/sites-available/* /opt/backups/passbolt_files_$(date +%F)/
sudo cp -r /etc/letsencrypt /opt/backups/passbolt_files_$(date +%F)/letsencrypt
```

### 6. Archive the Backup
```bash
cd /opt/backups
sudo tar czvf passbolt_backup_$(date +%F).tar.gz passbolt_db_*.sql passbolt_files_$(date +%F)/
```

---

## 🔁 Restore Procedure

Make sure you have a clean Ubuntu server with the same Passbolt CE version installed.

### 1. Extract the Backup
```bash
sudo mkdir -p /opt/restore
sudo tar xzvf passbolt_backup_<date>.tar.gz -C /opt/restore
```

### 2. Restore MySQL Database
```bash
sudo mysql -u root -p
mysql> CREATE DATABASE passbolt;
mysql> exit
sudo mysql -u root -p passbolt < /opt/restore/passbolt_db_<date>.sql
```

### 3. Restore Passbolt Configuration
```bash
sudo cp /opt/restore/passbolt_files_<date>/passbolt.php /etc/passbolt/passbolt.php
```

### 4. Restore GPG Keyring
```bash
sudo rm -rf /var/lib/gnupg
sudo cp -r /opt/restore/passbolt_files_<date>/gnupg /var/lib/gnupg
sudo chown -R www-data:www-data /var/lib/gnupg
sudo chmod 700 /var/lib/gnupg
```

### 5. (Optional) Restore NGINX and SSL
```bash
sudo cp /opt/restore/passbolt_files_<date>/*.conf /etc/nginx/sites-available/
sudo cp -r /opt/restore/passbolt_files_<date>/letsencrypt /etc/letsencrypt
sudo systemctl reload nginx
```

---

## ✅ Post-Restore Health Check
Run the built-in health check:
```bash
sudo su -s /bin/bash -c "./bin/cake passbolt healthcheck" www-data
```

---

## 🔄 Recommended Backup Strategy

- 📅 Automate weekly backups via cron
- ☁️ Store backup archives on external media or remote secure storage
- 🧪 Test restore process periodically in a staging environment

---

## 📌 Notes

- Backup archives may contain sensitive data (e.g., GPG keys). Protect with file-level encryption or secure offsite storage.
- Adjust file paths or service names if you’ve customized your deployment.
