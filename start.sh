#!/bin/bash

# Source utility scripts
source "$(dirname "$0")/utils/utils.sh"
source "$(dirname "$0")/utils/colors.sh"
source "$(dirname "$0")/utils/menu.sh"
source "$(dirname "$0")/utils/system_checks.sh"

# Source module scripts
source "$(dirname "$0")/modules/pacman.sh"
source "$(dirname "$0")/modules/pkgbuild.sh"
source "$(dirname "$0")/modules/sound.sh"
source "$(dirname "$0")/modules/sddm.sh"
source "$(dirname "$0")/modules/kde_plasma.sh"
source "$(dirname "$0")/modules/vmware.sh"
source "$(dirname "$0")/modules/nvidia.sh"
source "$(dirname "$0")/modules/gaming.sh"
source "$(dirname "$0")/modules/wine.sh"
source "$(dirname "$0")/modules/steam.sh"

# Main menu options
options=(
    "Pacman Utils"
    "PKGBUILD Utils"
    "Sound Utils"
    "SDDM Utils"
    "KDE Plasma Utils"
    "NVIDIA Utils"
    "VMWare Utils"
    "Wine Utils"
    "Gaming Utils"
    "Steam Utils"
    "Quit"
)

# Main menu function
main_menu() {
    while true; do
        # dont wrap the function in "$()" as that called substitution creates subshell call and thats will prevent printing
        show_menu "CorrM Linux Utils Tool" "A comprehensive collection of system utilities" "${options[@]}"
        choice=$?

        case $choice in
            1) pacman_menu ;;
            2) pkgbuild_menu ;;
            3) sound_menu ;;
            4) sddm_menu ;;
            5) kde_plasma_menu ;;
            6) nvidia_menu ;;
            7) vmware_menu ;;
            8) wine_menu ;;
            9) gaming_menu ;;
            10) steam_menu ;;
            ${#options[@]}) print_color "$YELLOW" "Thank you for using the CorrM Utils Tool. Goodbye!"; exit 0 ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac

        # If not "Back to main menu" selected
        if [ "$?" -ne "0" ]; then
            pause
        fi
    done
}

# Run the main menu
check_root
main_menu
