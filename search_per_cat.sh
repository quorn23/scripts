#!/bin/bash

# Define the API endpoint
API_ENDPOINT="http://qbittorrent:8080/api/v2/torrents/info"

# Get the list of categories
CATEGORIES=$(curl -s "$API_ENDPOINT" | jq -r '.[].category' | sort | uniq)

# Create an array to store the categories
CATEGORY_ARRAY=()

echo "Categories:"
i=1
while read -r CATEGORY; do
  echo "$i: $CATEGORY"
  CATEGORY_ARRAY[i]=$CATEGORY
  ((i++))
done <<< "$CATEGORIES"

# Ask the user to choose a category
read -p "Please choose a category by number: " CHOSEN_CATEGORY_NUMBER

# Get the chosen category
CHOSEN_CATEGORY=${CATEGORY_ARRAY[$CHOSEN_CATEGORY_NUMBER]}

# Get the list of torrents in the chosen category
TORRENTS=$(curl -s "$API_ENDPOINT" | jq -r --arg category "$CHOSEN_CATEGORY" '.[] | select(.category == $category) | .hash')

# Loop over the torrents and execute the command for each one
for HASH in $TORRENTS; do
  echo "Processing torrent with hash: $HASH"
  
  # Define the command
  COMMAND="curl -XPOST http://cross-seed:2468/api/webhook -H 'Content-Type: application/json' --data '{\"infoHash\":\"$HASH\"}'"
  
  # Execute the command
  eval $COMMAND
  
  # Wait for 60 seconds
  sleep 60
done
