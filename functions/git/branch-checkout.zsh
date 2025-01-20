# Custom function to checkout and pull branch
function co() {
  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  local branch_name="$1"
  local branch_created=false
  local change_happened=true

  if [[ -z "$branch_name" ]]; then
    echo -e "${YELLOW}Please provide a branch name${NC}"
    return 1
  fi

  # Capture the list of skipped files
  local files_to_skip=$(list-skipped)

  # Unskip all files before checkout
  unskip-all >/dev/null

  stash >/dev/null

  # Check if branch exists (either locally or remotely)
  if git show-ref --verify --quiet "refs/heads/$branch_name" ||
    git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
    gco "$branch_name" >/dev/null 2>&1 && gpra >/dev/null 2>&1
  else
    echo -e "${YELLOW}Branch '$branch_name' doesn't exist. Would you like to create it? [y/n]${NC}"
    read -r -s -k 1 response
    if [[ $response =~ [Yy] ]]; then
      br "$branch_name"
      branch_created=true
    else
      echo -e "${YELLOW}Operation cancelled${NC}"
      change_happened=false
    fi
  fi

  # Try to pop the stash
  if ! pop >/dev/null; then
    echo -e "${YELLOW}Stash pop encountered conflicts.${NC}"
    echo -e "${BLUE}Resolve the conflicts, then:${NC}"
    echo -e "  - Press any key to continue and restore skipped files"
    echo -e "  - Press 'c' to cancel and undo changes"

    # Wait for user input
    read -r -s -k 1 key
    if [[ "$key" == "c" ]]; then
      echo -e "\n${YELLOW}Cancelling checkout...${NC}"
      gco "$current_branch" >/dev/null 2>&1
      if $branch_created; then
        force-delete "$branch_name"
      fi
      pop >/dev/null
      return 1
    fi
  fi

  # Re-skip the previously skipped files
  while IFS= read -r file; do
    [[ -n "$file" ]] && skip "$file" >/dev/null
  done <<<"$files_to_skip"

  if $change_happened; then
    echo "${BLUE}Checked out ${BLUE_BOLD}${branch_name}${BLUE} successfully${NC}"
  fi
}

compdef _git_branch_autocomplete co
