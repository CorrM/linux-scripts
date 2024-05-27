#!/bin/bash

yay -Syu hyprland-git hyprpaper-git xdg-desktop-portal-hyprland-git rofi-wayland alacritty-git

ln -s "$(pwd)/alacritty" ~/.config/alacritty
ln -s "$(pwd)/hypr" ~/.config/hypr
