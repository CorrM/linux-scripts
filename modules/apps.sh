#!/bin/bash

apps_menu() {
    check_root
    if ! check_pacman || ! check_yay; then
        return 1
    fi

    local options=(
        "Back to main menu"
        "Install CoolerControl (CoolerControl is a feature-rich cooling device control application for Linux)"
    )
    while true; do
        show_menu "Applications Installer" "Collection of applications you can install" "${options[@]}"
        choice=$?

        case $choice in
            1) return 0 ;;
            2) apps_install_coolercontrol ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac

        pause
    done
}

apps_install_coolercontrol() {
    print_color "$YELLOW" "Installing CoolerControl..."
    yay -S coolercontrol

    check_command "CoolerControl" "coolercontrol -v"
    local app_installed=$?

    if [ $app_installed -ne 0 ]; then
        print_color "$RED" "Failed to install CoolerControl."
        return 1
    fi

    print_color "$YELLOW" "Enable and start the systemd service..."
    systemctl enable --now coolercontrold

    print_color "$GREEN" "CoolerControl installed successfully."
}
