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

  local has_changes_in_worktree=$(git diff --name-only)
  if [[ -n "$has_changes_in_worktree" ]]; then
    stash >/dev/null
  fi

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

  if [[ -n "$has_changes_in_worktree" ]]; then
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
        git reset --merge >/dev/null 2>&1
        gco "$current_branch" >/dev/null 2>&1
        if $branch_created; then
          force-delete "$branch_name"
        fi
        pop >/dev/null
        return 1
      fi
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

# Custom function to checkout branch on all configured projects
function co-all() {
  local branch_name="$1"
  local current_dir=$(pwd)
  local success_count=0
  local total_count=0
  local projects_to_process=()

  # Check if PROJECTS array is loaded
  if [[ ${#PROJECTS[@]} -eq 0 ]]; then
    echo -e "${RED}Error:${NC} No projects configured. Please check your projects configuration."
    return 1
  fi

  # Parse arguments
  if [[ $# -eq 0 ]]; then
    echo -e "${YELLOW}Usage: co-all <branch-name> [project-alias1 project-alias2 ...]${NC}"
    echo -e "${BLUE}Examples:${NC}"
    echo -e "  ${CYAN}co-all main${NC}                    # Checkout main branch on all projects"
    echo -e "  ${CYAN}co-all feature-branch fe admin${NC}  # Checkout feature-branch on fe and admin projects"
    return 1
  elif [[ $# -eq 1 ]]; then
    # Only branch name provided, process all projects
    branch_name="$1"
    for project_alias in "${!PROJECTS[@]}"; do
      projects_to_process+=("$project_alias")
    done
  else
    # Branch name and project aliases provided
    branch_name="$1"
    shift
    projects_to_process=("$@")

    # Validate each project alias
    for project_alias in "${projects_to_process[@]}"; do
      if [[ -z "${PROJECTS[$project_alias]}" ]]; then
        echo -e "${RED}Error:${NC} Invalid project alias '${YELLOW}${project_alias}${NC}'"
        echo -e "${BLUE}Available project aliases:${NC}"
        for available_alias in "${!PROJECTS[@]}"; do
          echo -e "  ${CYAN}${available_alias}${NC}"
        done
        return 1
      fi
    done
  fi

  if [[ ${#projects_to_process[@]} -eq 1 ]]; then
    echo -e "${BLUE}Checking out branch ${BLUE_BOLD}${branch_name}${BLUE} on project ${BLUE_BOLD}${projects_to_process[1]}${BLUE}...${NC}"
  else
    echo -e "${BLUE}Checking out branch ${BLUE_BOLD}${branch_name}${BLUE} on ${#projects_to_process[@]} projects...${NC}"
  fi
  echo ""

  # Loop through specified projects
  for project_alias in "${projects_to_process[@]}"; do
    local project_path=$(get_project_path "$project_alias")
    # Expand the path
    project_path="${project_path/#\~/$HOME}"

    total_count=$((total_count + 1))

    echo -e "${CYAN}Processing ${CYAN_BOLD}${project_alias}${CYAN} (${project_path})${NC}"

    # Check if project directory exists
    if [[ ! -d "$project_path" ]]; then
      echo -e "  ${YELLOW}⚠️  Directory not found, skipping...${NC}"
      continue
    fi

    # Check if it's a git repository
    if [[ ! -d "$project_path/.git" ]]; then
      echo -e "  ${YELLOW}⚠️  Not a git repository, skipping...${NC}"
      continue
    fi

    # Change to project directory
    cd "$project_path" 2>/dev/null
    if [[ $? -ne 0 ]]; then
      echo -e "  ${RED}❌ Failed to change to project directory${NC}"
      continue
    fi

    # Check if branch exists (either locally or remotely)
    if git show-ref --verify --quiet "refs/heads/$branch_name" 2>/dev/null ||
      git show-ref --verify --quiet "refs/remotes/origin/$branch_name" 2>/dev/null; then
      # Branch exists, checkout and pull
      if git checkout "$branch_name" >/dev/null 2>&1 && git pull --rebase --autostash >/dev/null 2>&1; then
        echo -e "  ${GREEN}✅ Successfully checked out ${branch_name}${NC}"
        success_count=$((success_count + 1))
      else
        echo -e "  ${RED}❌ Failed to checkout/pull ${branch_name}${NC}"
      fi
    else
      echo -e "  ${YELLOW}⚠️  Branch ${branch_name} doesn't exist in this repository${NC}"
    fi

    echo ""
  done

  # Return to original directory
  cd "$current_dir" 2>/dev/null

  # Summary
  echo -e "${BLUE}Summary:${NC}"
  echo -e "  ${GREEN}✅ Successfully checked out: ${success_count}${NC}"
  echo -e "  ${YELLOW}⚠️  Skipped/Failed: $((total_count - success_count))${NC}"
  echo -e "  ${BLUE}📊 Total projects processed: ${total_count}${NC}"

  if [[ $success_count -eq $total_count ]]; then
    echo -e "${GREEN}🎉 All projects successfully checked out to ${branch_name}!${NC}"
  elif [[ $success_count -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  Some projects were successfully checked out, but not all.${NC}"
  else
    echo -e "${RED}❌ No projects were successfully checked out.${NC}"
    return 1
  fi
}

compdef _git_branch_autocomplete co
compdef _co_all_autocomplete co-all
