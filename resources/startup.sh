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
# NOTE: Obsolete, since we now adjust the user's ROOTS file instead.
# if [ ! -f "$HOME/.isabelle/Isabelle2022/etc/components" ]; then
#   echo "$AFP_THYS" >> $HOME/.isabelle/Isabelle2022/etc/components
# fi

# Patch ROOTS file of the AFP if a .patch-afp config file exists.
# Each line in the .patch-afp file is interpreted as an entry to
# be removed form the AFP's ROOTS file (i.e. to avoid duplication).
if [ -f .patch-afp ]; then
  echo -n -e "Patching $AFP_THYS/ROOTS by removing:"
  cat .patch-afp |
  while read ENTRY; do
    echo -n -e " ${ANSI_RED}$ENTRY${ANSI_RESET}"
    # Note that 'sed -i ...' fails to due lack of permission
    # to create a temporary file inside the $AFP_THYS folder.
    sed "/^$ENTRY\$/d" $AFP_THYS/ROOTS >/tmp/ROOTS
    cat /tmp/ROOTS >$AFP_THYS/ROOTS
    rm /tmp/ROOTS
  done
  echo
fi

# Execute command specified by CMD in the Dockerfile.
"$@"
