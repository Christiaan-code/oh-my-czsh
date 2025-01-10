function squash() {
  git reset --soft dev
  git commit -m "$@"
  git push --force
}

function squash-main() {
  git reset --soft main
  git commit -m "$@"
  git push --force
}

function squash-prod() {
  git reset --soft prod
  git commit -m "$@"
  git push --force
}
