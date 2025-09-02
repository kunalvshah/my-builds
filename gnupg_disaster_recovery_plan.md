# GnuPG Disaster Recovery Plan

This document describes what to do if you lose access to your GnuPG private keys.

---

## 1. Prevention (Best Practices)
- Keep your **primary key offline** (air-gapped USB, encrypted vault).
- Use **subkeys (S, E, A)** for daily operations.
- Always generate a **revocation certificate** at key creation:
  ```bash
  gpg --output revoke-cert.asc --gen-revoke <KEYID>
  ```
- Store multiple **backups** of:
  - Primary private key (offline, encrypted)
  - Subkeys
  - Revocation certificate (printed as QR, or encrypted USB)

---

## 2. If You Lose a Subkey
- Use your **offline primary key** to extend/renew subkeys or create new ones:
  ```bash
  gpg --edit-key <KEYID>
  gpg> addkey
  gpg> save
  ```
- Publish updated key to keyservers or distribute directly.

---

## 3. If You Lose All Subkeys but Still Have the Primary Key
- Import your offline **primary key**.
- Generate replacement subkeys (sign/encrypt/auth).
- Push updated public key to servers.

---

## 4. If You Lose Your Primary Key but Have the Revocation Certificate
- Upload the **revocation certificate** to keyservers:
  ```bash
  gpg --import revoke-cert.asc
  gpg --keyserver hkps://keys.openpgp.org --send-keys <KEYID>
  ```
- Notify your contacts: "My old key has been revoked, use my new key."

---

## 5. If You Lose Both Primary Key and Revocation Certificate
- Worst-case scenario:
  - You cannot revoke your old key.
  - Subkeys will expire automatically, but primary key will remain on keyservers forever.
- What to do:
  1. Generate a **new keypair**.
  2. Publish and distribute the new public key.
  3. Inform contacts (email signature, website, social profile):
     - "My old key `<OLDKEYID>` is no longer valid, please use `<NEWKEYID>`."

---

## 6. Quick Checklist
- ✅ Always create and back up a **revocation cert**.
- ✅ Keep **primary key offline**, use **subkeys** daily.
- ✅ Set **expiry** for subkeys (1–2 years). Renew with offline master.  
- ✅ If disaster strikes:
  - Subkey lost → renew it.  
  - Master + cert → revoke.  
  - Master lost, no cert → abandon, announce new key.  

---

Stay safe 🔐
