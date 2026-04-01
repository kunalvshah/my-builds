
# Certificate Authority (CA) Setup on Ubuntu 24.04 (Manual Steps)

This guide documents all manual steps used to set up a two-tier Certificate Authority (CA) infrastructure (Root CA + Intermediate CA) using OpenSSL on Ubuntu 24.04.

---

## 📁 Directory Structure

```bash
mkdir -p ~/ca/{root,intermediate}
cd ~/ca
```

### Root CA Directory Setup

```bash
cd ~/ca/root
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
```

### Intermediate CA Directory Setup

```bash
cd ~/ca/intermediate
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber
```

---

## 🔐 Generate Keys

### Root CA Key

```bash
openssl genrsa -out private/root.key.pem 4096
chmod 400 private/root.key.pem
```

### Root CA Self-signed Certificate

```bash
openssl req -config openssl.cnf     -key private/root.key.pem     -new -x509 -days 7300 -sha256 -extensions v3_ca     -out certs/root.cert.pem
chmod 444 certs/root.cert.pem
```

### Intermediate CA Key

```bash
openssl genrsa -out private/intermediate.key.pem 4096
chmod 400 private/intermediate.key.pem
```

---

## 📄 Intermediate CA Certificate Request and Signing

### Create Intermediate CSR

```bash
openssl req -config openssl.cnf -new -sha256     -key private/intermediate.key.pem     -out csr/intermediate.csr.pem
```

### Sign Intermediate Certificate with Root CA

```bash
cd ~/ca/root

openssl ca -config openssl.cnf -extensions v3_intermediate_ca     -days 3650 -notext -md sha256     -in ../intermediate/csr/intermediate.csr.pem     -out ../intermediate/certs/intermediate.cert.pem
chmod 444 ../intermediate/certs/intermediate.cert.pem
```

---

## 🔗 Create CA Chain

```bash
cat intermediate/certs/intermediate.cert.pem root/certs/root.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem
```

---

## 📜 End-Entity (Server) Certificate Issuance

### Generate Server Key

```bash
openssl genrsa -out api.intelimach.lab.key.pem 4096
```

### Generate CSR (on server)

```bash
openssl req -new -key api.intelimach.lab.key.pem -out api.intelimach.lab.csr.pem
```

### Sign Server Certificate (on CA server)

```bash
openssl ca -config openssl.cnf -extensions server_cert     -days 825 -notext -md sha256     -in csr/api.intelimach.lab.csr.pem     -out certs/api.intelimach.lab.cert.pem
chmod 444 certs/api.intelimach.lab.cert.pem
```

### Concatenate Full Chain for NGINX

```bash
cat certs/api.intelimach.lab.cert.pem certs/ca-chain.cert.pem > certs/api.intelimach.lab.fullchain.pem
```

---

## 🔧 Deploying on NGINX

```nginx
ssl_certificate     /etc/nginx/ssl/certs/api.intelimach.lab.fullchain.pem;
ssl_certificate_key /etc/nginx/ssl/private/api.intelimach.lab.key.pem;
```

---

## ✅ Trusted Certificate Installation (Manual)

- **Windows / Browsers**: Import `root.cert.pem` into Trusted Root Certification Authorities.
- **iOS / Android**: Email or upload and install `root.cert.pem` manually.

---

## ✅ DNS and Hosts Setup

Make sure `/etc/hosts` or internal DNS maps `api.intelimach.lab` to correct IP.

---

End of Guide.

### If above does not work then restore CA from the backup and follow the steps

# CA Restore Guide — Intelimach Lab

**Tested on:** Ubuntu 24.04.2 LTS, OpenSSL 3.0.13

## What You Need

1. **Backup file:** `ca-backup-YYYYMMDD.tar.gz`
2. **Root CA passphrase** (also stored in `README` inside the backup)
3. **Intermediate CA passphrase** (also stored in `README` inside the backup)

