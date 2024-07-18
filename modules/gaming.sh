#!/bin/bash

# Reference:
# https://wiki.archlinux.org/title/Gamemode
# https://wiki.archlinux.org/title/MangoHud

# For NVidia Install cachyOS kernel with that video https://www.youtube.com/watch?v=_FqQ8MCWFlU, then use that video to install GPU drivers https://www.youtube.com/watch?v=0tu1-M_qJos

gaming_menu() {
    check_root

    clear
    print_color "$YELLOW" "===   Gaming Utils   ==="
    print_color "$BLUE" "No specific actions implemented yet."
    print_color "$GREEN" "This module can be expanded with gaming-specific utilities in the future."

    return 1
}
