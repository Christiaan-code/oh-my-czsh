function pr() {
  gaa
  gcb "$1"
  gcmsg "$2"
  git push --set-upstream origin "$1"
}

function multi-pr() {
  local bases=("prod" "main")
  echo -e "\n${BLUE_BOLD}Starting PR creation for $(printf "${CYAN_BOLD}%s${BLUE_BOLD}, " "${bases[@]}" | sed 's/, $//')${NC}\n"

  # Check if there are any changes to commit
  if [[ -z $(git status --porcelain) ]]; then
    echo -e "${RED_BOLD}Error: No changes to commit${NC}"
    echo -e "${YELLOW}Please make some changes before creating PRs${NC}"
    return 1
  fi

  local feature_name="$1"

  # Check if at least two parameters are provided (feature name and at least one message)
  if [[ $# -lt 2 ]]; then
    echo -e "${RED_BOLD}Error: Missing parameters${NC}"
    echo -e "${YELLOW}Usage: multi-pr feature-name 'message1' ['message2' ...]${NC}"
    return 1
  fi

  local current_branch=$(git rev-parse --abbrev-ref HEAD)

  # Store current changes
  git stash

  # Create a temporary branch to make the commit
  git checkout -b "temp-${feature_name}"
  git stash apply stash@{0}
  git add .

  # Build the commit command with multiple -m parameters
  local commit_cmd="git commit"
  shift # Remove the first parameter (feature_name)
  for message in "$@"; do
    commit_cmd+=" -m \"$message\""
  done

  # Execute the commit command
  eval "$commit_cmd"
  local commit_hash=$(git rev-parse HEAD)

  for base in "${bases[@]}"; do
    # Determine branch name format
    if [[ "$base" == "prod" ]]; then
      local branch_name="hotfix/${feature_name}"
    else
      local branch_name="${feature_name}-${base}"
    fi
    echo -e "${BLUE}Creating branch $branch_name from $base...${NC}"

    # Checkout base branch and pull latest
    co "$base"

    # Create new branch
    git checkout -b "$branch_name"

    # Cherry-pick the commit
    if ! git cherry-pick "$commit_hash"; then
      echo -e "${YELLOW}Merge conflicts detected. Please resolve them using your GUI.${NC}"
      while true; do
        echo -e "${YELLOW}Press any key once you've resolved and staged the conflicts...${NC}"
        read -n 1

        if [[ -n $(git diff --name-only --diff-filter=U) ]]; then
          echo -e "${YELLOW}There are still unresolved conflicts. Please resolve all conflicts and stage the changes.${NC}"
        else
          git cherry-pick --continue
          break
        fi
      done
    fi

    # Push the branch
    git push --set-upstream origin "$branch_name"

    echo -e "${GREEN_BOLD}✓ Created PR branch: $branch_name${NC}"
  done

  # Clean up
  git checkout "$current_branch"
  git branch -D "temp-${feature_name}"
  git stash drop stash@{0}

  echo -e "\n${BLUE_BOLD}Done! Created PRs for $(printf "${CYAN_BOLD}%s${BLUE_BOLD}, " "${bases[@]}" | sed 's/, $//')${NC}"
}
