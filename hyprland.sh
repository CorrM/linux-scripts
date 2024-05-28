#!/bin/bash

yay -Syu otf-font-awesome ttf-arimo-nerd noto-fonts hyprland-git hyprpaper-git xdg-desktop-portal-hyprland-git rofi-wayland alacritty-git hypridle-git hyprlock-git waybar wlogout nwg-look

ln -s "$(pwd)/alacritty" ~/.config
ln -s "$(pwd)/hypr" ~/.config
ln -s "$(pwd)/waybar" ~/.config
