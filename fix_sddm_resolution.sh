#!/bin/bash

# Check for root permissions
if [[ $EUID -ne 0 ]]; then
    echo "This script requires root privileges to run. Please run it with sudo."
    exit 1
fi

# Check if current session is x11
# https://www.reddit.com/r/archlinux/comments/143b6we/how_to_display_login_screen_sddm_on_a_single/
if [ "$XDG_SESSION_TYPE" != "x11" ]; then
    echo "This script is designed for use within an X11 session environment."
    exit 1
fi

# Check if SDDM is the window manager
if [[ $(systemctl is-active sddm.service) != "active" ]]; then
    read -p "SDDM is not the current display manager. Are you sure you want to continue? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Check if /etc/sddm.conf exists and is not empty
# https://www.reddit.com/r/archlinux/comments/52ehk8/comment/d7jl2gz/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
if [[ ! -s /etc/sddm.conf ]]; then
    read -p "/etc/sddm.conf does not exist or is empty. Do you want to create example config? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        sddm --example-config | sudo tee /etc/sddm.conf
        if [[ $? -ne 0 ]]; then
            echo "Failed to create /etc/sddm.conf. Please create it manually."
            exit 1
        fi
    else
        echo "Please create /etc/sddm.conf to proceed."
        exit 1
    fi
fi

# Get the output of the xrandr command
xrandr_output=$(/usr/bin/xrandr)

# Parse connected monitors and their resolutions with refresh rates
connected_monitors=()
declare -A monitor_resolutions

current_monitor=""
while IFS= read -r line; do
    if [[ "$line" == *" connected"* ]]; then
        # Extract monitor name
        monitor_name=$(echo "$line" | awk '{print $1}')
        connected_monitors+=("$monitor_name")
        current_monitor="$monitor_name"
        monitor_resolutions["$current_monitor"]=""
    elif [[ "$line" =~ ^[[:space:]]+([0-9]+x[0-9]+)[[:space:]]+([0-9.]+)\*?\+? ]]; then
        # Extract resolution and refresh rate
        resolution=${BASH_REMATCH[1]}
        refresh_rate=${BASH_REMATCH[2]}
        monitor_resolutions["$current_monitor"]+="$resolution@$refresh_rate "
    fi
done <<< "$xrandr_output"

# Ask the user to select a primary monitor
echo ""
echo "Please select the primary monitor:"
select primary_monitor in "${connected_monitors[@]}"; do
    if [[ -n "$primary_monitor" ]]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Ask the user to select a resolution and refresh rate for the primary monitor
echo ""
echo "Available resolutions and refresh rates for $primary_monitor:"
resolutions=(${monitor_resolutions[$primary_monitor]})
select res_rate in "${resolutions[@]}"; do
    if [[ -n "$res_rate" ]]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Prepare the xrandr command to set the primary monitor and resolution
# https://github.com/sddm/sddm/issues/958#issuecomment-353714073
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
echo "A backup of the original Xsetup file has been created at $backup_file"

# Insert the xrandr command into the Xsetup file
awk -v cmd="$xrandr_command" -v turn_off="$turn_off_commands" '
    BEGIN {inserted=0}
    /^#/ {print; next}
    !inserted {print cmd; printf turn_off; inserted=1}
    {print}
' "$xsetup_file" > "$xsetup_file.new"

# Move the new file to replace the original
mv "$xsetup_file.new" "$xsetup_file"

echo "The primary monitor has been set to $primary_monitor with resolution and refresh rate $res_rate, and other monitors have been turned off."
