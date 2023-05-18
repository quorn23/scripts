#!/bin/bash

###########################################
#                                         #
# Search Movies per files with cross-seed #
#                                         #
# V1.1 Gabe                               #
###########################################

function single_letter_search() {
  letter="$1"
  folders="/data/media/movies/$letter*"

  for folder in $folders; do
    if [ -d "$folder" ]; then
      echo "Processing folder: $folder"
      curl -XPOST http://cross-seed:2468/api/webhook --data-urlencode "path=$folder"
      sleep 60
    fi
  done
}

function multi_search() {
  start_letter="$1"
  end_letter="$2"

  for letter in $(eval echo "{$start_letter..$end_letter}"); do
    folders="/data/media/movies/$letter*"
    for folder in $folders; do
      if [ -d "$folder" ]; then
        echo "Processing folder: $folder"
        curl -XPOST http://cross-seed:2468/api/webhook --data-urlencode "path=$folder"
        sleep 60
      fi
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
