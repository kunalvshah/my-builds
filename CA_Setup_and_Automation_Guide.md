# Personal Certificate Authority (CA) Setup Guide

**Created on:** 2025-07-31 19:27:39

## Overview

This guide documents the complete setup and automation of a personal Certificate Authority on Ubuntu 24.04, used for both lab and protected production servers.

---

## ✅ Phase 1: Root CA Setup

- Directory structure created under `/root/ca`
- Root private key and self-signed certificate generated (RSA 4096)
- OpenSSL config `openssl.cnf` for Root CA defined
- Root CA kept offline (air-gapped when possible)

---

## ✅ Phase 2: Intermediate CA Setup

- Intermediate directory under `/root/ca/intermediate`
- Intermediate key generated and CSR created
- CSR signed by Root CA with `v3_intermediate_ca` extensions
- Intermediate OpenSSL config updated with:
  - `copy_extensions = copy`
  - `policy_loose` for flexible DN fields
  - SAN support

---

## ✅ Phase 3: Certificate Chain

- Chain created:
  - `ca-chain.cert.pem` includes intermediate + root
  - Used `cat intermediate.cert.pem root.cert.pem > ca-chain.cert.pem`

---

## ✅ Phase 4: NGINX Server Certificate

- CSR generated from NGINX host
- Intermediate CA signed server CSR with `server_cert` usage
- Deployment:
  - Private key in `/etc/nginx/ssl/private/`
  - Cert in `/etc/nginx/ssl/certs/`
  - Configured `ssl_certificate` and `ssl_certificate_key`
  - Chain includes only server cert + intermediate
- Resolved common errors:
  - `ERR_CERT_AUTHORITY_INVALID`: solved via proper root install
  - `ERR_CERT_COMMON_NAME_INVALID`: solved via SAN

---

## ✅ Phase 5: OS Certificate Trust Store

- **Windows**: Imported Root CA cert manually into "Trusted Root"
- **iOS & Android**: Deployment steps documented
  - iOS: Installed via profile / email
  - Android: Installed via system settings

---

## ✅ Phase 6: Automation Scripts

### 🔹 Scripts Created

- `ca.sh`: Unified CLI wrapper with:
  - `sign`, `revoke`, `crl`, `chain` subcommands
- `generate_full_chain.sh`: Combines server cert + intermediate (+ root if needed)
- `generate_csr.sh`: CSR generator for web servers
- Logging added to each script for audit trail

### 🔹 File Locations

- CA Directory: `/root/ca`
- Scripts: `/root/ca/scripts/`

---

## 🧩 Advanced Considerations

- OCSP skipped due to air-gapped/protected network
- No active revocation tracking needed
- Flexible OpenSSL config enables SAN/IP for multiple hosts
- `openssl.cnf` cleanly separates cert types (server, user)

---

## ✅ Example Host Issued

- `passbolt.intelimach.com`: CSR signed and deployed successfully
- `api.intelimach.lab`: NGINX cert issued and trusted

---

## 🔁 Future Use Prompt

To repeat this setup with minimal input, use:

> "Setup a personal OpenSSL CA with an offline root and online intermediate on Ubuntu 24.04 for internal and lab servers. Automate CSR signing, logging, chain generation. Assume root access and secure network."

---

## Author

Kunal | Intelimach Lab CA Authority