> **Security warning:** The backup contains `README` with both passphrases in plaintext. Always store the backup in an encrypted location (encrypted USB, password-protected vault, etc.).

---

## Step 1 — Create the Backup (on current server)

```bash
tar czf /root/ca-backup-$(date +%Y%m%d).tar.gz /root/ca /root/issue-cert.sh /root/README
```

## Step 2 — Transfer to New Server

```bash
scp /root/ca-backup-*.tar.gz user@newserver:/root/
```

## Step 3 — Restore (on new server)

```bash
# Install OpenSSL
apt update && apt install -y openssl

# Extract the backup
cd /
tar xzf /root/ca-backup-*.tar.gz
```

This restores everything to `/root/ca`, `/root/issue-cert.sh`, and `/root/README`.

Check `README` for the key passphrases, tested OS/OpenSSL versions, and usage notes.

**Important:** Always run `issue-cert.sh` with `bash`, not `sh`:
```bash
bash /root/issue-cert.sh app.intelimach.lab
```

### If restoring to a different path

If you don't want the files at `/root/ca`, extract wherever you like and then update the hardcoded paths in **three files**:

```bash
NEW_PATH="/your/new/path/ca"

sed -i "s|/root/ca|${NEW_PATH}|g" \
  ${NEW_PATH}/root/openssl.cnf \
  ${NEW_PATH}/intermediate/openssl.cnf \
  /path/to/issue-cert.sh
```

## Step 4 — Verify

Run all four checks — every one must pass:

```bash
# 4a. Verify Root key password
openssl rsa -in /root/ca/root/private/ca.key.pem -check -noout
# Expected: RSA key ok

# 4b. Verify Intermediate key password
openssl rsa -in /root/ca/intermediate/private/intermediate.key.pem -check -noout
# Expected: RSA key ok

# 4c. Verify the chain of trust
openssl verify -CAfile /root/ca/root/certs/ca.cert.pem \
  /root/ca/intermediate/certs/intermediate.cert.pem
# Expected: intermediate.cert.pem: OK

# 4d. Issue a test certificate
bash /root/issue-cert.sh test.intelimach.lab
# Expected: "Certificate Issued Successfully!" with verification OK
```

## Step 5 — Decommission Old Server

Once verified, securely wipe the CA data from the old server:

```bash
# On the OLD server — only after confirming the new one works
shred -vfz -n 5 /root/ca/root/private/ca.key.pem
shred -vfz -n 5 /root/ca/intermediate/private/intermediate.key.pem
shred -vfz -n 5 /root/README
rm -rf /root/ca
```

---

## Quick Reference — File Locations

```
/root/
├── README                             # Passphrases, system info, usage notes
├── issue-cert.sh                          # Certificate issuing script
└── ca/
    ├── root/
    │   ├── openssl.cnf                    # Root CA config
    │   ├── private/ca.key.pem             # Root private key (GUARD THIS)
    │   ├── certs/ca.cert.pem              # Root certificate (distribute to clients)
    │   ├── index.txt                      # Certificate database
    │   └── serial                         # Next serial number
    └── intermediate/
        ├── openssl.cnf                    # Intermediate CA config
        ├── private/intermediate.key.pem   # Intermediate private key
        ├── certs/intermediate.cert.pem    # Intermediate certificate
        ├── certs/ca-chain.cert.pem        # Full chain (Intermediate + Root)
        ├── index.txt                      # Certificate database
        └── serial                         # Next serial number
```

## Issuing Certificates After Restore

```bash
# Single domain
bash /root/issue-cert.sh app.intelimach.lab

# Custom validity (2 years)
bash /root/issue-cert.sh app.intelimach.lab 730

# With extra SANs
bash /root/issue-cert.sh app.intelimach.lab 365 "DNS:api.intelimach.lab,IP:192.168.1.100"

# Wildcard
bash /root/issue-cert.sh "*.intelimach.lab" 365
```

