#!/bin/bash
# proxmox-cloudinit-template.sh
# Automates creation of a Proxmox VM template with Cloud-Init support

set -e

# === Variables (edit these before running) ===
VMID=110
VMNAME="ubuntu-template"
STORAGE="local-lvm"
BRIDGE="vmbr1"
MEMORY=2048
DISK_SIZE=30G
UBUNTU_IMG="/root/ubuntu-24.04-server-cloudimg-amd64.img"
SNIPPET_USERDATA="/var/lib/vz/snippets/${VMID}-userdata-cloudinit.yaml"

# === Step 1: Create VM ===
echo "[*] Creating VM $VMID ($VMNAME)..."
qm create $VMID \
  --name $VMNAME \
  --memory $MEMORY \
  --balloon $MEMORY \
  --cpu host \
  --cores 2 \
  --net0 virtio,bridge=$BRIDGE \
  --bios ovmf \
  --agent enabled=1

# === Step 2: Import disk ===
echo "[*] Importing Ubuntu cloud image..."
qm importdisk $VMID $UBUNTU_IMG $STORAGE

# Attach imported disk as virtio0
qm set $VMID --virtio0 ${STORAGE}:vm-${VMID}-disk-0,discard=on,cache=writeback

# Resize disk
qm resize $VMID virtio0 $DISK_SIZE

# Add Cloud-Init drive
qm set $VMID --scsi0 ${STORAGE}:cloudinit

# Add serial port
qm set $VMID --serial0 socket

# Configure boot order
qm set $VMID --boot order=virtio0

# === Step 3: Convert to template ===
echo "[*] Converting VM $VMID to template..."
qm template $VMID

# === Step 4: Clone VM from template ===
NEW_VM_ID=210
NEW_VM_NAME="ubuntu-vm1"

echo "[*] Cloning template to new VM $NEW_VM_ID ($NEW_VM_NAME)..."
qm clone $VMID $NEW_VM_ID --name $NEW_VM_NAME --full

# === Step 5: Attach Cloud-Init customization ===
echo "[*] Attaching Cloud-Init user data..."
qm set $NEW_VM_ID --cicustom "user=local:snippets/$(basename $SNIPPET_USERDATA)"

# Update Cloud-Init
qm cloudinit update $NEW_VM_ID

echo "[*] VM $NEW_VM_ID ($NEW_VM_NAME) is ready!"
echo "You can now start it: qm start $NEW_VM_ID"
