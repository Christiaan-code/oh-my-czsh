_projects_autocompletion() {
  local project_aliases=()
  for key in ${(k)PROJECTS}; do
    project_aliases+=($key)
  done
  _describe 'project aliases' project_aliases
}

_git_branch_autocomplete() {
  local branches
  branches=($(git branch --format='%(refname:short)' 2>/dev/null))
  _describe 'Existing branches' branches
}

_skipped_files_autocomplete() {
  local skipped_files
  skipped_files=($(list-skipped))
  _describe 'Skipped files' skipped_files
}

_co_all_autocomplete() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  _arguments -C \
    '1: :->branch' \
    '*: :->projects'

  case "$state" in
    branch)
      _git_branch_autocomplete
      ;;
    projects)
      _projects_autocompletion
      ;;
  esac
}
