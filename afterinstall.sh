#!/bin/bash
echo Running KArchInstall afterinstall (v1-2024-04-11)
echo Updating mirrors
read -p "Enter your country code (e.g., US, GB): " country
reflector --verbose --latest 5 --age 2 --fastest 5 --protocol https --sort rate --country "$country" --save /etc/pacman.d/mirrorlist

echo Updating system...
sudo pacman -Syu

echo Installing:
echo OBSᶠˡᵃᵗᵖᵃᵏ
echo Discord
echo flatpak
echo yayᵃᵘʳ
echo zsh
echo steam

installing discord/flatpak/zsh/steam
sudo pacman -Sy --needed discord flatpak git base-devel zsh steam
echo Installing yay...
maindir=$(pwd)
cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
echo Installing flathub and OBS
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install com.obsproject.Studio
echo Installing OhMyZSH with KoPlayz theme...
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
cd ~/.oh-my-zsh/themes
wget https://raw.githubusercontent.com/KoPlayz/omz-themes/main/koplayz.zsh-theme
echo "You can now change the zsh theme to any theme avalible (koplayz, agnoster, etc)"
read -p "Entering nano to change zsh theme (~/.zshrc)"
nano ~/.zshrc
source ~/.zshrc