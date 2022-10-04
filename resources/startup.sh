#!/bin/bash
###################################################################
# This script is automatically executed via the ENTRYPOINT of the #
# isabelle-x11 docker image. We perform some post hoc setup tasks #
# here, such as creating a components file that includes the AFP. #
# (The AFP is installed by the Dockerfile as well, under /opt)    #
###################################################################

# ANSI escape sequences for terminal output
ANSI_RESET='\033[0m'
ANSI_BOLD='\033[1m'
ANSI_RED='\033[0;31m'
ANSI_GREEN='\033[0;32m'
ANSI_YELLOW='\033[0;33m'
ANSI_BLUE='\033[0;34m'
ANSI_MAGENTA='\033[0;35m'
ANSI_CYAN='\033[0;36m'

# Utility function to display an informative message.
function info {
  echo -e "$1"
}

# Inform the user about the Isabelle & AFP tool versions provided.
info "${ANSI_BOLD}Tool Version${ANSI_RESET}: $ISABELLE_DIST ($AFP_RELEASE)"
# info "Please send suggestions and bug reports to ${ANSI_BLUE}frank.zeyda@gmail.com${ANSI_RESET} ."

# Create Isabelle components file (with AFP) if it does not exist.
# NOTE: Alternatively, we may also create/modify the local ROOTS file.
if [ ! -f "$HOME/.isabelle/Isabelle2021-1/etc/components" ]; then
  echo "$AFP" >> $HOME/.isabelle/Isabelle2021-1/etc/components
fi

# Execute command specified by CMD in the Dockerfile.
"$@"
