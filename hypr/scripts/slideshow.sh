#!/usr/bin/env bash

main() {
  hyprctl hyprpaper unload all
  killall hyprpaper

  echo "splash = false" >~/.config/hypr/hyprpaper.conf
  echo "ipc = true" >>~/.config/hypr/hyprpaper.conf
  # monitors=$(hyprctl monitors -j | jq -r ".[] | .name")

  # for monitor in $monitors; do
  #   wallpaper=$(fd ".png|.jpg|.jpeg|.webp" ~/Pictures/wallpapers/ | shuf -n1)
  #   echo "preload = $wallpaper" >>~/.config/hypr/hyprpaper.conf
  #   echo "wallpaper = $monitor,$wallpaper" >>~/.config/hypr/hyprpaper.conf
  # done

  wallpaper=$(fd ".png|.jpg|.jpeg|.webp" ~/Pictures/wallpapers/ | shuf -n1)
  echo "preload = $wallpaper" >>~/.config/hypr/hyprpaper.conf
  echo "wallpaper = ,$wallpaper" >>~/.config/hypr/hyprpaper.conf

  echo "# BACKGROUND
background {
    blur_passes = 3
    contrast = 1
    brightness = 0.5
    vibrancy = 0.2
    vibrancy_darkness = 0.2
    path = $wallpaper   # supports png, jpg, webp (no animations, though)
  }
" >~/.config/hypr/sections/lock-background.conf

  hyprpaper &
  sleep 1m
  main
}

if [ ! -d "$HOME/Pictures/wallpapers/" ]; then
  notify-send -u cirtical "$HOME/Pictures/wallpapers/ does not exist. Please create this directory and store your wallpapers there."
  exit 1
else
  main
fi
