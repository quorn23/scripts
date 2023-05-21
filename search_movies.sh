#!/bin/bash

###########################################
#                                         #
# Search Movies per files with cross-seed #
#                                         #
# V2.0 Gabe                               #
# Added multi base paths                  #
# Added lower case check                  #
# Replaced eval                           #
# Base_paths check                        #
###########################################

#!/bin/bash

base_paths=("/data/media/movies" "/data/media/movies4k/")
api_base_url="http://cross-seed:2468"

for i in "${!base_paths[@]}"; do
  if [[ "${base_paths[$i]}" != */ ]]; then
    base_paths[$i]="${base_paths[$i]}/"
  fi
done

function process_folders() {
  folders="$1"

  for folder in $folders; do
    if [ -d "$folder" ]; then
      echo "Processing folder: $folder"
      curl -XPOST "${api_base_url}/api/webhook" --data-urlencode "path=$folder"
      sleep 60
    fi
  done
}

function single_letter_search() {
  letter="$1"
  letter=$(echo "$letter" | tr '[:lower:]' '[:upper:]')
  for base_path in "${base_paths[@]}"; do
    process_folders "${base_path}${letter}*"
  done
}

function multi_search() {
  start_letter="$1"
  end_letter="$2"
  start_letter=$(echo "$start_letter" | tr '[:lower:]' '[:upper:]')
  end_letter=$(echo "$end_letter" | tr '[:lower:]' '[:upper:]')

  for letter in $(seq -f "%02g" $(printf '%d' "'$start_letter") $(printf '%d' "'$end_letter")); do
    for base_path in "${base_paths[@]}"; do
      process_folders "${base_path}${letter}*"
    done
  done
}

echo "Choose an option:"
echo "1. Single letter search"
echo "2. Multi-search (range of letters or numbers)"
read -p "Enter the number of your choice: " choice

case $choice in
  1)
    read -p "Enter the letter: " letter
    single_letter_search "$letter"
    ;;
  2)
    read -p "Enter the start letter: " start_letter
    read -p "Enter the end letter: " end_letter
    multi_search "$start_letter" "$end_letter"
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac
