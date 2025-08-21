# GPG — Ed25519 Primary (cert-only) + 3 Subkeys (E, S, A)

**Goal:** Create an Ed25519 primary key that is *certification-only* (kept offline), plus three subkeys for **Encryption [E]**, **Signing [S]**, and **Authentication [A]** (used for SSH). Include revocation and cleanup steps so the online machine keeps *only* the subkeys.

**Scope / prerequisites**
- Tested with GnuPG **2.4.4** (Linux/macOS). Windows/Gpg4win is similar but paths/tools differ.
- Basic familiarity with terminal and `gpg` commands.
- A secure offline medium (encrypted USB or air-gapped machine) to store the master secret and revocation certificate.

---

## Overview (high level)
1. Create a certification-only primary key (Ed25519)
2. Add an encryption subkey (Curve25519 / cv25519)
3. Add a signing subkey (Ed25519)
4. Create authentication subkey **by creating a sign-only subkey first** and then changing its usage to Authenticate (this is required on some GPG builds) — see details below
5. Export & back up (master and subkeys)
6. Delete master secret from online machine and import *only* subkeys for daily use
7. Create revocation certificate and store it with the offline master
8. Optionally configure `gpg-agent` for SSH using the authentication subkey

---

## Detailed, copy-paste steps

> Replace `<KEYID>` with your key id / fingerprint where needed. Run commands as your normal user (do not use sudo for `gpg` unless you know why).

### A. Create the primary (certification-only) key

```bash
gpg --expert --full-generate-key
```

Follow the prompts. A typical transcript (user inputs after `>`):

```
Please select what kind of key you want:
  (9) ECC (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities, expert)
  (12) ECC (encrypt only)
Your selection? 9

Possible actions for a ECC key: Sign Encrypt Authenticate Certify
Current allowed actions: Sign Encrypt Authenticate Certify

# toggle off Sign, Encrypt, Authenticate so only Certify remains
> s
> e
> a
> q

Please select which elliptic curve you want:
  (1) Curve 25519
Your selection? 1

Key is valid for? (0) 0 = key does not expire
> 0

Is this correct? (y/N) y

# Enter your user ID (Name, Email) and passphrase when prompted
```

After creation, verify:

```bash
gpg -K --keyid-format LONG
# Expect: sec   ed25519/<KEYID> [C]
```

> **Note:** If your particular GPG build does not show ‘C-only’ in the menu, you may end up with `[SC]` for the primary. That is still acceptable, but keeping the primary offline remains important.

---

### B. Add an Encryption subkey (`[E]`) — cv25519

```bash
gpg --edit-key <KEYID>
# at gpg> prompt:
addkey
# choose the menu option for "ECC (encrypt only)" (usually 12)
# pick Curve 25519
# set expiration (recommended: 1y or 2y; you can renew)
save
```

Verify subkey present:

```bash
gpg -K --keyid-format LONG
# Expect an ssb with cv25519 and [E]
```

---

### C. Add a Signing subkey (`[S]`) — Ed25519

```bash
gpg --edit-key <KEYID>
# at gpg>:
addkey
# choose the menu option for "ECC (sign only)" (usually 10)
# pick Curve 25519 (Ed25519)
# set expiration (recommended)
save
```

Verify:

```bash
gpg -K --keyid-format LONG
# Expect an ssb ed25519 [S]
```

---

### D. Add an Authentication subkey (`[A]`) — (special step)

Some GPG menus allow `addkey --expert` → `ECC (set your own capabilities)` & toggle to Authenticate only. On other builds the Authenticate-only option isn't directly presented. The reliable & portable method is:

1. **Create a sign-only subkey first** (same as step C). Then:

```bash
gpg --edit-key <KEYID>
# at gpg> prompt
list                     # shows keys and indexes; note the index number of the new ssb you just created
key <N>                  # select the ssb you want to convert (replace <N> with the index shown)
change-usage             # interactively toggle capabilities; remove Sign, add Authenticate
save
```

Example transcript inside `gpg --edit-key`:

```
gpg> list
sec  0: ed25519/ABCDEF... [C]
ssb  1: cv25519/1111... [E]
ssb  2: ed25519/2222... [S]
# assume ssb 2 is the sign-only subkey we created for auth
gpg> key 2
gpg> change-usage
Possible actions for a ECC key: Sign Encrypt Authenticate Certify
Current allowed actions: Sign
# toggle off Sign and toggle on Authenticate
> s
> a
> q
gpg> save
```

Now `gpg -K` should show an ssb with `[A]` (or `[S][A]` depending on toggles). Recommended result: one ssb for `[E]`, one for `[S]`, and one for `[A]`.

