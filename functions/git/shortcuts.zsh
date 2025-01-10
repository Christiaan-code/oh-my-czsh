function skip-env() {
  git update-index --skip-worktree src/environments/environment.ts
}

function unskip-env() {
  git update-index --no-skip-worktree src/environments/environment.ts
}

function skip() {
  git update-index --skip-worktree "$@"
}

function unskip() {
  git update-index --no-skip-worktree "$@"
}

function pick() {
  git cherry-pick "$@" --no-commit -m 1
}

function stash() {
  git stash -u
}

function apply() {
  git stash apply
}

function pop() {
  git stash pop
}

function revert() {
  git revert "$@" --no-commit -m 1
}

function br() {
  git checkout -b "$1"
}