# Forward a port using Microsoft DevTunnel
# Installation: brew install --cask devtunnel
# Documentation: https://learn.microsoft.com/en-us/azure/developer/dev-tunnels
# Usage: forward 4200
function forward() {
  echo -e "\n${BLUE_BOLD}Forwarding port $1...${NC}"
  local port="$1"
  local browser_url=""
  local inspect_url=""

  devtunnel host -p "$port" --allow-anonymous | while IFS= read -r line; do
    if [[ $line == *"Connect via browser"* ]]; then
      browser_url=$(echo "${line#*: }" | cut -d',' -f1)
      echo "$browser_url" | pbcopy
      echo -e "\n${GREEN_BOLD}🚀 Tunnel ready! Your application is available at: $browser_url${NC}"
      echo -e "${CYAN}URL has been copied to clipboard!${NC}"
    # elif [[ $line == *"Inspect network activity"* ]]; then
    #   inspect_url=$(echo "${line#*: }")
    #   echo -e "\n${GREEN_BOLD}🔍 Inspect network activity at: $inspect_url${NC}"
    fi
  done
}
