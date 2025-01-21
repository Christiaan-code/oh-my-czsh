function br() {
  git checkout -b "$1" >/dev/null 2>&1
  echo "${BLUE}Branch ${BLUE_BOLD}'$1'${BLUE} created${NC}"
}
compdef _git_branch_autocomplete br

function delete() {
  if ! git branch -d "$1" >/dev/null 2>&1; then
    echo "${YELLOW}Branch ${BLUE_BOLD}'$1'${YELLOW} is not fully merged.${NC}"
    read -p "Do you want to force delete it? (y/N): " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      force-delete "$1"
      echo "${BLUE}Branch ${BLUE_BOLD}'$1'${BLUE} deleted${NC}"
    else
      echo "${YELLOW}Branch deletion cancelled.${NC}"
    fi
  fi
  echo "${BLUE}Branch ${BLUE_BOLD}'$1'${BLUE} deleted${NC}"
}
compdef _git_branch_autocomplete delete

function force-delete() {
  git branch -D "$1" >/dev/null 2>&1
  echo "${BLUE}Branch ${BLUE_BOLD}'$1'${BLUE} deleted${NC}"
}
compdef _git_branch_autocomplete force-delete