---

### E. Export backups and create a revocation certificate (do this on the **secure** machine)

```bash
# Export full secret key (master + subkeys) — KEEP THIS OFFLINE, encrypted, in a safe
gpg --export-secret-keys -a <KEYID> > master-secret.asc

# Export *only* the secret subkeys for online use
gpg --export-secret-subkeys -a <KEYID> > subkeys-only.asc

# Export public key
gpg --export -a <KEYID> > public.asc

# Create a revocation certificate (store with the master offline)
gpg --output <KEYID>.rev --gen-revoke <KEYID>
```

**Important:** Protect `master-secret.asc` and `<KEYID>.rev` physically and cryptographically (encrypt the files, store in safe, or print with `paperkey`).

---

### F. Delete the private master from an online machine & import only subkeys

> If you generated everything on the same (online) machine, follow these steps. If you already generated keys on an offline machine, copy `subkeys-only.asc` to the online machine and just import it.

```bash
# (Optional) Confirm current secret keys
gpg -K --keyid-format LONG

# Delete secret keys (this removes secret material — confirm carefully)
gpg --delete-secret-keys <KEYID>

# Now import only the subkeys you prepared earlier (copy subkeys-only.asc to this machine):
gpg --import subkeys-only.asc

# Verify: secret key listing will show the primary as a stub (sec#) and the subkeys present
gpg -K --keyid-format LONG
# Expected:
# sec#  ed25519/<KEYID> [C]
# ssb   cv25519/<SUBID1> [E]
# ssb   ed25519/<SUBID2> [S]
# ssb   ed25519/<SUBID3> [A]
```

The `sec#` (or missing secret for master) indicates the primary secret key is not present — that is desired.

---

### G. Configure SSH authentication with the `[A]` subkey

1. Enable SSH support in `gpg-agent` (edit `~/.gnupg/gpg-agent.conf`):

```
enable-ssh-support
```

2. Restart gpg-agent:

```bash
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

3. Ensure your shell knows where the SSH socket is (add to `~/.bashrc`/`~/.zshrc`):

```bash
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
```

4. Tell `gpg-agent` which subkey to expose to SSH. Find the keygrip for the auth subkey:

```bash
gpg -K --with-keygrip --keyid-format LONG
```

Copy the `Keygrip = ...` value for the `[A]` subkey and append it to `~/.gnupg/sshcontrol`:

```bash
echo <KEYGRIP> >> ~/.gnupg/sshcontrol
chmod 600 ~/.gnupg/sshcontrol
```

5. Export the SSH public key for server `authorized_keys`:

```bash
gpg --export-ssh-key <KEYID>
# copy the output (ssh-ed25519 AAAA...) into server's ~/.ssh/authorized_keys
```

6. Test SSH login:

```bash
ssh user@yourserver
```

`gpg-agent` will prompt for the subkey passphrase when the authentication subkey is required.

---

## Verification & common checks

- List secret keys with long format:

```bash
gpg -K --keyid-format LONG
```

- Public key listing:

```bash
gpg --list-keys --keyid-format LONG
```

- If `sec#` appears, the secret primary is not present (good for offline master).

- If you ever need to **revoke a single subkey**, use `gpg --edit-key <KEYID>` → `key <N>` → `revkey` (or use offline master to issue a revocation cert for that subkey).

---

## Safety notes & best practices
- **Never** keep `master-secret.asc` on an internet-connected machine. Store it encrypted and offline.
- Use a strong passphrase on your primary key.
- Set reasonable expirations on subkeys (1–3 years) and renew them from the offline master when needed.
- Keep the revocation certificate offline with the master key material.
- If a subkey is compromised, revoke just that subkey and publish the revocation (use the offline master to sign the revocation if necessary).

---

## Quick checklist (copy for printing)
- [ ] Generate cert-only primary (Ed25519) and store master offline
- [ ] Add cv25519 encryption subkey (E)
- [ ] Add Ed25519 signing subkey (S)
- [ ] Create sign-only subkey then `change-usage` → Authenticate (A)
- [ ] Export `master-secret.asc`, `subkeys-only.asc`, `public.asc`
- [ ] Generate `<KEYID>.rev` revocation cert
- [ ] `gpg --delete-secret-keys <KEYID>` on online machine
- [ ] `gpg --import subkeys-only.asc` on online machine
- [ ] Configure `gpg-agent` for SSH and add auth keygrip to `sshcontrol`

---

If you want, I can also produce a **one-shot script** that runs safe checks and automates the export/import steps (you’d still perform the interactive keygen steps manually).

