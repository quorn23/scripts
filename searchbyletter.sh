#!/bin/bash

###########################################
#                                         #
# Search Movies per files with cross-seed #
#                                         #
# V2.2 Gabe                               #
# Added multi base paths                  #
# Added lower case check                  #
# Replaced eval                           #
# Base_paths check                        #
# Fixed lower case check for multi letter #
# Updated to Cross-Seed V6 (api key)      #
###########################################

### Configuration (YOU NEED TO EDIT THIS): ###

# Example for multiple paths: base_paths=("/data/media/movies" "/data/media/movies4k/")
base_paths=("/data/media/movies4k/")

# api_base_url, where is your cross-seed reachable?
api_base_url="http://cross-seed:2468"

# Head to this url in case you're lost: https://www.cross-seed.org/docs/v6-migration#apiauth-removed-and-apikey-added-options
api_key="YOURAPIKEY"

# READ: I added an additional sleep between searches, keep in mind, this script is to search for already existing media,
#       so ANY SWARM is already long gone and you're in NO HURRY to get your media imported. Look into Tmux, byobu or screen etc.
#       to run the search without needing an active shell session. You're not in a rush, set it to 60 (seconds) or higher and just let it run.
sleep="60"

### -------------------------------------------------- ###
### End configuration, no need to edit below this line ###
### -------------------------------------------------- ###

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
      curl -XPOST "${api_base_url}/api/webhook?apikey=$api_key" --data-urlencode "path=$folder"
##      curl -XPOST "${api_base_url}/api/webhook" -H "X-Api-Key: $api_key" --data-urlencode "path=$folder" ##
      sleep $sleep
    fi
  done
}

function single_letter_search() {
  letter="$1"
  letter_upper=$(echo "$letter" | tr '[:lower:]' '[:upper:]')
  letter_lower=$(echo "$letter" | tr '[:upper:]' '[:lower:]')

  for base_path in "${base_paths[@]}"; do
    process_folders "${base_path}${letter_upper}*"
    process_folders "${base_path}${letter_lower}*"
  done
}

function multi_search() {
  start_letter="$1"
  end_letter="$2"
  start_letter=$(echo "$start_letter" | tr '[:lower:]' '[:upper:]')
  end_letter=$(echo "$end_letter" | tr '[:lower:]' '[:upper:]')

  for ((i=$(printf '%d' "'$start_letter'");i<=$(printf '%d' "'$end_letter'");i++)); do
    letter=$(printf "\\$(printf '%03o' "$i")")
    for base_path in "${base_paths[@]}"; do
      process_folders "${base_path}${letter}*"
    done
  done
}

# Menu
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
