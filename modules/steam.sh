#!/bin/bash

# Menu function
steam_menu() {
    local options=("Fix MimeType" "Back to main menu")
    while true; do
        show_menu "Steam Utils" "Utilities for Steam" "${options[@]}"
        choice=$?

        case $choice in
            1) steam_fix_mimetype ;;
            ${#options[@]}) return 0 ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac
        pause
    done
}

# Function to fix MimeType
steam_fix_mimetype() {
    print_color "$YELLOW" "Fixing MimeType..."

    local user_home=$(get_user_home_dir)
    local file_path="$user_home/.local/share/applications/steam.desktop"

    # Check if the file exists
    if [ ! -f "$file_path" ]; then
        print_color "$RED" "Error: steam.desktop file not found! (Is Steam installed?)"
        return 1
    fi

    # Use sed to replace the line starting with "MimeType="
    if sed -i "/^MimeType=/c\\MimeType=x-scheme-handler/steam" "$file_path"; then
        print_color "$GREEN" "steam.desktop updated successfully."
        print_color "$YELLOW" "Restart steam required to apply changes."
    else
        print_color "$RED" "Error: Failed to update steam.desktop."
        return 1
    fi

    return 0
}
