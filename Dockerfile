################################################################################
# Dockerfile to create the isabelle-x11 Docker image                           #
# 2022 (c) by Frank Zeyda (frank.zeyda@gmail.com) for Galois, Inc.             #
################################################################################

# We use Ubuntu 22.10 (Kinetic Kudu) as the based image.
FROM ubuntu:22.10

# Build arguments passed to this Dockerfile.
ARG ISABELLE_DIST
ARG ISABELLE_TAR
ARG AFP_RELEASE

# Information about this Docker image.
LABEL maintainer="frank.zeyda@gmail.com"
LABEL description="Docker image providing Isabelle with X11 support."
LABEL isabelle="$ISABELLE_DIST"
LABEL afp="$AFP_RELEASE"
LABEL version="1.0"

# Use apt in non-interactive mode throughout.
ENV DEBIAN_FRONTEND=noninteractive

# Copy extracted Isabelle and AFP distributions to /opt.
ADD --chown=0:0 downloads/$ISABELLE_DIST /opt/$ISABELLE_DIST
ADD --chown=0:0 downloads/$AFP_RELEASE   /opt/$AFP_RELEASE

# Make the AFP's ROOTS file writeable for everyone.
RUN chmod a+rw /opt/$AFP_RELEASE/thys/ROOTS

# Expose image meta-information to the container.
ENV ISABELLE_DIST="$ISABELLE_DIST"
ENV AFP_RELEASE="$AFP_RELEASE"

# Add Isabelle installation to PATH environment.
ENV PATH="${PATH}:/opt/Isabelle2021-1/bin"

# Add environment variables to locate AFP theories.
ENV AFP_BASE="/opt/$AFP_RELEASE"
ENV AFP_THYS="$AFP_BASE/thys"

# Install prerequisites to run isabelle jedit (X11 support).
RUN apt-get update -y && \
    apt-get install -y less rlwrap unzip && \
    apt-get install -y libfontconfig1 libgomp1 libxext6 libxrender1 libxtst6 libxi6 && \
    apt-get clean

# Create a regular work account the image user with UID 1000.
RUN useradd --create-home \
            --shell /bin/bash \
            --user-group \
            --uid 1000 work

# Customize bash prompt.
RUN echo                            >> /home/work/.bashrc && \
    echo '# Customize bash prompt (added by Dockerfile).' \
                                    >> /home/work/.bashrc && \
    echo 'export PS1="[\u@\h]\\$ "' >> /home/work/.bashrc

# Copy startup.sh script to perform posteriori setup tasks.
COPY resources/startup.sh startup.sh

# Enter the container as a regular user rather than root.
USER work

# The working directory is the work user's home folder.
WORKDIR /home/work

# The startup.sh script preforms the following actions:
#  1. patch the $AFP_THYS/ROOTS file according to .patch-afp;
#  2. execute whatever command is passed via CMD.
ENTRYPOINT ["/startup.sh"]

# If no CMD is provided, open a login shell to the container.
CMD ["/bin/bash", "--login"]
