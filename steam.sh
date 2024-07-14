#!/bin/bash

options=("Fix MimeType" "Quit")
select opt in "${options[@]}"; do
  case $opt in
    "Fix MimeType")
      echo "Fix MimeType..."

      file_path="$HOME/.local/share/applications/steam.desktop"

      # Check if the file exists
      if [ ! -f "$file_path" ]; then
        echo "steam.desktop file not found!. (is Steam installed?)"
        exit 1
      fi

      # Use sed to replace the line starting with the "MimeType="
      sed -i "/^MimeType=/c\\MimeType=x-scheme-handler/steam" "$file_path"

      echo "steam.desktop has been updated"
      break
      ;;

    "Quit")
      echo "Exiting."
      break
      ;;
    *) echo "Invalid option $REPLY";;
  esac
done
