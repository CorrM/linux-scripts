#!/bin/bash

# References:
# https://forum.winehq.org/viewtopic.php?t=36871
# https://www.reddit.com/r/linux4noobs/comments/firqs9/getting_windows_wpf_applications_to_run_with_wine/
# https://www.winehq.org/pipermail/wine-bugs/2020-April/534007.html
# https://github.com/Winetricks/winetricks/issues/2051

# Menu function
wine_menu() {
    check_root
    if ! check_yay || ! check_wine || ! check_winetricks; then
        return 1
    fi

    local options=(
        "Back to main menu"
        "Install wine-tkg"
        "Fix WPF for default prefix"
        "Delete default prefix"
    )
    while true; do
        show_menu "Wine Utils" "Utilities for Wine" "${options[@]}"
        choice=$?

        case $choice in
            1) return 0 ;;
            2) wine_install_wine_tkg ;;
            3) wine_fix_wpf_applications ;;
            4) wine_delete_default_prefix ;;
            *) print_color "$RED" "Invalid option. Please try again." ;;
        esac
        pause
    done
}

wine_install_wine_tkg() {
    print_color "$YELLOW" "Installing wine-tkg..."

    # Make cache folder
    if [ -d "wine-cache" ]; then
        rm -rf wine-cache
    fi

    mkdir wine-cache
    cd wine-cache

    # Download wine
    wget -P ./ --no-check-certificate --no-proxy https://nightly.link/Frogging-Family/wine-tkg-git/workflows/wine-arch/master/wine-tkg-build.zip

    # Install
    unzip wine-tkg-build.zip
    yay -U wine-tkg-*.pkg.tar.zst

    # Delete cache
    rm -rf wine-cache

    # Back to main folder
    cd ..
}

wine_fix_wpf_applications() {
    if ! check_wine; then
        return 1
    fi

    print_color "$YELLOW" "Fixing WPF applications for default prefix..."

    # winetricks remove_mono
    winetricks -q dotnet48 d3dcompiler_47

    # Workaround for WPF https://github.com/Winetricks/winetricks/issues/2051
    wine reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Avalon.Graphics" /v DisableHWAcceleration /t REG_DWORD /d 1 /f
}

wine_delete_default_prefix() {
    if ! check_wine; then
        return 1
    fi

    print_color "$CYAN" "Are you sure you want to delete the default wine prefix? (y/n)"
    read -r confirmation

    if [ "$confirmation" = "y" ]; then
        echo "Deleting..."
        rm -rf ~/.wine
    else
        echo "Aborted."
    fi
}
