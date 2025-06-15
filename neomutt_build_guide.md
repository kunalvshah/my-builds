
# Building and Installing NeoMutt (May 2025 Release) on Ubuntu 24.04 (WSL2)

This guide walks through building the latest NeoMutt from source using the `autosetup` system, configuring it for Gmail with GPG and OAuth support, and resolving platform-specific issues like AppArmor on WSL2.

---

## 📦 Prerequisites

### System
- OS: Ubuntu 24.04 running on WSL2
- Shell: Bash (with `sudo` privileges)

---

## 1. Clone the NeoMutt Repository

```bash
git clone https://github.com/neomutt/neomutt.git
cd neomutt
```

---

## 2. Install Required Build Dependencies

```bash
sudo apt update
sudo apt install -y   build-essential   libncursesw5-dev   libgnutls28-dev   libgpgme-dev   libnotmuch-dev   libtokyocabinet-dev   libsqlite3-dev   libidn2-0-dev   libsasl2-dev   liblz4-dev   libzstd-dev   zlib1g-dev   pkg-config   docbook-xml   docbook-xsl   xsltproc   xmlto   libp11-kit-dev   libgpg-error-dev
```

---

## 3. Configure the Build with `autosetup`

Use the following one-line command to configure NeoMutt with the required features:

```bash
./configure --prefix=/usr/local --ssl --gnutls --gpgme --notmuch --sqlite --tokyocabinet --sasl --autocrypt --zlib --lz4 --zstd --homespool --disable-paths-in-cflags --disable-doc
```

---

## 4. Build and Install

```bash
make -j$(nproc)
sudo make install
```

---

## 5. Verify Installation

```bash
neomutt -v
```

Make sure the output shows support for `gpgme`, `sasl`, `gnutls`, and compression backends like `lz4`, `zlib`, `zstd`.

---

## 6. Install Supporting Tools

These tools are helpful for full NeoMutt + Gmail usage:

```bash
sudo apt install -y gnupg msmtp isync notmuch w3m urlview pass xsel
```

---

## 7. 🛡 Handling AppArmor (WSL2-Specific)

AppArmor is not fully supported under WSL2 and may block `msmtp`.

### Option 1: Disable AppArmor Prompt During Reconfigure

Run:

```bash
sudo dpkg-reconfigure msmtp
```

When asked:

> **Enable AppArmor support for msmtp?**

Select: **No**

### Option 2: Manually Disable Profile

Alternatively, you can disable AppArmor for `msmtp` like this:

```bash
sudo mv /etc/apparmor.d/usr.bin.msmtp /etc/apparmor.d/usr.bin.msmtp.disabled
```

Or remove AppArmor entirely if not needed:

```bash
sudo apt purge apparmor apparmor-utils
```

---

## ✅ Ready for Configuration

At this point, NeoMutt is fully installed with support for:
- Gmail via `msmtp` and `isync`
- OAuth or App Password
- GPG encryption/signing
- Full privacy-oriented configuration

Next Steps:
- Configure `~/.msmtprc` for Gmail SMTP
- Setup `~/.mbsyncrc` for email fetching
- Write `~/.neomuttrc` for email reading

---
