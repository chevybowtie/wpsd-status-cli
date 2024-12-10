#!/bin/bash

# Load configuration file
CONFIG_FILE="${CONFIG_FILE:-config.cfg}"

if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "Error: Configuration file '$CONFIG_FILE' not found."
  echo "Please create a configuration file with the necessary parameters."
  exit 1
fi

# Ensure required configurations are set
if [[ -z "$SERVER_IP" ]]; then
  echo "Error: SERVER_IP is not set in the configuration file."
  exit 1
fi

if [[ -z "$UPDATE_INTERVAL" ]]; then
  echo "Error: UPDATE_INTERVAL is not set in the configuration file."
  exit 1
fi

# Construct the backend URL dynamically
BACKEND_URL="http://$SERVER_IP/mmdvmhost/live_caller_backend.php"

extract_data() {
  local label="$1"
  local regex="$2"
  # Extract the content using grep and clean it
  local content=$(echo "$HTML_CONTENT" | grep -Po "$regex" | sed -E 's/<[^>]+>//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # Remove the label and extra colon from the content
  content=$(echo "$content" | sed -E "s/^$label[[:space:]]*:?[[:space:]]*//")

  # Print the cleaned label and content
  printf "%-15s: %s\n" "$label" "$content"
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

update_screen() {
  # Fetch the dynamic HTML content using curl and normalize it
  HTML_CONTENT=$(curl -s "$BACKEND_URL" | tr -d '\n' | sed -E 's/>[[:space:]]+</></g')

  # Check if the HTML content was successfully fetched
  if [[ -z "$HTML_CONTENT" ]]; then
    tput cup 2 0
    echo "Error: Unable to fetch content from $BACKEND_URL."
    return
  fi

  # Move cursor to the starting position for updates
  tput cup 2 0

  # Extract and display the Call Sign in large font
  CALL_SIGN=$(echo "$HTML_CONTENT" | grep -Po "<span class='oc_call'>.*?</span>" | sed -E 's/<[^>]+>//g')
  if [[ -n "$CALL_SIGN" ]]; then
    figlet "$CALL_SIGN"
  else
    echo "Call Sign: Not available"
  fi

  # Extract and display other data
  extract_data "Operator Name" "<span class='oc_name'>.*?</span>"

# Extract and clean the Location
LOCATION=$(echo "$HTML_CONTENT" | grep -Po "<span class='oc_caller'>.*?</span>" \
  | sed -E 's/<span class='\''oc_name'\''>.*?<\/span>//g' \
  | sed -E 's/<br \/>/, /g' \
  | sed -E 's/<[^>]+>//g' \
  | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# Print the Location
printf "%-15s: %s\n" "Location" "$LOCATION"


  extract_data "Source" "Source:.*?<span class='dc_info_def'>(.*?)</span>"
  extract_data "Mode" "Mode:.*?<span class='dc_info_def'>(.*?)</span>"
  extract_data "Target" "Target:.*?<span class='dc_info_def'>(.*?)</span>"
  extract_data "TX Duration" "TX Duration:.*?<span class='dc_info_def'>(.*?)</span>"
  extract_data "Packet Loss" "Packet Loss:.*?<span class='loss_.*?'>(.*?)</span>"
  extract_data "Hotspot Time" "Hotspot Time:.*?<span class='hw_info_def'>(.*?)</span>"
  extract_data "CPU Temp" "CPU Temp:.*?<span class='cpu_norm'>(.*?)</span>" | sed 's/&deg;/°/g'
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
