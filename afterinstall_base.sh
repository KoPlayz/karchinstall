#!/bin/bash
rm ~/afterinstall_base.sh
rm ~/.bashrc
echo Updating mirrors
read -p "Enter your country code (e.g., US, GB): " country
reflector --verbose --latest 5 --age 2 --fastest 5 --protocol https --sort rate --country "$country" --save /etc/pacman.d/mirrorlist

echo Updating system...
sudo pacman -Syu

install_desktop_environment() {
    echo "Installing a DE/WM"
    echo "DEs:"
    echo "[1] KDE Plasma"
    echo "[2] Gnome"
    echo "[3] XFCE"
    echo "WMs:"
    echo "[4] AwesomeWM"
    echo "[5] I3WM"

    while true; do
        read -p "Which DM/WM? (1-5) " choice
        case $choice in
            1)
                echo "Installing KDE Plasma..."
                sudo pacman -S plasma-desktop konsole sddm
                sudo systemctl enable sddm
                echo Done.
                break
                ;;
            2)
                echo "Installing Gnome..."
                sudo pacman -S gnome gnome-terminal gdm
                sudo systemctl enable gdm
                echo Done.
                break
                ;;
            3)
                echo "Installing XFCE..."
                sudo pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
                sudo systemctl enable lightdm.service
                echo Done.
                break
                ;;
            4)
                echo "Installing AwesomeWM..."
                sudo pacman -S awesome kitty lightdm lightdm-gtk-greeter
                sudo systemctl enable lightdm.service
                echo Done.
                echo "[Seat:*]
greeter-session=lightdm-gtk-greeter
user-session=awesome" | sudo tee /etc/lightdm/lightdm.conf
                break
                ;;
            5)
                echo "Installing I3WM..."
                sudo pacman -S i3-gaps i3status dmenu lightdm lightdm-gtk-greeter
                sudo systemctl enable lightdm
                echo "[Seat:*]
greeter-session=lightdm-gtk-greeter
user-session=i3" | sudo tee /etc/lightdm/lightdm.conf
                echo Done.
                break
                ;;
            *)
                echo "Invalid choice. Please select a number from 1 to 5."
                ;;
        esac
    done
}

install_desktop_environment

