#!/bin/bash

# Check if amixer command is available
if ! command -v amixer &> /dev/null; then
    echo "Error: amixer command not found. Make sure ALSA is installed. You can install by \`sudo pacman -S alsa-lib alsa-utils\`" >&2
    exit 1
fi

# Get a list of all available sound cards
cards=$(aplay -l | grep -oP 'card \d+' | awk '{print $2}' | sort -u)

# Check if any sound cards were found
if [ -z "$cards" ]; then
    echo "No sound cards found." >&2
    exit 1
fi

# Iterate over each sound card and set Auto-Mute Mode to Disabled
for card in $cards; do
    # Check if the 'Auto-Mute Mode' control exists for the current card
    if ! amixer -c $card scontrols | grep -q 'Auto-Mute Mode'; then
        echo -e "card ${card}: Auto-Mute Mode control \033[0;31m'NOT found'\033[0m" >&2
        continue
    fi

    # Set 'Auto-Mute Mode' to Disabled
    amixer -c $card sset 'Auto-Mute Mode' Disabled -q >/dev/null

    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo -e "card $card: Auto-Mute Mode set to '\033[0;32mDisabled\033[0m'"
    else
        echo "card $card: Failed to set Auto-Mute Mode to Disabled" >&2
    fi
done
