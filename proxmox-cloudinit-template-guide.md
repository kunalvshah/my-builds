# Proxmox VM Template Creation with Cloud-Init

This guide walks through creating a reusable Proxmox VM template with
Cloud-Init support and deploying a VM from it.

------------------------------------------------------------------------

## Step 1: Create the Base VM

1.  Login to **Proxmox Web UI** and create a new VM.
2.  On the **Create Virtual Machine** page:
    -   **General**: Set **VM ID** (your choice), **Name** (your
        choice). Leave other fields as default.
    -   **OS**: Do not use any media.
    -   **System**:
        -   Set **BIOS** = `OVMF (UEFI)`.
        -   Select **EFI Storage**.
        -   Check **Qemu Agent**.
    -   **Disk**: Remove the default `scsi0` disk (we will add it later
        via shell).
    -   **CPU**: Choose **Type = Host**, keep others default.
    -   **Memory**: Set `2048` for both **Memory** and **Minimum
        Memory**. Ensure **Ballooning Device** is checked.
    -   **Network**: Select **Bridge = vmbr1**. Leave others unchanged.
    -   **Confirm**: Click **Finish** and make sure **Start after
        created** is **unchecked**.

------------------------------------------------------------------------

## Step 2: Import the Disk and Configure VM

1.  Note down the **VM ID** you just created.

2.  Login to **Proxmox shell** as `root`.

3.  Run:

    ``` bash
    qm disk import <VMID> <ubuntu-image>.img local-lvm
    ```

4.  Go back to **Proxmox Web UI** → Select the VM → **Hardware** tab:

    -   You will see **Unused Disk 0**.
    -   Click **Unused Disk 0** → Set:
        -   **Bus** = `VirtIO Block`\
        -   **Discard** = checked\
        -   **Cache** = `Write back`\
        -   **Backup** = unchecked\
    -   This will now show as `Hard Disk (virtio0)`.
    -   Select `virtio0` → **Disk Action → Resize** → Set **Size
        Increment (GiB) = 30** → **Resize**.

5.  Add Cloud-Init drive:

    -   Click **Add → CloudInit Drive**
    -   Set **Bus = SCSI**
    -   Set **Storage = local-lvm**.

6.  Add Serial Port:

    -   Click **Add → Serial Port → 0**.

7.  Configure Boot Order:

    -   Go to **Options → Boot Order**.
    -   Unselect everything except `virtio0`.
    -   Move `virtio0` to the top.

------------------------------------------------------------------------

## Step 3: Convert VM to Template

1.  Shutdown the VM if running.

2.  Convert it into a template:

    ``` bash
    qm template <VMID>
    ```

------------------------------------------------------------------------

## Step 4: Create a VM from Template

1.  From **Proxmox Web UI**, right-click the template.
2.  Select **Clone**.
3.  Choose:
    -   **Mode = Full Clone** (recommended).
    -   Provide a **new VM ID** and **Name**.
4.  Once created, you have a new VM based on the template.

------------------------------------------------------------------------

## Step 5: Apply Cloud-Init Customization

You can provide custom Cloud-Init configuration (user data, network
config, etc.) to the cloned VM.

> **Note (Best Practice):**  
> It is recommended to name Cloud-Init snippet files with the **VMID prefix** for clarity and easier management.  
> Suggested naming convention:  
> - `<VMID>-userdata-cloudinit.yaml`  
> - `<VMID>-network-cloudinit.yaml`  
>
> This helps quickly identify which snippet belongs to which VM.

1.  Place your Cloud-Init YAML file under:

    ``` bash
    /var/lib/vz/snippets/
    ```

2.  Link it to the VM:

    ``` bash
    qm set <VMID> --cicustom "user=local:snippets/<VMID>-userdata-cloudinit.yaml,network=local:snippets/<VMID>-network-cloudinit.yaml"
    ```

------------------------------------------------------------------------

✅ You now have a reusable Proxmox VM template with Cloud-Init support.\
You can easily spin up new VMs with custom initialization scripts.
