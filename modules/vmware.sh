#!/bin/bash

# References:
# https://www.reddit.com/r/vmware/comments/1d2hzvs/unable_to_install_all_modules_error_while/
# https://github.com/nan0desu/vmware-host-modules/wiki
# https://gist.github.com/ddan9/daa3c1d3bce0eb879cd711d144712206

# Menu function
vmware_menu() {
    check_root
    if ! check_git; then
        return 1
    fi

    local options=("Install VMWare" "Patch VMWare" "Add to DKMS" "Clean patch cache" "Back to main menu")
    while true; do
        show_menu "VMWare Utils" "Utilities for VMWare" "${options[@]}"
        choice=$?

        case $choice in
            0) return 0 ;;
            1) vmware_install_vmware ;;
            2) vmware_patch ;;
            3) vmware_add_dkms ;;
            4) vmware_clean_patch_cache ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac
        pause
    done
}

vmware_install_vmware() {
    print_color "$YELLOW" "Installing VMWare..."
    sh VMware-Workstation-Full-17.5.2-23775571.x86_64.bundle --eulas-agreed
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
            ;;

            "6.9.1 and around")
                git checkout tmp/workstation-17.5.2-k6.9.1
            ;;
        esac
    done

    # Compiling
    make clean
    make
    sudo make install

    # Providing tarballs to vmware's tool
    make tarballs && cp -v vmmon.tar vmnet.tar /usr/lib/vmware/modules/source/ && vmware-modconfig --console --install-all

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
