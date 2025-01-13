# Custom function to checkout and pull branch
function co() {
  local branch_name="$1"

  if [[ -z "$branch_name" ]]; then
    echo -e "${YELLOW}Please provide a branch name${NC}"
    return 1
  fi

  gco "$branch_name" >/dev/null && gpra
}

# Add autocompletion for the function
_co() {
  local branches
  branches=($(git branch --format='%(refname:short)' 2>/dev/null))
  _describe 'branch' branches
}
compdef _co co
