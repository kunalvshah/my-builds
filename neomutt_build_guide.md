# 🧩 NeoMutt Build & Install Guide (Ubuntu 24.04 - WSL2)

## ✅ System

- **OS**: Ubuntu 24.04 (running inside WSL2)
- **Kernel**: Linux 6.6.87.1-microsoft-standard-WSL2
- **Target**: Full-featured NeoMutt for Gmail (IMAP/SMTP + OAuth2), GPG, Header Cache with Compression, and Privacy

---

## 🔧 Step 1: Install Required Dependencies

```bash
sudo apt update && sudo apt install -y \
  build-essential \
  git \
  pkg-config \
  libncursesw5-dev \
  libssl-dev \
  libgnutls28-dev \
  libgpgme-dev \
  libnotmuch-dev \
  libsqlite3-dev \
  libtokyocabinet-dev \
  libsasl2-dev \
  liblz4-dev \
  libzstd-dev \
  zlib1g-dev \
  libidn2-dev \
  libtinfo-dev \
  docbook-xml \
  docbook-xsl \
  xsltproc \
  xml-core \
  ca-certificates \
  curl
```

---

## 📦 Step 2: Clone the NeoMutt GitHub Repository

```bash
git clone https://github.com/neomutt/neomutt.git
cd neomutt
```

Check out the latest tagged release (May 2025):

```bash
git checkout 20250510
```

---

## ⚙️ Step 3: Configure Build with Autosetup

```bash
./configure --prefix=/usr/local --ssl --gnutls --gpgme --notmuch --sqlite --tokyocabinet --sasl --autocrypt --zlib --lz4 --zstd --homespool --disable-paths-in-cflags --disable-doc
```

This configures NeoMutt with:
- GPG/PGP support
- Gmail-compatible TLS + SASL
- IMAP/SMTP
- Header caching (TokyoCabinet)
- Compression (lz4, zstd, zlib)
- Privacy (no hostname or build path leaks)

If you encounter errors like `liblz4` or `libzstd` not found, double-check that `liblz4-dev` and `libzstd-dev` are installed.

---

## 🛠️ Step 4: Build and Install

```bash
make -j$(nproc)
sudo make install
```

---

## 🔍 Step 5: Confirm Build Features

```bash
neomutt -v
```

You should see output like:

```
NeoMutt 20250510-1-<commit_hash>
...
Compile options:
  +autocrypt +gnutls +gpgme +notmuch +sqlite +sasl +smime +pgp
  +hcache +lz4 +zlib +zstd
...
storage: tokyocabinet
```

---

## ✅ Optional: Runtime Utilities (Recommended)

```bash
sudo apt install -y gnupg msmtp isync notmuch w3m urlview pass xsel
```

---

## 📁 Filesystem Paths of Interest

| Path                    | Description                                |
|-------------------------|--------------------------------------------|
| `/usr/local/bin/neomutt` | Installed NeoMutt binary                  |
| `/usr/local/etc/`       | Location for `neomuttrc` if system-wide    |
| `~/.config/neomutt/`    | Preferred config dir (create manually)     |
| `~/.gnupg/`              | GPG key storage                            |
| `~/.mail/` or `~/Maildir/` | Mail store if using offline sync tools |
