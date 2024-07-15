#!/bin/bash

# Source utility scripts
source "$(dirname "$0")/utils/utils.sh"
source "$(dirname "$0")/utils/colors.sh"
source "$(dirname "$0")/utils/menu.sh"
source "$(dirname "$0")/utils/system_checks.sh"

# Source module scripts
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
    "Sound Utils"
    "SDDM Utils"
    "KDE Plasma Utils"
    "VMWare Utils"
    "NVIDIA Utils"
    "Gaming Utils"
    "Wine Utils"
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
            1) sound_menu ;;
            2) sddm_menu ;;
            3) kde_plasma_menu ;;
            4) vmware_menu ;;
            5) nvidia_menu ;;
            6) gaming_menu ;;
            7) wine_menu ;;
            8) steam_menu ;;
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
