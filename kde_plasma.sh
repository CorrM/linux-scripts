#!/bin/bash

# References:
# https://unix.stackexchange.com/questions/277909/updated-my-arch-linux-server-and-now-i-get-tmux-need-utf-8-locale-lc-ctype-bu

# Check if current DE is plasma
if [ "$DESKTOP_SESSION" != "plasma" ]; then
    echo "This script is designed for use within an plasma desktop environment."
    exit 1
fi

options=("Fast window preview" "Fix locale" "Quit")
select opt in "${options[@]}"; do
  case $opt in
    "Fast window preview")
      kwriteconfig6 --file ~/.config/plasmarc --group PlasmaToolTips --key Delay 1
      break
      ;;

    "Fix locale") # Detected locale "C" with character encoding "ANSI_X3.4-1968", which is not UTF-8.
      sudo localectl set-locale LANG=en_GB.UTF-8
      break
      ;;

    "Quit")
      echo "Exiting."
      break
      ;;
    *) echo "Invalid option $REPLY";;
  esac
done
