# Define projects configuration
declare -A PROJECTS

# Format for projects.config.zsh:
# PROJECTS[alias]="path|node:version(optional)|run_command1;run_command2;..."
source ~/.zsh/functions/run-projects/projects.config.zsh

function get_project_path() {
  local project_name="$1"
  echo "${PROJECTS[$project_name]%%|*}"
}

function get_project_node_version() {
  local project_name="$1"
  local without_path="${PROJECTS[$project_name]#*|}"
  if [[ $without_path == node:* ]]; then
    echo "${without_path%%|*}" | sed 's/node://'
    return 0
  fi
  return 1
}

function get_project_commands() {
  local project_name="$1"
  local without_path="${PROJECTS[$project_name]#*|}"
  if [[ $without_path == node:* ]]; then
    echo "${without_path#*|}"
  else
    echo "$without_path"
  fi
}

function run() {
  local branch="main"
  local projects=()
  local i=1
  local pids=()
  local log_dir="/tmp/dev-projects"

  # Function to cleanup processes and files on exit
  function cleanup() {
    echo "\n${BLUE_BOLD}Stopping all projects...${NC}"
    for pid in "${pids[@]}"; do
      kill $pid 2>/dev/null
    done

    # Clean up log files
    if [ -d "$log_dir" ]; then
      rm -rf "$log_dir"
    fi

    return
  }

  # Set up trap for Ctrl+C
  trap cleanup INT

  # Clean up log files
  if [ -d "$log_dir" ]; then
    rm -rf "$log_dir"
  fi

  # Parse all arguments
  while [ $i -le $# ]; do
    # Use eval to get the argument at position $i
    eval "current=\${$i}"

    if [ "$current" = "-b" ]; then
      # Check if next argument exists
      eval "next=\${$((i + 1)):-}"
      if [ -z "$next" ]; then
        echo "${RED}Error:${NC} No branch name provided after -b flag"
        return 1
      fi
      branch="$next"
      i=$((i + 2))
    else
      projects+=("$current")
      i=$((i + 1))
    fi
  done

  # Check if any project aliases were provided
  if [ ${#projects[@]} -eq 0 ]; then
    echo "${RED}Error:${NC} No project aliases provided"
    return 1
  fi

  # Validate each project alias
  for project_alias in "${projects[@]}"; do
    if [ -z "${PROJECTS[$project_alias]}" ]; then
      echo "${RED}Error:${NC} Invalid project alias '${YELLOW}${project_alias}${NC}'"
      return 1
    fi
  done

  echo "${BLUE_BOLD}Running ${#projects[@]} projects on branch:${GREEN} $branch${NC}"

  # Create a directory for logs
  mkdir -p "$log_dir"

  # Start each project in background
  for project_alias in "${projects[@]}"; do
    local project_path=$(get_project_path "$project_alias")
    local project_commands=$(get_project_commands "$project_alias")

    # Expand the path
    project_path="${project_path/#\~/$HOME}"

    # Create a subshell for each project
    (
      local node_version
      if node_version=$(get_project_node_version "$project_alias"); then
        echo "${MAGENTA}Executing: ${MAGENTA_BOLD}nvm use $node_version${NC}"
        nvm use "$node_version"
      fi
      cd "$project_path" &&
        echo "${MAGENTA}Executing: ${MAGENTA_BOLD}co $branch${NC}" &&
        co "$branch" &&
        echo "${MAGENTA}Executing: ${MAGENTA_BOLD}yarn${NC}" &&
        yarn &&
        echo "${MAGENTA}Executing: ${MAGENTA_BOLD}$project_commands${NC}" &&
        eval "$project_commands"
    ) >"$log_dir/$project_alias.log" 2>&1 &

    pids+=($!)
    echo "${GREEN}Started${NC} $project_alias (PID: $!)"
  done

  echo "\n${BLUE_BOLD}All projects started! Tailing logs...${NC}\n"

  # Use tail to follow all log files, replacing the header with project alias
  tail -f "$log_dir"/*.log | awk '
    /==> .*\.log <==/ {
      # Extract project name from the path
      match($0, /[^\/]+\.log/)
      project=substr($0, RSTART, RLENGTH-4)
      printf "\n%s%s%s\n", "'"${BLUE_BOLD}"'", project, "'"${NC}"'"
      next
    }
    { print }
  '
}
