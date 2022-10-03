#!/bin/bash
set -e # exit immediately upon errors

# ANSI escape sequences for terminal output
ANSI_RESET='\033[0m'
ANSI_BOLD='\033[1m'

# Print an informative message (in bold font)
function info {
  echo -e "${ANSI_BOLD}$1${ANSI_RESET}"
}

info "Removing dangling images ..."

# Remove all dangling images form local docker store.
docker images --quiet --filter=dangling=true | xargs --no-run-if-empty docker rmi
