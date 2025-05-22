# Define projects configuration
typeset -A PROJECTS

# Format for projects.config.zsh:
# PROJECTS[alias]="path|node:version(optional)|run_command1;run_command2;..."
source "$(dirname "$0")/projects.config.zsh"

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
