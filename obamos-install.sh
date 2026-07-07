#!/usr/bin/env bash
# ObamOS Professional TUI Installer

if ! command -v dialog &> /dev/null; then nix-env -iA nixpkgs.dialog; fi

HEIGHT=15; WIDTH=50

# Partitioning
partition_menu() {
    choice=$(dialog --menu "Disk Partitioning" $HEIGHT $WIDTH 3 \
        1 "Auto-format drive (GPT + EFI)" \
        2 "Manual partition" 3>&1 1>&2 2>&3 3>&-)
    
    if [ "$choice" == "1" ]; then
        lsblk
        DRIVE=$(dialog --inputbox "Enter drive to wipe (e.g., /dev/vda):" $HEIGHT $WIDTH 3>&1 1>&2 2>&3 3>&-)
        parted "$DRIVE" mklabel gpt
        parted "$DRIVE" mkpart primary fat32 1MiB 512MiB
        parted "$DRIVE" set 1 esp on
        parted "$DRIVE" mkpart primary ext4 512MiB 100%
        mkfs.fat -F 32 "${DRIVE}1"
        mkfs.ext4 "${DRIVE}2"
        mount "${DRIVE}2" /mnt
        mkdir -p /mnt/boot
        mount "${DRIVE}1" /mnt/boot
    fi
}

# Theme selection
theme_menu() {
    THEME=$(dialog --menu "Select Hyprland Theme" $HEIGHT $WIDTH 3 \
        1 "Default Hyprland" \
        2 "Caelestia" \
        3 "End-4" 3>&1 1>&2 2>&3 3>&-)
    echo "THEME=$THEME" > /tmp/obamos_theme
}

# User Setup
user_menu() {
    USERNAME=$(dialog --inputbox "Enter Username:" $HEIGHT $WIDTH 3>&1 1>&2 2>&3 3>&-)
    PASSWORD=$(dialog --passwordbox "Set Password:" $HEIGHT $WIDTH 3>&1 1>&2 2>&3 3>&-)
    echo "USER=$USERNAME" >> /tmp/obamos_install_info
    echo "PASS=$PASSWORD" >> /tmp/obamos_install_info
}

dialog --title "ObamOS Setup" --msgbox "Welcome to the ObamOS Installer." $HEIGHT $WIDTH
partition_menu
theme_menu
user_menu

if (dialog --yesno "Proceed with installation?" $HEIGHT $WIDTH); then
    echo "Generating System..."
    # Deployment logic would follow here
else
    echo "Aborted."
fi
