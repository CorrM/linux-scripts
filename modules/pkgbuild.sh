#!/bin/bash

pkgbuild_menu() {
    check_root
    if ! check_pacman; then
        return 1
    fi

    local options=(
        "Back to main menu"
        "Update parallel jobs"
    )
    while true; do
        show_menu "PKGBUILD Utils" "Utilities for PKGBUILD" "${options[@]}"
        choice=$?

        case $choice in
            1) return 0 ;;
            2) pkgbuild_update_parallel_jobs ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac

        pause
    done
}

pkgbuild_update_parallel_jobs() {
    print_color "$YELLOW" "Updating parallel jobs..."

    local conf_file="/etc/makepkg.conf"

    # Get the number of processors and subtract 2, but ensure it's at least 1
    num_procs=$(nproc --all)
    j_value=$((num_procs - 2))
    j_value=$(($j_value > 1 ? $j_value : 1))

    # Update the MAKEFLAGS in the configuration file
    sed -i -E "/MAKEFLAGS/ {
      s/-j[0-9]+/-j$j_value/; t
      s/\"$/ -j$j_value\"/
    }" "$conf_file"

    print_color "$GREEN" "Update parallel jobs applied."
}
