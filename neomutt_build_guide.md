# NeoMutt Pro-Grade Build and Setup Guide (Ubuntu 24.04 WSL)

Last updated: June 2025

---

## 🧰 System Overview

- **OS**: Ubuntu 24.04 (WSL)
- **NeoMutt version**: `20250510`
- **Build system**: autosetup
- **Mail provider**: Gmail (initially with App Password; OAuth2 optional for advanced setup)
- **Privacy-focused**: Headers sanitized, secure configurations

---

## ✅ Step-by-Step Installation and Setup

### Step 0: Preliminaries

```bash
sudo apt update && sudo apt upgrade
sudo apt install -y build-essential libncursesw5-dev libgnutls28-dev libgpgme-dev libnotmuch-dev \
  libsqlite3-dev libsasl2-dev libtokyocabinet-dev libidn2-0-dev liblz4-dev libzstd-dev zlib1g-dev \
  docbook-xml docbook-xsl xsltproc xmlto gettext pkg-config libssl-dev
```

### Step 1: Build NeoMutt

```bash
git clone https://github.com/neomutt/neomutt
cd neomutt
./configure \
  --prefix=/usr/local \
  --ssl \
  --gnutls \
  --gpgme \
  --notmuch \
  --sqlite \
  --tokyocabinet \
  --sasl \
  --autocrypt \
  --zlib \
  --lz4 \
  --zstd \
  --homespool \
  --disable-doc \
  --disable-paths-in-cflags
make -j$(nproc)
sudo make install
```

### Step 2: Install Supporting Tools

```bash
sudo apt install -y gnupg msmtp isync notmuch w3m urlview pass xsel
```

> During installation, when prompted:
>
> - ✅ Choose "Yes" to enable AppArmor for `msmtp`.
> - Later, you can disable strict enforcement with:\
>   `sudo dpkg-reconfigure msmtp` → Select "No" for AppArmor support if needed.

---

## 🔐 Mail Client Setup (Pro-Grade with App Password)

### Folder Standardization

We use `~/.mail` as the unified location for all mail-related config and storage.

### Step 1: `msmtp` Setup (Sending Mail)

#### 1.1 Create Gmail Config

File: `~/.config/msmtp/config`

```ini
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ~/.mail/msmtp.log

account gmail
host smtp.gmail.com
port 587
from your_email@gmail.com
user your_email@gmail.com
passwordeval "gpg -q --for-your-eyes-only --no-tty -d ~/.mail/gmail/pass.gpg"

account default : gmail
```

#### 1.2 Store Gmail App Password Securely

```bash
gpg -o ~/.mail/gmail/pass.gpg -e -r YOUR_GPG_KEY_ID
# Type the App Password when prompted
```

#### 1.3 Permissions

```bash
chmod 600 ~/.config/msmtp/config
chmod 600 ~/.mail/gmail/pass.gpg
```

#### 1.4 Test

```bash
echo -e "To: your_email@gmail.com\nSubject: msmtp test\n\nThis is a test from msmtp." | msmtp -a gmail -t
```

---

### Step 2: `mbsync` Setup (Receiving Mail)

#### 2.1 Create Directory

```bash
mkdir -p ~/.mail/gmail
```

#### 2.2 Create Config: `~/.mbsyncrc`

```ini
IMAPStore remote-gmail
Host imap.gmail.com
User your_email@gmail.com
PassCmd "gpg -q --for-your-eyes-only --no-tty -d ~/.mail/gmail/pass.gpg"
SSLType IMAPS

MaildirStore local-gmail
Path ~/.mail/gmail/
Inbox ~/.mail/gmail/INBOX

Channel gmail
Far :remote-gmail:
Near :local-gmail:
Patterns *
Create Both
SyncState *
```

#### 2.3 Permissions

```bash
chmod 600 ~/.mbsyncrc
```

#### 2.4 GPG Key

Use a GPG key for encrypting your App Password. You can change this key later by re-encrypting `pass.gpg`. By default, your GPG key is local unless explicitly uploaded to a keyserver.

#### 2.5 Initial Sync

```bash
mbsync gmail
```

> By default, `mbsync` synced to `~/Mail` but we redirected it to `~/.mail/gmail/` using `Path`.

---

### Step 3: NeoMutt Configuration

#### 3.1 Directory Structure

```
~/.mail/
├── gmail/
│   ├── account.rc
│   └── folders (e.g., INBOX, Sent, etc.)
```

#### 3.2 `~/.config/neomutt/neomuttrc`

```neomutt
source ~/.mail/gmail/account.rc
```

#### 3.3 `~/.mail/gmail/account.rc`

```neomutt
set realname = "Your Name"
set from = "your_email@gmail.com"
set sendmail = "/usr/bin/msmtp"
set use_from = yes
set envelope_from = yes

set folder = "~/.mail/gmail"
set spoolfile = "+INBOX"
set record = "+[Gmail]/Sent Mail"
set postponed = "+[Gmail]/Drafts"
set trash = "+[Gmail]/Trash"

set header_cache = ~/.cache/neomutt/headers
set message_cachedir = ~/.cache/neomutt/bodies
set certificate_file = ~/.mail/certificates
```

#### 3.4 Create Cache Directories

```bash
mkdir -p ~/.cache/neomutt/{headers,bodies}
mkdir -p ~/.mail/certificates
```

#### 3.5 Run NeoMutt

```bash
neomutt
```

---

## 🔪 Optional: Test Mail Flow

Send a test mail via `msmtp` and check it appears in your inbox via `mbsync` and `neomutt`.

---

## 🔒 Privacy Tips

- NeoMutt strips local hostname and IP by default if properly built (`--disable-paths-in-cflags`)
- Avoid using `.muttrc` if using modern structure with `neomuttrc`
- Use GPG for storing passwords

---

## 📌 To Do Later

- Add OAuth2 setup in **Advanced Setup** section.
- Configure PGP for encrypted mail.
- Add hooks, macros, sidebar customization, etc.

---

## 🧼 Cleanup

```bash
sudo apt autoremove
sudo apt clean
```

---

## ✅ Summary

You now have a **fully customized NeoMutt** email setup that:

- Sends via Gmail using App Password and `msmtp`
- Receives via `mbsync` IMAP sync
- Stores everything in `~/.mail/gmail`
- Uses `gnupg` for password security
- Has compression and header cache support enabled

---

For any issues, feel free to raise them on the [NeoMutt GitHub](https://github.com/neomutt/neomutt/issues).

