#!/bin/bash

if [ -z "$1" ] || [ "$1" == "." ]; then
  folder_path=$(pwd)
elif [[ "$1" == /* ]]; then
  folder_path="$1"
else
  folder_path=$(pwd)/"$1"
fi

if [ ! -d "$folder_path" ]; then
  echo "Folder $folder_path doesn't exist."
  exit 1
fi

if [ ! -L "/var/www/html" ]; then
  while true; do
    read -p "Apache server files aren't links. Delete anyway? (Y/N) " yn
    case $yn in
      [Yy]*)
        sudo rm -r /var/www/html
        break
        ;;
      [Nn]*) exit 0 ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
else
  sudo rm -r "/var/www/html"
fi

sudo ln -s "$folder_path" /var/www/html
echo "Successfully linked $folder_path to /var/www/html."

chmod o+rx "$folder_path"
chmod -R o+rX "$folder_path"

if command -v getenforce &>/dev/null && [ "$(getenforce)" != "Disabled" ]; then
  sudo semanage fcontext -a -t httpd_sys_content_t "$folder_path(/.*)?"
  sudo restorecon -Rv "$folder_path"
fi

sudo systemctl restart httpd
echo "Apache restarted. Folder should be accessible now."

