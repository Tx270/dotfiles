connect() {
  user="${1:-$NAS_USER}"
  ssh "${user}@${NAS_HOST}"
}
