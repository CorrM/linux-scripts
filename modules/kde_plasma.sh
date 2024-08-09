#!/bin/bash

# References:
# https://unix.stackexchange.com/questions/277909/updated-my-arch-linux-server-and-now-i-get-tmux-need-utf-8-locale-lc-ctype-bu

kde_plasma_menu() {
    if ! check_plasma; then
        return 1
    fi

    local options=(
        "Back to main menu"
        "Fast window preview"
        "Fix locale"
    )
    while true; do
        show_menu "KDE Plasma Utils" "Utilities for KDE Plasma" "${options[@]}"
        choice=$?

        case $choice in
            1) return 0 ;;
            2) kde_plasma_fast_window_preview ;;
            3) kde_plasma_fix_locale ;;
            4) kde_plasma_reset ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac
        pause
    done
}

kde_plasma_fast_window_preview() {
    kwriteconfig6 --file ~/.config/plasmarc --group PlasmaToolTips --key Delay 1
    print_color "$GREEN" "Fast window preview enabled."
}

kde_plasma_fix_locale() {
    sudo localectl set-locale LANG=en_GB.UTF-8
    print_color "$GREEN" "Locale set to en_GB.UTF-8."
}

kde_plasma_reset() {
    print_color "$CYAN" "Are you sure you want to reset KDE Plasma? (y/n)"
    read -r confirmation

    if [ "$confirmation" = "y" ]; then
        echo "Deleting..."
        rm ~/.config/plasma-org.kde.plasma.desktop-appletsrc
        rm ~/.config/plasmashellrc
    else
        echo "Aborted."
    fi
}
