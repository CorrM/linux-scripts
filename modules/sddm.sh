#!/bin/bash

# References:
# https://github.com/sddm/sddm/issues/958#issuecomment-353714073

sddm_menu() {
    check_root
    if ! check_xrandr || ! check_x11 || ! check_sddm; then
        return 1
    fi

    sddm_configure_sddm

    return 0
}

sddm_configure_sddm() {
    # Check if /etc/sddm.conf exists and is not empty
    if [[ ! -s /etc/sddm.conf ]]; then
        read -p "/etc/sddm.conf does not exist or is empty. Do you want to create example config? (y/n): " choice
        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
            sddm --example-config | tee /etc/sddm.conf
            if [[ $? -ne 0 ]]; then
                print_color "$RED" "Failed to create /etc/sddm.conf. Please create it manually."
                return
            fi
        else
            print_color "$RED" "Please create /etc/sddm.conf to proceed."
            return
        fi
    fi

    # Check if the desktop session is plasma
    if [[ "$DESKTOP_SESSION" == "plasma" ]]; then
        read -p "Detected Plasma session. Do you want to copy the display and input configuration for SDDM? (y/n): " choice
        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
            sddm_copy_plasma_config
        fi
    fi

    sddm_configure_primary_monitor
}

sddm_copy_plasma_config() {
    # Copy kwinoutputconfig.json for display configuration
    if [[ -f ~/.config/kwinoutputconfig.json ]]; then
        cp ~/.config/kwinoutputconfig.json /var/lib/sddm/.config/
        chown sddm:sddm /var/lib/sddm/.config/kwinoutputconfig.json
        print_color "$GREEN" "Copied display configuration to SDDM."
    else
        print_color "$YELLOW" "Display configuration file ~/.config/kwinoutputconfig.json not found."
    fi

    # Copy kcminputrc for input configuration
    if [[ -f ~/.config/kcminputrc ]]; then
        cp ~/.config/kcminputrc /var/lib/sddm/.config/
        chown sddm:sddm /var/lib/sddm/.config/kcminputrc
        print_color "$GREEN" "Copied input configuration to SDDM."
    else
        print_color "$YELLOW" "Input configuration file ~/.config/kcminputrc not found."
    fi

    print_color "$YELLOW" "You may need to open Plasma's System Settings and navigate to Startup and Shutdown > Login Screen (SDDM) and click \"Apply Plasma Settings...\""
}

sddm_configure_primary_monitor() {
    # Get the output of the xrandr command
    xrandr_output=$(/usr/bin/xrandr)

    # Parse connected monitors and their resolutions with refresh rates
    connected_monitors=()
    declare -A monitor_resolutions

    current_monitor=""
    while IFS= read -r line; do
        if [[ "$line" == *" connected"* ]]; then
            monitor_name=$(echo "$line" | awk '{print $1}')
            connected_monitors+=("$monitor_name")
            current_monitor="$monitor_name"
            monitor_resolutions["$current_monitor"]=""
        elif [[ "$line" =~ ^[[:space:]]+([0-9]+x[0-9]+)[[:space:]]+([0-9.]+)\*?\+? ]]; then
            resolution=${BASH_REMATCH[1]}
            refresh_rate=${BASH_REMATCH[2]}
            monitor_resolutions["$current_monitor"]+="$resolution@$refresh_rate "
        fi
    done <<< "$xrandr_output"

    # Ask the user to select a primary monitor
    echo ""
    print_color "$YELLOW" "Please select the primary monitor:"
    select primary_monitor in "${connected_monitors[@]}"; do
        if [[ -n "$primary_monitor" ]]; then
            break
        else
            print_color "$RED" "Invalid selection. Please try again."
        fi
    done

    # Ask the user to select a resolution and refresh rate for the primary monitor
    echo ""
    print_color "$YELLOW" "Available resolutions and refresh rates for $primary_monitor:"
    resolutions=(${monitor_resolutions[$primary_monitor]})
    select res_rate in "${resolutions[@]}"; do
        if [[ -n "$res_rate" ]]; then
            break
        else
            print_color "$RED" "Invalid selection. Please try again."
        fi
    done

    # Prepare the xrandr command to set the primary monitor and resolution
    xrandr_command="/usr/bin/xrandr --output \"$primary_monitor\" --primary --mode ${res_rate%@*} --rate ${res_rate#*@}"

    # Prepare the commands to turn off other monitors
    turn_off_commands=""
    for monitor in "${connected_monitors[@]}"; do
        if [[ "$monitor" != "$primary_monitor" ]]; then
            turn_off_commands+="/usr/bin/xrandr --output \"$monitor\" --off\n"
        fi
    done

    # Modify the /usr/share/sddm/scripts/Xsetup file
    xsetup_file="/usr/share/sddm/scripts/Xsetup"

    # Create a backup of the Xsetup file
    backup_file="$xsetup_file.bak"
    cp "$xsetup_file" "$backup_file"
    chmod 644 "$backup_file"
    print_color "$BLUE" "A backup of the original Xsetup file has been created at $backup_file"

    # Insert the xrandr command into the Xsetup file
    awk -v cmd="$xrandr_command" -v turn_off="$turn_off_commands" '
        BEGIN {inserted=0}
        /^#/ {print; next}
        !inserted {print cmd; printf turn_off; inserted=1}
        {print}
    ' "$xsetup_file" > "$xsetup_file.new"

    # Move the new file to replace the original
    mv "$xsetup_file.new" "$xsetup_file"
    chmod 755 "$xsetup_file"

    print_color "$GREEN" "The primary monitor has been set to $primary_monitor with resolution and refresh rate $res_rate, and other monitors have been turned off."
}
