# Define configuration options
typeset -A ZSH_PREFERENCES

# Load saved preferences if they exist
if [[ -f ~/.zsh/config/preferences/preferences.config.zsh ]]; then
  source ~/.zsh/config/preferences/preferences.config.zsh
fi

function configure-zsh() {
  echo "${BLUE_BOLD}ZSH Configuration${NC}\n"

  # Configure terminal preference for run-projects
  echo "${BLUE}Select the terminal to use when running multiple projects:${NC}"
  echo "1) System Terminal"
  echo "2) iTerm"
  echo -n "Enter your choice (1-2): "

  read terminal_choice

  case $terminal_choice in
  1)
    ZSH_PREFERENCES[preferred_terminal]="terminal"
    echo "${GREEN}✓ Set default terminal to: System Terminal${NC}"
    ;;
  2)
    if osascript -e 'id of application "iTerm"' &>/dev/null; then
      ZSH_PREFERENCES[preferred_terminal]="iTerm"
      echo "${GREEN}✓ Set default terminal to: iTerm${NC}"
    else
      echo "${RED}iTerm is not installed. Using default Terminal.app${NC}"
      ZSH_PREFERENCES[preferred_terminal]="terminal"
    fi
    ;;
  *)
    echo "${RED}Invalid choice. Using default (System Terminal)${NC}"
    ZSH_PREFERENCES[preferred_terminal]="terminal"
    ;;
  esac

  # Save preferences to config file
  mkdir -p ~/.zsh/config/preferences
  echo "# ZSH Preferences Configuration" >~/.zsh/config/preferences/preferences.config.zsh
  echo "ZSH_PREFERENCES[preferred_terminal]=\"${ZSH_PREFERENCES[preferred_terminal]}\"" >>~/.zsh/config/preferences/preferences.config.zsh

  echo "\n${GREEN_BOLD}Configuration saved successfully!${NC}"
}
