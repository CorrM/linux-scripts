#!/bin/bash

# References:
# https://github.com/devonkinghorn/linux-nvidia-dynamic-power-management-setup
# https://www.reddit.com/r/hyprland/comments/1bjlije/comment/kvvdwot/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
# https://www.youtube.com/watch?v=BH2Chn9N0z8

nvidia_menu() {
    check_root
    if ! check_nvidia; then
        return 1
    fi

    local options=(
        "Back to main menu"
        "Fix resume from suspend"
        "Maximize performance"
    )
    while true; do
        show_menu "NVIDIA Utils" "Utilities for NVIDIA GPUs" "${options[@]}"
        choice=$?

        case $choice in
            1) return 0 ;;
            2) nvidia_fix_resume_from_suspend ;;
            3) nvidia_maximize_performance ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac

        pause
    done
}

nvidia_fix_resume_from_suspend() {
    print_color "$YELLOW" "Fixing resume from suspend..."

    local conf_file="/etc/modprobe.d/nvidia-power-management.conf"
    local option="options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp"

    if [ -f "$conf_file" ]; then
        if grep -q "$option" "$conf_file"; then
            print_color "$GREEN" "The required option is already present in $conf_file."
        else
            echo "$option" >> "$conf_file"
            print_color "$GREEN" "Added the required option to $conf_file."
        fi
    else
        echo "$option" > "$conf_file"
        print_color "$GREEN" "Created $conf_file with the required option."
    fi

    sudo systemctl enable nvidia-suspend.service
    sudo systemctl enable nvidia-hibernate.service
    sudo systemctl enable nvidia-resume.service

    print_color "$GREEN" "Resume from suspend fix applied."
}

nvidia_maximize_performance() {
    print_color "$YELLOW" "Maximizing performance..."

    local conf_file="/etc/modprobe.d/nvidia.conf"
    local options=(
        "options nvidia NVreg_UsePageAttributeTable=1"
        "options nvidia NVreg_InitializeSystemMemoryAllocations=0"
        "options nvidia NVreg_DynamicPowerManagement=0x02"
        "options nvidia NVreg_EnableGpuFirmware=0"
        "options nvidia_drm modeset=1"
        "options nvidia_drm fbdev=1"
    )

    for option in "${options[@]}"; do
        if grep -q "$option" "$conf_file" 2>/dev/null; then
            print_color "$YELLOW" "The option '$option' is already present."
        else
            echo "$option" >> "$conf_file"
            print_color "$GREEN" "Added the option '$option'."
        fi
    done

    mkinitcpio -P

    print_color "$GREEN" "Performance maximization applied."
    print_color "$YELLOW" "For better performance, consider using a custom kernel such as Zen or CachyOs."
}
