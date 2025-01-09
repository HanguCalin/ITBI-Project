# AMSH Shell Script

## Overview
AMSH (**`Automounter Shell`**) is a custom shell script that automates the handling of mountpoints. It provides a shell-like interface (**`amsh>`**) and ensures that required filesystems are automatically mounted before accessing them. Mountpoints are automatically unmounted after a configurable timeout if they are no longer in use. The script handles both internal commands (like `cd`) and external commands (like `touch` or `ls`), ensuring compatibility with filesystems specified in a configuration file.

---

## Features
- Provides a shell-like interface.
- Automatically mounts filesystems defined in the configuration file (`amsh_mounts.conf`).
- Ensures filesystems are unmounted if unused for a configurable timeout period.
- Prevents unmounting if other processes or the shell itself are using a mountpoint.
- Supports internal commands (`cd`) and external commands (`touch`, `ls`, etc.) seamlessly.

---

## Requirements
- Linux operating system.
- Bash shell.
- Root privileges for mounting and unmounting filesystems.
- `mount`, `umount`, `lsof`, and `awk` utilities available.

---

## Installation
1. Create the directory AMShell and clone this repository.
   ```bash
    ~$ cd /home/vboxuser/Desktop/
    ~/Desktop$ mkdir AMShell
    ~/Desktop$ cd AMShell/
    ~/Desktop/AMShell$ git clone https://github.com/HanguCalin/ITBI-Project
    ~/Desktop/AMShell$ sudo mkdir -p /mnt/data /mnt/backup /mnt/test
    ```
2. Create the virtual disks and format them with the `ext4` filesytem.
    ```bash
    ~/Desktop/AMShell$ dd if=/dev/zero of=./data.img bs=1M count=10
    ~/Desktop/AMShell$ mkfs.ext4 ./data.img 
    ~/Desktop/AMShell$ dd if=/dev/zero of=./backup.img bs=1M count=10
    ~/Desktop/AMShell$ mkfs.ext4 ./backup.img 
    ~/Desktop/AMShell$ dd if=/dev/zero of=./test.img bs=1M count=10
    ~/Desktop/AMShell$ mkfs.ext4 ./test.img 
    ```
3. Make the shell script executable.
    ```bash
    ~/Desktop/AMShell$ chmod +x amsh.sh
   ```
---

## Configuration
The script reads filesystem information from a configuration file named `amsh_mounts.conf`. This file should be located in the same directory as the script.

### Configuration File Format
```
# Format: device_path mount_path fs_type
/dev/sdb1 /mnt/data ext4
/dev/sdb2 /mnt/backup ntfs
```

- **device_path**: The device to be mounted (e.g., `/dev/sdb1`).
- **mount_path**: The directory where the device should be mounted (e.g., `/mnt/data`).
- **fs_type**: Filesystem type (e.g., `ext4`, `ntfs`).

### Example Configuration File
```
# Example configuration file for AMSH
./data.img /mnt/data ext4
./backup.img /mnt/backup ext4
./test.img /mnt/test ext4

```

---

## Usage
Run the script using:
```bash
./amsh.sh
```

### Available Commands
- **`cd <path>`**: Change directory. Automatically mounts the target path if required.
- **External commands**: Use any valid shell command (e.g., `ls`, `touch`, `cat`). If the command accesses a mountpoint, it will automatically mount it.
- **`exit`**: Exit the shell.

---

## Timeout Handling
Mountpoints are automatically unmounted after a period of inactivity (default: 10 seconds). The timeout can be configured by modifying the `MOUNT_TIMEOUT` variable in the script.

If a mountpoint is in use (e.g., by another process or the shell itself), it will not be unmounted until it becomes idle.

---

## License
This project is licensed under the MIT License. See the LICENSE file for details.

---

## Author
**Hangu Calin, Ungureanu Sergiu, Spoiala Cristian**