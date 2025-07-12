if [ -z "$1" ] || [ "$1" == "." ]; then
  folder_path=$(pwd)
elif [[ "$1" == /* ]]; then
  folder_path="$1"
else
  folder_path=$(pwd)/"$1"
fi

if [ ! -d "$folder_path" ]; then
  echo "Folder $folder_path doesn't exist."
  return 0
fi

if [ ! -L "/var/www/html" ]; then
  while true; do
    read -p "Apache server files aren't links. Delete anyway? (Y/N)" yn
    case $yn in
    [Yy]*)
      sudo rm -r /var/www/html
      break
      ;;
    [Nn]*) return 0 ;;
    *) echo "Please answer yes or no." ;;
    esac
  done
else
  sudo rm -r "/var/www/html"
fi

sudo ln -s "$folder_path" /var/www/html
echo "Succesfully added folder $folder_path to the apache server."
