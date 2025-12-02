#!/usr/bin/env bash

# Define the menu options
options="Lock\nLogout\nHibernate\nReboot\nPoweroff\nSuspend"

# Show the menu using Rofi
choice=$(echo "$options" | rofi -dmenu -i -p "⏻ " -lines 5 -width 20)

case "$choice" in
Lock)
  # Lock the screen
  hyprctl dispatch exec hyprlock
  ;;
Logout)
  # Log out
  hyprctl dispatch exit
  ;;
Hibernate)
  # Hibernate the system
  systemctl hibernate
  ;;
Reboot)
  # Reboot the system
  systemctl reboot
  ;;
Poweroff)
  # Shutdown the system
  systemctl poweroff
  ;;
Suspend)
  systemctl suspend
  ;;
*)
  # Exit without doing anything
  exit 0
  ;;
esac
