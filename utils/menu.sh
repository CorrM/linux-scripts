#!/bin/bash

# Function to show a menu and return the user's choice
show_menu() {
    local title=$1
    local subtitle=$2
    shift 2
    local options=("$@")
    local choice

    while true; do
        clear
        print_color "$YELLOW" "===    $title    ==="
        print_color "$BLUE" "$subtitle"
        echo ""

        for i in "${!options[@]}"; do
            printf "%s${CYAN}%d${NC}) ${options[i]}%s\n" "  " $((i+1))
        done

        echo ""
        print_color "$YELLOW" "Enter your choice:"
        read -r choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            return $choice
        else
            print_color "$RED" "Invalid option. Please try again."
            pause
        fi
    done
}
