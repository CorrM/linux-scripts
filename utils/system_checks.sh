#!/bin/bash

# Check if the script is running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_color "$RED" "Please run as root."
        exit 1
    fi
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

# Check if command is exists
check_command() {
    local name=$1
    local command=$2

    if ! command -v $command &> /dev/null; then
        return 1
    fi

    return 0
}

check_command_with_error() {
    local name=$1
    local command=$2

    check_command "$name" "$command"
    local command_found=$?

    if [ $command_found -ne 0 ]; then
        if [ -n "$3" ]; then
            local install_command=$3
            print_color "$RED" "Error: $command command not found. Make sure $name is installed. You can install by \`$install_command\`"
        else
            print_color "$RED" "Error: $command command not found. Make sure $name is installed."
        fi

        return 1
    fi

    return 0
}

# Check if pacman is installed
check_pacman() {
    check_command_with_error "pacman" "pacman --version"
    return $?
}

# Check if yay is installed
check_yay() {
    check_command_with_error "yay" "yay --version"
    return $?
}

# Check if git is installed
check_git() {
    check_command_with_error "git" "git -v"
    return $?
}

# Check if xrandr command is available
check_xrandr() {
    check_command_with_error "xrandr" "xrandr" "pacman -S xorg-xrandr"
    return $?
}

# Check if ALSA is installed
check_alsa() {
    check_command_with_error "ALSA" "amixer" "pacman -S alsa-lib alsa-utils"
    return $?
}

# Check if wine is installed
check_wine() {
    check_command_with_error "wine" "wine"
    return $?
}

# Check if winetricks is installed
check_winetricks() {
    check_command_with_error "winetricks" "winetricks"
    return $?
}
