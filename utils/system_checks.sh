#!/bin/bash

# Check if the script is running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_color "$RED" "Please run as root."
        exit 1
    fi
}

# Check if pacman is installed
check_pacman() {
    if ! command -v pacman --version &> /dev/null; then
        print_color "$RED" "Error: pacman command not found. Make sure pacman is installed."
        return 1
    fi
    return 0
}

# Check if SDDM is the display manager
check_sddm() {
    if [[ $(systemctl is-active sddm.service) != "active" ]]; then
        read -p "SDDM is not the current display manager. Are you sure you want to continue? (y/n): " choice
        if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
            return 1
        fi
    fi
    return 0
}

# Check for NVIDIA GPU
check_nvidia() {
    if ! lspci | grep -i nvidia > /dev/null; then
        read -p "NVIDIA GPU not detected. Do you want to continue? (y/n) " choice
        case "$choice" in
            y|Y ) return 0 ;;
            * ) return 1 ;;
        esac
    fi
    return 0
}

# Check if current DE is plasma
check_plasma() {
    if [ "$DESKTOP_SESSION" != "plasma" ]; then
        print_color "$RED" "This option is designed for use within a Plasma desktop environment."
        return 1
    fi
    return 0
}

# Check if current session is x11
check_x11() {
    if [ "$XDG_SESSION_TYPE" != "x11" ]; then
        print_color "$RED" "This option is designed for use within an X11 session environment."
        return 1
    fi
    return 0
}

# Check if yay is installed
check_yay() {
    if ! command -v yay &> /dev/null; then
        print_color "$RED" "yay could not be found. Please install yay."
        exit 1
    fi
}

# Check if git is installed
check_git() {
    if ! command -v git -v &> /dev/null; then
        print_color "$RED" "git could not be found. Please install git."
        return 1
    fi
    return 0
}

# Check if xrandr command is available
check_xrandr() {
    if ! command -v xrandr &> /dev/null; then
        print_color "$RED" "Error: xrandr command not found. Make sure xrandr is installed. You can install by \`sudo pacman -S xorg-xrandr\`"
        return 1
    fi
    return 0
}

# Check if ALSA is installed
check_alsa() {
    if ! command -v amixer &> /dev/null; then
        print_color "$RED" "amixer could not be found. Please install ALSA. You can install by \`sudo pacman -S alsa-lib alsa-utils\`"
        return 1
    fi
    return 0
}

# Check if wine is installed
check_wine() {
    if ! command -v wine &> /dev/null; then
        print_color "$RED" "wine could not be found. Please install wine."
        return 1
    fi
    return 0
}

# Check if winetricks is installed
check_winetricks() {
    if ! command -v winetricks &> /dev/null; then
        print_color "$RED" "winetricks could not be found. Please install winetricks."
        return 1
    fi
    return 0
}
