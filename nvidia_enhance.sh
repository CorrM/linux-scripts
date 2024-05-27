#!/bin/bash

# References:
# https://github.com/devonkinghorn/linux-nvidia-dynamic-power-management-setup
# https://www.reddit.com/r/hyprland/comments/1bjlije/comment/kvvdwot/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
# https://www.youtube.com/watch?v=BH2Chn9N0z8

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
options=("Fix resume from suspend" "Maximize performance" "Quit")
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
    "Maximize performance")
      echo "Maximizing performance..."

      # File path
      conf_file="/etc/modprobe.d/nvidia.conf"
      options=(
        "options nvidia NVreg_UsePageAttributeTable=1"
        "options nvidia NVreg_InitializeSystemMemoryAllocations=0"
        "options nvidia NVreg_DynamicPowerManagement=0x02"
        "options nvidia NVreg_EnableGpuFirmware=0"
        "options nvidia_drm modeset=1 fbdev=1"
      )

      # Check if the file exists and add options if they are not present
      for option in "${options[@]}"; do
        if grep -q "$option" "$conf_file" 2>/dev/null; then
          echo "The option '$option' is already present in $conf_file."
        else
          echo "$option" >> "$conf_file"
          echo "Added the option '$option' to $conf_file."
        fi
      done

      echo "Performance maximization applied."
      break
      ;;
    "Quit")
      echo "Exiting."
      break
      ;;
    *) echo "Invalid option $REPLY";;
  esac
done
