#!/bin/bash
# Execute this script via "source setenv.sh" for the change of PATH
# being visible inside the calling shell.

# Add element to PATH if not already present (copied from /etc/bashrc).
function pathmunge {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}

# Add current directory and its 'bin' subfolder to PATH.
pathmunge $PWD
pathmunge $PWD/bin

export PATH
