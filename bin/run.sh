#!/bin/bash
set -e # exit immediately upon error(s)

# Set hostname of the container to isabelle-x11.
HOSTNAME="--hostname isabelle-x11"

# The namespace mapping ensures that the 'work' user in the container
# is mapped to the local user running this script. Futher, container
# UIDs/GIDs 0..999 are mapped to the intermediate UIDs 1..1000. See:
#  https://stackoverflow.com/questions/70770437/mapping-of-user-ids
# for a more detailed explanation on UID mapping in rootless containers.
NAMESPACE="--uidmap 1000:0:1 --uidmap 0:1:1000
           --gidmap 1000:0:1 --gidmap 0:1:1000"

# The following options are crucial to permit the container to create
# a X11 connection to the host. For a more detailed explanation, see:
#  https://major.io/2021/10/17/run-xorg-applications-with-podman/
X11_OPTS="-e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --security-opt label=type:container_runtime_t"

# Maps the local work directory into /home/work inside the container.
HOME_EXPORT="-v ./work:/home/work"

# The initial start if the container can be a little slow due to the
# UID/GUI namespace mapping. (On my laptop, it takes about 30 seconds.)
echo "Starting isabelle-x11 container, please wait (this may take a minute) ..."

# Execute the isabelle-x11 docker image.
docker run -it --rm $HOSTNAME $NAMESPACE $HOME_EXPORT $X11_OPTS isabelle-x11 $*

# Let the user know that his work is not lost ...
echo "Note that your work persists in the local 'work' subfolder."