#!/bin/bash

# References:
# https://unix.stackexchange.com/questions/277909/updated-my-arch-linux-server-and-now-i-get-tmux-need-utf-8-locale-lc-ctype-bu

kde_plasma_menu() {
    if ! check_plasma; then
        return 1
    fi

    local options=("Fast window preview" "Fix locale" "Back to main menu")
    while true; do
        show_menu "KDE Plasma Utils" "Utilities for KDE Plasma" "${options[@]}"
        choice=$?

        case $choice in
            1)
                kwriteconfig6 --file ~/.config/plasmarc --group PlasmaToolTips --key Delay 1
                print_color "$GREEN" "Fast window preview enabled."
                ;;
            2)
                sudo localectl set-locale LANG=en_GB.UTF-8
                print_color "$GREEN" "Locale set to en_GB.UTF-8."
                ;;
            ${#options[@]}) return 0 ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac
        pause
    done
}
