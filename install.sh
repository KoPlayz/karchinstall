#!/bin/bash
echo "Script by Github/KoPlayz for UEFI systems (v1.1-2024-04-12)."
echo "What is the path of your HD/USB to install?"
sudo fdisk -l
echo "------------------------------------------------"
read -p "HD/USB install (eg, /dev/vda): /dev/" hdloc
echo "------------------------------------------------"
echo " "
clear
echo "The size of the specified drive is: $(lsblk -b -n -o SIZE /dev/$hdloc | awk '{printf "%.2f", $1/1024/1024/1024}') GB"
echo -e "\e[1;31mTHIS DRIVE WILL BE ERASED\e[0m"
read -p "OK? (y/n) " answer
if [[ $answer == "yes" || $answer == "y" ]]; then
    # Continue with the rest of your script here
    echo "Continuing with drive erase..."
else
    echo "Exiting..."
    exit 1
fi
hdloc=/dev/$hdloc

# Setting disk to GPT
parted --script $hdloc mklabel gpt

# Create a 1GB partition
parted --script $hdloc mkpart primary 1MiB 1GiB

# Create an 8GB partition
parted --script $hdloc mkpart primary 1GiB 9GiB

# Create a partition using the rest of the space
parted --script $hdloc mkpart primary 9GiB 100%

# Set disk variables
efipart=$hdloc"1"
swappart=$hdloc"2"
rootpart=$hdloc"3"

# Format partitions
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
pacstrap -K $mntlocation base linux efibootmgr linux-firmware reflector nano grub $cpubrand2-ucode vim man-db man-pages texinfo networkmanager

genfstab -U $mntlocation >> $mntlocation/etc/fstab
echo "------------------------------------------------"
# Setting hostname
read -p "What would you like to set your hostname to? " hostname
echo "$hostname" > "$mntlocation/etc/hostname"
echo "------------------------------------------------"

read -p "What should the username be? " username
read -p "What should the password be? " password
read -p "What should the root (superuser) password be? " rootpassword


# Making user account and changing files
info_file="$mntlocation/home/root/user_info"
echo "username=$username" > $info_file
echo "password=$password" >> $info_file
echo "rootpassword=$rootpassword" >> $info_file
username=0
password=0
rootpassword=0
# chrooting in for final things
arch-chroot $mntlocation /bin/bash <<EOF
source /home/root/user_info
# Add user & set passwd
useradd -m "$username"
echo "$username:$password" | chpassword
echo "root:$rootpassword" | chpassword
shred /home/root/user_info
rm /home/root/user_info
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
