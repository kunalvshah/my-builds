
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
