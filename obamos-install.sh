#!/usr/bin/env bash
# ObamOS Professional TUI Installer

# Ensure dialog is available
if ! command -v dialog &> /dev/null; then nix-env -iA nixpkgs.dialog; fi

HEIGHT=15
WIDTH=50

# --- Function: Partitioning ---
partition_menu() {
    choice=$(dialog --menu "Disk Partitioning" $HEIGHT $WIDTH 4 \
        1 "Auto-format drive (GPT)" \
        2 "Manual partition" 3>&1 1>&2 2>&3 3>&-)
    
    if [ "$choice" == "1" ]; then
        lsblk
        read -p "Enter drive to wipe (e.g., /dev/sda): " DRIVE
        parted "$DRIVE" mklabel gpt
        parted "$DRIVE" mkpart primary ext4 1MiB 100%
        mkfs.ext4 "${DRIVE}1"
        mount "${DRIVE}1" /mnt
    fi
}

# --- Function: User Setup ---
user_menu() {
    USERNAME=$(dialog --inputbox "Enter Username:" $HEIGHT $WIDTH 3>&1 1>&2 2>&3 3>&-)
    PASSWORD=$(dialog --passwordbox "Set Password:" $HEIGHT $WIDTH 3>&1 1>&2 2>&3 3>&-)
    
    # Logic to be executed after config is generated
    echo "USER_NAME=$USERNAME" > /tmp/obamos_install_info
    echo "USER_PASS=$PASSWORD" >> /tmp/obamos_install_info
}

# --- Main Logic ---
dialog --title "ObamOS Installer" --msgbox "Welcome to the ObamOS Setup Utility." $HEIGHT $WIDTH
partition_menu
user_menu

# Final confirmation
if (dialog --yesno "Ready to install ObamOS?" $HEIGHT $WIDTH); then
    clear
    echo "Installing... Please wait."
    # Here you would trigger nixos-install
else
    clear
    echo "Installation aborted."
fi
