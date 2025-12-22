function git-cleanup() {
  echo -e "\n${BLUE_BOLD}Starting cleanup...${NC}\n"

  local branches=()
  local branch
  local answer

  # Get protected branches from config, default to main,stage
  local protected_branches="${ZSH_PREFERENCES[protected_branches]:-main,stage}"
  # Convert comma-separated list to regex pattern (main,stage -> main|stage)
  local protected_pattern=$(echo "$protected_branches" | tr ',' '|')
  local default_branch=$(echo "$protected_branches" | cut -d',' -f1)

  # Store all branches in array, excluding protected branches
  while IFS= read -r branch; do
    branches+=("$branch")
  done < <(git branch | grep -vE "^\*?\s*($protected_pattern)$")

  co "$default_branch"

  # Process each branch
  for branch in "${branches[@]}"; do
    # Remove leading whitespace/asterisk
    branch=$(echo "$branch" | tr -d '[:space:]*')

    # Try to delete with -d first (only works for properly merged branches)
    if git branch -d "$branch" 2>/dev/null; then
      echo -e "${GREEN}✓ Deleted merged branch: $branch${NC}"
      continue
    fi

    # If we get here, the branch wasn't properly merged
    while true; do
      echo -n "${YELLOW}Branch '$branch' is not properly merged. Force delete? (y/n): ${NC}"
      read answer
      if [[ "$answer" =~ ^[YyNn]$ ]]; then
        break
      fi
      echo -e "${YELLOW}Please answer y or n${NC}"
    done

    if [[ "$answer" =~ ^[Yy]$ ]]; then
      git branch -D "$branch"
      echo -e "${GREEN_BOLD}✓ Force deleted branch: $branch${NC}"
    else
      echo -e "${GREY}Skipped branch: $branch${NC}"
    fi
  done

  echo -e "\n${BLUE_BOLD}Cleanup complete!${NC}"
}
