#!/bin/bash

# References:
# https://forum.winehq.org/viewtopic.php?t=36871
# https://www.reddit.com/r/linux4noobs/comments/firqs9/getting_windows_wpf_applications_to_run_with_wine/
# https://www.winehq.org/pipermail/wine-bugs/2020-April/534007.html
# https://github.com/Winetricks/winetricks/issues/2051

# Check if wine is installed
if ! command -v wine &> /dev/null; then
  echo "wine could not be found. Please install wine."
  exit 1
fi

# Check if winetricks is installed
if ! command -v winetricks &> /dev/null; then
  echo "winetricks could not be found. Please install winetricks."
  exit 1
fi

# Check if yay is installed
if ! command -v yay --version &> /dev/null; then
  echo "yay could not be found. Please install yay."
  exit 1
fi

options=("Install wine-tkg" "Install dotnet48 and d3dcompiler_47 for default prefix" "Delete default prefix" "Quit")
select opt in "${options[@]}"; do
  case $opt in
    "Install wine-tkg")
      echo "Install wine-tkg..."

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

      break
    ;;

    "Install dotnet48 and d3dcompiler_47 for default prefix")
        echo "Install dotnet48 and d3dcompiler_47..."

        winetricks remove_mono
        winetricks -q dotnet48 d3dcompiler_47

        # Workaround for WPF https://github.com/Winetricks/winetricks/issues/2051
        wine reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Avalon.Graphics" /v DisableHWAcceleration /t REG_DWORD /d 1 /f

        break
      ;;

    "Delete default prefix")
      echo "Are you sure you want to delete the default wine prefix? This will delete the '~/.wine' directory. (y/n)"
      read -r confirmation
      if [ "$confirmation" = "y" ]; then
        echo "Deleting..."
        rm -rf ~/.wine
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
