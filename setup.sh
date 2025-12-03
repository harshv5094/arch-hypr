#!/usr/bin/env bash

# Checking if script runner is root #
if [ "$(id -u)" -eq 0 ]; then
  echo "Please don't run this script as root"
  exit 1
fi

# Global Variables #
CLONE_URL="https://github.com/harshv5094/arch-hypr"
CLONE_DIR="/tmp/arch-hypr"
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config/}
HYPR_DIRS=('hypr' 'mako' 'mpd' 'nwg-look' 'qt6ct' 'rmpc' 'rofi' 'waybar' 'xdg-desktop-portal')

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

  echo "Copying my config directories"
  for HYPR_DIR in "${HYPR_DIRS[@]}"; do
    cp -rf "$CLONE_DIR/$HYPR_DIR" "$XDG_CONFIG_HOME"
  done
fi

setupLyWindowManager() {
  echo -e "** Setting Up Login Manager (Ly) **"
  paru -S --noconfirm ly

  LOGIN_MANAGERS=('sddm' 'gdm' 'lightdm' 'lxdm' 'lxdm-gtk3' 'mdm' 'nodm' 'xdm' 'entrance')

  for LOGIN_MANAGER in "${LOGIN_MANAGERS[@]}"; do
    if systemctl list-unit-files | grep -q "^${LOGIN_MANAGER}\.service"; then
      if sudo systemctl --is-active --quiet "$LOGIN_MANAGER"; then
        printf "%b\n" "* Disabling $LOGIN_MANAGER... *"
        sudo systemctl disable "$LOGIN_MANAGER"
        sudo systemctl stop "$LOGIN_MANAGER"
      fi
    fi
  done

  echo -e "* Enabling Ly... *"
  sudo systemctl enable ly.service

  echo "* Copying My Ly config files *"
  if [ -e /etc/ly ]; then
    sudo mv /etc/ly/config.ini /etc/ly/config.ini.bak
    sudo cp -rf "${CLONE_DIR}/ly/config.ini" "/etc/ly/"
  fi

  echo -e "* Ly setup complete! *"
}

setupHyprland() {
  echo -e "*** Starting Hyprland Setup **"

  echo -e "** Installing Hyprland Packages **"
  paru -S --noconfirm kitty hyprland hyprlock hypridle hyprpicker hyprpaper uwsm rofi xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

  echo -e "** Installing Base tools **"
  paru -S --noconfirm pavucontrol brightnessctl playerctl network-manager-applet gnome-keyring cpufreqctl \
    wl-clipboard copyq mako blueman bluez bluez-utils waybar mate-polkit mpd mpc rmpc nwg-look \
    xdg-utils xdg-user-dirs xdg-user-dirs-gtk gnome-themes-extra breeze qt6ct qt6-wayland speech-dispatcher cronie

  echo -e "** Installing GUI tools **"
  paru -S --noconfirm firefox gnome-disk-utility gnome-tweaks gnome-text-editor gnome-clocks gnome-characters \
    transmission-gtk seahorse loupe timeshift evince transmission-gtk baobab \
    gnome-calculator totem gimp

  echo -e "** Installing File Manager **"
  paru -S --noconfirm thunar tumbler libgepub libopenraw thunar-volman thunar-media-tags-plugin thunar-archive-plugin xarchiver

  echo -e "** Installing Fonts & Icons **"
  paru -S --noconfirm noto-fonts noto-fonts-emoji noto-fonts-extra ttf-jetbrains-mono-nerd inter-font ttf-firacode-nerd \
    ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common ttf-nerd-fonts-symbols-mono ttf-hanazono noto-fonts-cjk papirus-icon-theme otf-font-awesome

  echo -e "** Installing Hyprland Plugins **"
  paru -S --noconfirm grimblast-git

  echo -e "** Install AUR Packages Tools **"
  paru -S --noconfirm visual-studio-code-bin localsend-bin linutil-bin auto-cpufreq xdg-terminal-exec

  echo "** Setting up XDG Default Directories **"
  xdg-user-dirs-update

  echo "** Setting up XDG GTK Default Directories **"
  xdg-user-dirs-gtk-update

  echo "*** Hyprland Setup is finished **"
  rm -rf "$CLONE_DIR"
}

if command -v paru &>/dev/null; then
  setupLyWindowManager
  setupHyprland
else
  echo "** Please install Paru first **"
  exit 1
fi
