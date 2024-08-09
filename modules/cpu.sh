#!/bin/bash

# References:
# https://wiki.archlinux.org/title/CPU_frequency_scaling

cpu_menu() {
    check_root

    local options=(
        "Back to main menu"
        "Enable AMD power-performance states"
    )
    while true; do
        show_menu "CPU Utils" "Utilities for CPU" "${options[@]}"
        choice=$?

        case $choice in
            1) return 0 ;;
            2) cpu_enable_pstate ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac

        pause
    done
}

cpu_enable_pstate() {
    local GRUB_FILE="/etc/default/grub"
    if [ ! -f "$GRUB_FILE" ]; then
        print_color "$RED" "Error: $GRUB_FILE does not exist."
        exit 1
    fi

    print_color "$YELLOW" "Found '$GRUB_FILE'. Proceeding with modifications."

    # Attempt to update amd_pstate=active
    sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ {
        s/ amd_pstate=[^ "]*//g
        s/"$/"/
        s/" *"/"/
        s/"$/ amd_pstate=active"/
    }' "$GRUB_FILE"

    # Check if the modification was successful
    if [ $? -eq 0 ]; then
        if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_FILE"; then
            print_color "$GREEN" "Updated GRUB_CMDLINE_LINUX_DEFAULT with amd_pstate=active"
        else
            print_color "$RED" "Error: GRUB_CMDLINE_LINUX_DEFAULT not found in $GRUB_FILE"
            print_color "$RED" "Please check your GRUB configuration manually."
            exit 1
        fi
    else
        print_color "$RED" "Error: Failed to modify $GRUB_FILE"
        exit 1
    fi

    print_color "$GREEN" "Modifications completed."

    # Check if update-grub is available
    if command -v update-grub &> /dev/null; then
        print_color "$YELLOW" "Updating GRUB configuration..."
        update-grub
        if [ $? -eq 0 ]; then
            print_color "$GREEN" "GRUB configuration updated successfully."
        else
            print_color "$RED" "Error: Updating GRUB configuration. Please run 'sudo update-grub' manually."
        fi
    else
        print_color "$YELLOW" "update-grub command not found. Please update your GRUB configuration manually."
    fi
}
