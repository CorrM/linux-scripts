#!/bin/bash

# Menu function
sound_menu() {
    if ! check_alsa; then
        return 1
    fi

    local options=(
        "Back to main menu"
        "Unmute all sound cards"
    )
    while true; do
        show_menu "Sound Utils" "Utilities for sound" "${options[@]}"
        choice=$?

        case $choice in
            1) return 0 ;;
            2) sound_unmute_all_audio_cards ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac
        pause
    done
}

sound_unmute_all_audio_cards() {
    print_color "$YELLOW" "Unmuting all sound cards..."

    # Get a list of all available sound cards
    cards=$(aplay -l | grep -oP 'card \d+' | awk '{print $2}' | sort -u)

    # Check if any sound cards were found
    if [ -z "$cards" ]; then
        print_color "$RED" "No sound cards found."
        return 1
    fi

    # Iterate over each sound card and set Auto-Mute Mode to Disabled
    for card in $cards; do
        # Check if the 'Auto-Mute Mode' control exists for the current card
        if ! amixer -c $card scontrols | grep -q 'Auto-Mute Mode'; then
            print_color "$RED" "[Card ${card}] Auto-Mute Mode control NOT found"
            continue
        fi

        # Set 'Auto-Mute Mode' to Disabled
        amixer -c $card sset 'Auto-Mute Mode' Disabled -q >/dev/null

        # Check if the command was successful
        if [ $? -eq 0 ]; then
            print_color "$GREEN" "[Card $card] Auto-Mute Mode set to Disabled"
        else
            print_color "$RED" "[Card $card] Failed to set Auto-Mute Mode to Disabled"
        fi
    done

    return 0
}
