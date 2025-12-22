function deploy-personal() {
  echo "y" | pnpm sst:deploy --account dev --stage christiaan
}

function remove-personal() {
  pnpm sst:remove --account dev --stage christiaan
}
