#!/bin/bash

# References:
# https://www.reddit.com/r/vmware/comments/1d2hzvs/unable_to_install_all_modules_error_while/
# https://github.com/nan0desu/vmware-host-modules/wiki
# https://gist.github.com/ddan9/daa3c1d3bce0eb879cd711d144712206
# https://github.com/rune1979/ubuntu-vmmon-vmware-bash/blob/master/wm_autoupdate_key.sh

# Menu function
vmware_menu() {
    check_root
    if ! check_git; then
        return 1
    fi

    local options=(
        "Back to main menu"
        "Install VMWare"
        "Patch VMWare / Fix VMWare (<=VMWare17.5)"
        "Add to DKMS"
        "Clean patch cache"
        "Fix VMWare Network Problems"
        "Uninstall VMWare"
    )
    while true; do
        show_menu "VMWare Utils" "Utilities for VMWare" "${options[@]}"
        choice=$?

        case $choice in
            1) return 0 ;;
            2) vmware_install_vmware ;;
            3) vmware_patch ;;
            4) vmware_add_dkms ;;
            5) vmware_clean_patch_cache ;;
            6) vmware_fix_network ;;
            7) vmware_uninstall ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac
        pause
    done
}

vmware_install_vmware() {
    print_color "$YELLOW" "Installing VMWare..."
    sh VMware-Workstation-Full-17.6.3-24583834.x86_64.bundle --eulas-agreed
}

vmware_patch() {
    print_color "$YELLOW" "Patching VMWare..."

    # Check if vmware-host-modules exists
    if [ ! -d "vmware-host-modules" ]; then
        git clone https://github.com/nan0desu/vmware-host-modules.git
    fi

    cd vmware-host-modules

    # Get patch
    options=("6.9.7+ kernels" "6.9.1 kernels and around")
    select opt in "${options[@]}"; do
        case $opt in
            "6.9.7+ kernels")
                git checkout tmp/workstation-17.5.2-k6.9-sharishth
                break
            ;;

            "6.9.1 and around")
                git checkout tmp/workstation-17.5.2-k6.9.1
                break
            ;;
        esac
    done

    # Compiling
    sudo make clean
    sudo make
    sudo make install

    # Providing tarballs to vmware's tool
    sudo make tarballs
    sudo cp -v vmmon.tar vmnet.tar /usr/lib/vmware/modules/source/
    sudo vmware-modconfig --console --install-all
    sudo modprobe -v vmmon

    print_color "$BLUE" "If that didnt work then make sure you installed kernal linux-header: (match your kernal)"
    print_color "$BLUE" "\t- 'sudo pacman -S linux-headers'"
    print_color "$BLUE" "\t- 'sudo pacman -S linux-cachyos-headers'"
    print_color "$BLUE" "If you already have kernal linux-header and get any problem:"
    print_color "$BLUE" "\t1. REINSTALL kernal linux-header again"
    print_color "$BLUE" "\t2. re-run this script again"

    # Back to main folder
    cd ..
}

vmware_add_dkms() {
    print_color "$YELLOW" "Adding to DKMS..."

    if [ ! -d "vmware-host-modules" ]; then
        echo "vmware-host-modules directory not found. Please run the patching process first."
        exit 1
    fi

    cd vmware-host-modules

    git checkout dkms
    git rev-list master..dkms | git cherry-pick --no-commit --stdin

    # Add dkms
    sudo dkms add .

    # Back to main folder
    cd ..
}

vmware_clean_patch_cache() {
    print_color "$CYAN" "Are you sure you want to clean the patch cache? (y/n)"
    read -r confirmation

    if [ "$confirmation" = "y" ]; then
      echo "Cleaning..."
      rm -rf vmware-host-modules
    else
      echo "Aborted."
    fi
}

vmware_fix_network() {
    print_color "$YELLOW" "Fixing VMWare network problems..."
    sudo systemctl enable --now vmware-networks
    print_color "$GREEN" "VMWare network service has been enabled and started."
}

vmware_uninstall() {
    print_color "$YELLOW" "Uninstalling VMWare..."
    print_color "$CYAN" "Are you sure you want to uninstall VMWare? (y/n)"
    read -r confirmation

    if [ "$confirmation" = "y" ]; then
        sudo vmware-installer -u vmware-workstation
        print_color "$GREEN" "VMWare has been uninstalled."
    else
        print_color "$BLUE" "Uninstall aborted."
    fi
}
