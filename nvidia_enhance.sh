#!/bin/bash

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Check for NVIDIA GPU
if ! lspci | grep -i nvidia > /dev/null; then
  read -p "NVIDIA GPU not detected. Do you want to continue? (y/n) " choice
  case "$choice" in
    y|Y ) ;;
    * ) echo "Exiting."; exit 1 ;;
  esac
fi

PS3='Please enter your choice: '
options=("Fix resume from suspend" "Quit")
select opt in "${options[@]}"
do
  case $opt in
    "Fix resume from suspend")
      echo "Fixing resume from suspend..."

      # File path
      conf_file="/etc/modprobe.d/nvidia-power-management.conf"
      option="options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp"

      # Check if the file exists and contains the option
      if [ -f "$conf_file" ]; then
        if grep -q "$option" "$conf_file"; then
          echo "The required option is already present in $conf_file."
        else
          echo "$option" >> "$conf_file"
          echo "Added the required option to $conf_file."
        fi
      else
        echo "$option" > "$conf_file"
        echo "Created $conf_file with the required option."
      fi

      # Enable the necessary services
      systemctl enable nvidia-suspend.service
      systemctl enable nvidia-hibernate.service
      systemctl enable nvidia-resume.service

      echo "Resume from suspend fix applied."
      break
      ;;
    "Quit")
      echo "Exiting."
      break
      ;;
    *) echo "Invalid option $REPLY";;
  esac
done
