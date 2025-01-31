function open() {
  local projects=()
  # Throw error if no arguments were provided
  if [[ $# -eq 0 ]]; then
    echo "Error: Please provide at least one project name"
    return 1
  fi

  projects=("$@")

  # Validate each project alias
  for project_alias in "${projects[@]}"; do
    if [ -z "${PROJECTS[$project_alias]}" ]; then
      echo "${RED}Error:${NC} Invalid project alias '${YELLOW}${project_alias}${NC}'"
      return 1
    fi
  done

  # Open each valid project
  for project in "${projects[@]}"; do
    local project_path=$(get_project_path "$project")
    # Expand the path
    project_path="${project_path/#\~/$HOME}"
    cursor "$project_path"
    echo "${BLUE}Opened ${BLUE_BOLD}${project}${NC}"
  done
}
compdef _projects_autocompletion open
