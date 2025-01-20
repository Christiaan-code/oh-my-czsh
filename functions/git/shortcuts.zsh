function skip-env() {
  if [[ -f "src/environments/environment.ts" ]]; then
    skip src/environments/environment.ts
  else
    echo "${YELLOW}No ${YELLOW_BOLD}environment.ts${YELLOW} file found${NC}"
  fi
  echo "${BLUE}Skipped ${BLUE_BOLD}environment.ts${BLUE}${NC}"
}

function unskip-env() {
  if [[ -f "src/environments/environment.ts" ]]; then
    unskip src/environments/environment.ts
  else
    echo "${YELLOW}No ${YELLOW_BOLD}environment.ts${YELLOW} file found${NC}"
  fi
  echo "${BLUE}Unskipped ${BLUE_BOLD}environment.ts${BLUE}${NC}"
}

function skip() {
  git update-index --skip-worktree "$@" >/dev/null
  echo "${BLUE}Skipped ${BLUE_BOLD}$1${BLUE}${NC}"
}

function unskip() {
  git update-index --no-skip-worktree "$@" >/dev/null
  echo "${BLUE}Unskipped ${BLUE_BOLD}$1${BLUE}${NC}"
}

function unskip-all() {
  # Save list of skipped files
  local skipped_files=$(list-skipped)

  # Unskip all files using shell function
  while IFS= read -r file; do
    [[ -n "$file" ]] && unskip "$file"
  done <<<"$skipped_files"

  # Output the skipped files so they can be captured
  echo "$skipped_files"
  echo "${BLUE}Unskipped all files${BLUE}${NC}"
}

function pick() {
  git cherry-pick "$@" --no-commit -m 1 >/dev/null
  echo "${BLUE}Cherry pick completed${BLUE}${NC}"
}

function stash() {
  git stash -u >/dev/null
  echo "${BLUE}Stashed successfully${BLUE}${NC}"
}

function apply() {
  git stash apply >/dev/null
  echo "${BLUE}Stash applied${BLUE}${NC}"
}

function pop() {
  git stash pop >/dev/null
  echo "${BLUE}Stash popped${BLUE}${NC}"
}

function revert() {
  git revert "$@" --no-commit -m 1 >/dev/null
  echo "${BLUE}Reverted successfully${BLUE}${NC}"
}

function list-skipped() {
  git ls-files -v | grep '^S' | awk '{print $2}'
}
