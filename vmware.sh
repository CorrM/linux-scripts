#!/bin/bash

# References:
# https://www.reddit.com/r/vmware/comments/1d2hzvs/unable_to_install_all_modules_error_while/
# https://github.com/nan0desu/vmware-host-modules/wiki

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
  echo "git could not be found. Please install git."
  exit 1
fi

echo "Please enter your choice: "
options=("Install VMWare" "Patch VMWare" "Add to DKMS" "Clean patch cache" "Quit")
select opt in "${options[@]}"; do
  case $opt in
    "Install VMWare")
      echo "Installing VMWare..."
      sh VMware-Workstation-Full-17.5.2-23775571.x86_64.bundle --eulas-agreed
      break
      ;;

    "Patch VMWare")
      echo "Patching VMWare..."

      # Check if vmware-host-modules exists
      if [ ! -d "vmware-host-modules" ]; then
        git clone https://github.com/nan0desu/vmware-host-modules.git
      fi

      # Get patch
      cd vmware-host-modules

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
      make clean
      make
      sudo make install

      # Providing tarballs to vmware's tool
      make tarballs && sudo cp -v vmmon.tar vmnet.tar /usr/lib/vmware/modules/source/ && sudo vmware-modconfig --console --install-all
      break
      ;;

    "Add to DKMS")
      echo "Adding to DKMS..."

      if [ ! -d "vmware-host-modules" ]; then
        echo "vmware-host-modules directory not found. Please run the patching process first."
        exit 1
      fi

      cd vmware-host-modules

      git checkout dkms
      git rev-list master..dkms | git cherry-pick --no-commit --stdin

      # Add dkms
      sudo dkms add .
      break
      ;;

    "Clean patch cache")
      echo "Are you sure you want to clean the patch cache? This will delete the vmware-host-modules directory. (y/n)"
      read -r confirmation

      if [ "$confirmation" = "y" ]; then
        echo "Cleaning..."
        rm -rf vmware-host-modules
      else
        echo "Aborted."
      fi

      break
      ;;

    "Quit")
      echo "Exiting."

      break
      ;;
    *) echo "Invalid option $REPLY";;
  esac
done
