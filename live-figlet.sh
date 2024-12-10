#!/bin/bash

# URL to fetch the dynamic content
BACKEND_URL="http://10.5.20.137/mmdvmhost/live_caller_backend.php"

# Interval between updates (in seconds)
UPDATE_INTERVAL=1.5

# Function to extract the text content from multi-line HTML
extract_data() {
  local regex="$1"
  local content=$(echo "$HTML_CONTENT" | awk 'BEGIN {RS="</span>"; FS=ORS} {if ($0 ~ /'"$regex"'/) {sub(/.*>/, "", $0); print}}' | head -n 1)

  # Replace &deg; with the actual degree symbol
  content=$(echo "$content" | sed 's/&deg;/°/g')
  echo "$content"
}

# Initialize screen for live updates
initialize_screen() {
  clear
  echo "Dynamic Live Updates from $BACKEND_URL"
  echo "--------------------------------------"
  for i in {1..15}; do
    echo ""  # Placeholder for dynamic content
  done
  echo "--------------------------------------"
  echo "Press 'q' to exit."
}

# Update the live content on the same lines
update_screen() {
  # Fetch the dynamic HTML content using curl
  HTML_CONTENT=$(curl -s "$BACKEND_URL")

  # Check if the HTML content was successfully fetched
  if [[ -z "$HTML_CONTENT" ]]; then
    tput cup 2 0
    echo "Error: Unable to fetch content from $BACKEND_URL."
    return
  fi

  # Move cursor to the starting position for updates
  tput cup 2 0

# Extract and display the Call Sign in large font
CALL_SIGN=$(extract_data "<span class='oc_call'>")
if [[ -n "$CALL_SIGN" ]]; then
  figlet "$CALL_SIGN"
else
  echo "Call Sign: Not available"
fi


  # Extract and display other data
  extract_data "<span class='oc_name'>" | awk '{printf "Operator Name  : %s\n", $0}'
  extract_data "<span class='oc_caller'>" | awk '{printf "Location       : %s\n", $0}'
  extract_data "Source:.*?<span class='dc_info_def'>" | awk '{printf "Source         : %s\n", $0}'
  extract_data "Mode:.*?<span class='dc_info_def'>" | awk '{printf "Mode           : %s\n", $0}'
  extract_data "Target:.*?<span class='dc_info_def'>" | awk '{printf "Target         : %s\n", $0}'
  extract_data "TX Duration:.*?<span class='dc_info_def'>" | awk '{printf "TX Duration    : %s\n", $0}'
  extract_data "Packet Loss:.*?<span class='dc_info_def'>" | awk '{printf "Packet Loss    : %s\n", $0}'
  extract_data "Hotspot Time:.*?<span class='hw_info_def'>" | awk '{printf "Hotspot Time   : %s\n", $0}'
  extract_data "CPU Temp:.*?<span class='cpu_norm'>" | awk '{printf "CPU Temp       : %s\n", $0}'
}

# Main loop to continuously fetch and display updates
RUNNING=true
initialize_screen

# Setup to capture keypress directly
stty -echo -icanon time 0 min 0

while $RUNNING; do
  update_screen
  sleep "$UPDATE_INTERVAL"

  # Check for key press
  key=$(dd bs=1 count=1 2>/dev/null)
  if [[ "$key" == "q" ]]; then
    RUNNING=false
  fi
done

# Restore terminal settings
stty sane

# Clean exit
clear
# echo "Exiting live updates. Goodbye!"
