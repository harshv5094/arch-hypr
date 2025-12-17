#!/usr/bin/env bash

# Checking if script runner is root #
if [ "$(id -u)" -eq 0 ]; then
  echo "Please don't run this script as root"
  exit 1
fi

# -- Setup Config Folders -- #
setupFolders() {
  # Clonning my repository, also adding safety check #
  if [ ! -d ${CLONE_DIR} ]; then
    git clone ${CLONE_URL} ${CLONE_DIR}

    echo "Copying my config directories"
    for HYPR_DIR in "${HYPR_DIRS[@]}"; do
      if [ -d "$XDG_CONFIG_HOME/$HYPR_DIR" ]; then
        echo -e "$XDG_CONFIG_HOME/$HYPR_DIR exist!\nBacking Up $XDG_CONFIG_HOME/$HYPR_DIR"
        mv "$XDG_CONFIG_HOME/$HYPR_DIR" "$XDG_CONFIG_HOME/${HYPR_DIR}.bak"

        echo -e "Copying $HYPR_DIR to $XDG_CONFIG_HOME"
        cp -rf "$CLONE_DIR/$HYPR_DIR" "$XDG_CONFIG_HOME"
      else
        echo -e "Copying $HYPR_DIR to $XDG_CONFIG_HOME"
        cp -rf "$CLONE_DIR/$HYPR_DIR" "$XDG_CONFIG_HOME"
      fi
    done
  else
    echo -e "$CLONE_DIR exist!"

    echo "** Copying my config directories **"
    for HYPR_DIR in "${HYPR_DIRS[@]}"; do
      cp -rf "$CLONE_DIR/$HYPR_DIR" "$XDG_CONFIG_HOME"
    done
  fi
}

# -- Setup Chaotic AUR -- #
setupChaoticAur() {
  echo "** Getting Chaotic AUR Primary Keys **"
  sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key 3056513887B78AEB

  echo "** Installing Chaotic AUR mirrorlist **"
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
  sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

  # -- Copying my pacman.conf -- #
  echo "** Copying my custom pacman.conf setting **"
  if [ ! -f "/etc/pacman.conf" ]; then
    cp -rf "$CLONE_DIR/pacman.conf" "/etc/"
  else
    mv "/etc/pacman.conf" "/etc/pacman.conf.bak"
    cp -rf "$CLONE_DIR/pacman.conf" "/etc/"
  fi

  echo "** Refreshing mirrorlist **"
  sudo pacman -Syu

  echo "** Installing yay from Chaotic AUR **"
  sudo pacman -S chaotic-aur/paru
}

# -- Setup my window manager -- #
setupLyWindowManager() {
  echo -e "** Setting Up Login Manager (Ly) **"
  $AUR_HELPER -S --noconfirm ly

  LOGIN_MANAGERS=('sddm' 'gdm' 'lightdm' 'lxdm' 'lxdm-gtk3' 'mdm' 'nodm' 'xdm' 'entrance')

  for LOGIN_MANAGER in "${LOGIN_MANAGERS[@]}"; do
    if systemctl list-unit-files | grep -q "^${LOGIN_MANAGER}\.service"; then
      if sudo systemctl --is-active --quiet "$LOGIN_MANAGER"; then
        printf "%b\n" "* Disabling $LOGIN_MANAGER... *"
        sudo systemctl disable "$LOGIN_MANAGER"
      fi
    fi
  done

  echo -e "* Enabling Ly... *"
  # NOTE: https://codeberg.org/fairyglade/ly/releases/tag/v1.3.0
  sudo systemctl disable getty@tty2.service
  sudo systemctl enable ly@tty2.service

  echo "* Copying My Ly config files *"
  if [ -d "/etc/ly/" ]; then
    sudo mv /etc/ly/config.ini /etc/ly/config.ini.bak
    sudo cp -rf "${CLONE_DIR}/ly/config.ini" "/etc/ly/"
  fi

  echo -e "* Ly setup complete! *"
}

setupHyprland() {
  echo -e "*** Starting Hyprland Setup **"

  echo -e "** Installing Hyprland Packages **"
  $AUR_HELPER -S --noconfirm --needed kitty hyprland hyprlock hypridle hyprpicker hyprpaper \
    uwsm rofi xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

  echo -e "** Installing Base tools **"
  $AUR_HELPER -S --noconfirm --needed pavucontrol brightnessctl playerctl network-manager-applet gnome-keyring cpufreqctl \
    wl-clipboard copyq mako blueman bluez bluez-utils waybar mate-polkit mpd mpc rmpc nwg-look \
    libgepub libopenraw xdg-utils xdg-user-dirs xdg-user-dirs-gtk gnome-themes-extra breeze qt6ct qt6-wayland speech-dispatcher cronie

  echo -e "** Installing GUI tools **"
  $AUR_HELPER -S --noconfirm --needed firefox chromium gnome-disk-utility gnome-tweaks gnome-characters \
    transmission-gtk seahorse loupe timeshift evince transmission-gtk baobab \
    gnome-calculator totem nautilus

  echo -e "** Installing Fonts & Icons **"
  $AUR_HELPER -S --noconfirm --needed noto-fonts noto-fonts-emoji noto-fonts-extra ttf-jetbrains-mono-nerd inter-font ttf-firacode-nerd \
    ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common ttf-nerd-fonts-symbols-mono ttf-hanazono noto-fonts-cjk papirus-icon-theme otf-font-awesome

  echo -e "** Installing Hyprland Plugins **"
  $AUR_HELPER -S --noconfirm --needed grimblast-git

  echo -e "** Install AUR Packages Tools **"
  $AUR_HELPER -S --noconfirm --needed visual-studio-code-bin localsend-bin linutil-bin auto-cpufreq xdg-terminal-exec

  echo "** Setting up XDG Default Directories **"
  xdg-user-dirs-update

  echo "** Setting up XDG GTK Default Directories **"
  xdg-user-dirs-gtk-update

  echo "*** Hyprland Setup is finished **"
  rm -rf "$CLONE_DIR"
}

# Global Variables #
CLONE_URL="https://github.com/harshv5094/arch-hypr"
CLONE_DIR="/tmp/arch-hypr"
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
HYPR_DIRS=('hypr' 'mako' 'mpd' 'nwg-look' 'qt6ct' 'rmpc' 'rofi' 'waybar' 'xdg-desktop-portal')

# Change this AUR_HELPER to your choice
AUR_HELPER="paru"

if command -v $AUR_HELPER &>/dev/null; then
  setupFolders
  setupChaoticAur
  setupLyWindowManager
  setupHyprland
else
  echo "** Please install $AUR_HELPER first for this script to work. **"
  exit 1
fi
