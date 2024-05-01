#!/bin/bash
echo "Script by Github/KoPlayz for UEFI systems (v1.1-2024-04-12)."
echo "You will need a partition for EFI (1GB Recommended), Root (majority), swap (RAM *2 recommended)"
echo " "
read -p "Confirm you have made these partitions, then type in the name of the partitions: (/dev/...)"

#efipart=userinput
read -p "EFI Partition: /dev/" efipart
efipart="/dev/$efipart"
echo "EFI (/boot) Partition is set to: $efipart"
echo "------------------------------------------------"

#rootpart=userinput
read -p "Root Partition: /dev/" rootpart
rootpart="/dev/$rootpart"
echo "Root (/) Partition is set to: $rootpart"
echo "------------------------------------------------"

#swappart=userinput
read -p "Swap Partition: /dev/" swappart
swappart="/dev/$swappart"
echo "SWAP Partition is set to: $swappart"
echo "------------------------------------------------"

# format ext4
mkfs.fat -F 32 $efipart
mkfs.ext4 $rootpart
mkswap $swappart

# Mount partitions
mntlocation=/mnt/karchinstall
mount $rootpart $mntlocation
mount --mkdir $efipart "$mntlocation/boot"
swapon $swappart
echo "------------------------------------------------"

read -p "Add packages seperates by spaces ( ) (WHICH YOU KNOW EXIST!) that you want added in addition to the base packages: " extrapackages
# Asking if cpu is AMD or Intel for microcode, then converting to lowercase
read -p "Is your CPU an AMD or Intel? " cpubrand1
cpubrand="${cpubrand1,,}"
# Asking if the cpu brand is correct
read -p "Is this correct: $cpubrand ? [Y/n] " confirm
confirm="${confirm,,}"
if [[ $confirm != "n" ]]; then
    echo "Confirmed."
else
    echo "Please re-enter the CPU brand."
fi
echo "------------------------------------------------"
# Pacstrap installing packages to /mnt
cpubrand2="$cpubrand"
echo "Here, we install:"
pacstrap -K $mntlocation base linux linux-firmware reflector nano grub $cpubrand2-ucode vim man-db man-pages texinfo networkmanager

genfstab -U $mntlocation >> $mntlocation/etc/fstab
echo "------------------------------------------------"
# Final touches
read -p "What would you like to set your hostname to? " hostname
echo "$hostname" > "$mntlocation/etc/hostname"
arch-chroot $mntlocation /bin/bash <<EOF
# Create a new user and set password/root password
read -p "What should the username be? " username
read -p "What should the password be? " password
read -p "What should the root (superuser) password be? " rootpassword
useradd -m "$username"
echo "$username:$password" | chpasswd
echo "root:$rootpassword" | chpasswd

# Update mirrors
echo Updating mirrors...
reflector --verbose --latest 5 --age 2 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Install GRUB for x86_64 UEFI
echo Installing GRUB for x86_64 UEFI...
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
EOF

read -p "Finished. Would you like to restart? (y/N) " restart
if [[ $restart == "y" || $restart == "Y" ]]; then
    reboot
fi
