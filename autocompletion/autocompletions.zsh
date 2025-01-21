_run_projects_autocompletion() {
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
