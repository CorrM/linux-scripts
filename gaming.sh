#!/bin/bash

# References:
# https://arch.d3sox.me/gaming/

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Check if yay is installed
if ! command -v yay --version &> /dev/null; then
  echo "yay could not be found. Please install yay."
  exit 1
fi
