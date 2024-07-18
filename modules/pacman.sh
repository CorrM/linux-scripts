#!/bin/bash

pacman_menu() {
    check_root
    if ! check_pacman; then
        return 1
    fi

    local options=("Update parallel downloads" "Enable color output" "Back to main menu")
    while true; do
        show_menu "Pacman Utils" "Utilities for Pacman package manager" "${options[@]}"
        choice=$?

        case $choice in
            0) return 0 ;;
            1) pacman_update_parallel_downloads ;;
            2) pacman_update_color_setting ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac

        pause
    done
}

pacman_update_parallel_downloads() {
    print_color "$YELLOW" "Updating parallel downloads..."

    local conf_file="/etc/pacman.conf"

    # Get the number of processors and subtract 2, but ensure it's at least 1
    num_procs=$(nproc --all)
    parallel_downloads=$((num_procs - 2))
    parallel_downloads=$(($parallel_downloads > 1 ? $parallel_downloads : 1))

    # Replace the line in the configuration file
    sed -i "s/^ParallelDownloads.*/ParallelDownloads = $parallel_downloads/" $conf_file

    print_color "$GREEN" "Update parallel downloads applied."
}

pacman_update_color_setting() {
    print_color "$YELLOW" "Enabling color output..."

    local conf_file="/etc/pacman.conf"

    # Look for the line ending with "Color" and replace it with "Color"
    sed -i "s/.*Color$/Color/" $conf_file

    print_color "$GREEN" "Enable color output applied."
}
