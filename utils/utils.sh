#!/bin/bash

# Get user home dir
get_user_home_dir() {
    echo "$(getent passwd $SUDO_USER | cut -d: -f6)"
    return 0
}
