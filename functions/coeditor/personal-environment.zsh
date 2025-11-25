function deploy-personal() {
  pnpm sst:deploy --account dev --stage christiaan
}

function remove-personal() {
  pnpm sst:remove --account dev --stage christiaan
}
