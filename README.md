# Disclaimer

This repository is just in the process of being set up. This means that
1. a release with run-time `isabelle-docker-runtime.tar.gz` has not been created yet;
2. the isabelle-x11 docker/podman image has not been pushed yet.

We should have this done in the next day or two!

# Isabelle docker image with X11 support

This repository contains resources (Dockerfile, scripts, makefile, etc.) to create a docker/podman image with **X11 support** for the current version of the Isabelle theorem prover ([Isabelle2021-1](https://isabelle.in.tum.de/)). The image can thus be used to start up Isabelle's jedit IDE via docker/podman on the host display. Currently, only Linux host systems are supported.

Here are a few further features and highlights:
- The image includes the [Archive of Formal Proofs](https://www.isa-afp.org/) developments, preconfigured as a component.
- A script `isabelle-docker` is provided that can be used as a drop-in replacement for `isabelle` to execute commands within the container and start up jedit inside the container i.e. via `isabelle-docker jedit`.
- Using the script, the home directory of the image user *inside the container* is mapped automatically to a local `work` directory outside on the host, so that both configuration changes and work on theories persist after shutting down the jedit IDE and thus destroying the container.

The image is based on a recent version of Ubuntu ([22.10, Kinetic Kudu](https://www.omgubuntu.co.uk/2022/08/ubuntu-22-10-release-new-features)) and is with 1.85 GB more on the bulky side. This is, however, primarily due to the size of the Isabelle installation files (1.3 GB) and AFP (~586 MB), rather than prerequisite packages i.e. for X11 support.

## Tool Versions

The latest [isabelle-x11]() image (version 1.0) provides:
- [Isabelle2021-1](https://isabelle.in.tum.de/) (December 2021)
- [afp-2022-10-01.tar.gz](https://www.isa-afp.org/release/afp-2022-10-01.tar.gz) (01 September 2022)

## For Users

A small runtime archive `isabelle-docker-runtime.tar.gz` is provided that needs to be downloaded from the [Releases](https://github.com/isabelle-utp/isabelle-x11-docker/releases) site and be extracted via:

`tar xzvf isabelle-docker-runtime.tar.gz`

This creates (in the current folder)
- a script `isabelle-docker`;
- a directory `work`.

The script is used to run Isabelle in the same way that one would execute the `isabelle` command in a local installation. The respective docker image ([isabelle-x11:latest]()) is automatically downloaded from the [Galois Inc](https://hub.docker.com/orgs/galoisinc/repositories) organization on dockerhub.

Note that the local `work` subdirectory is mapped into the container as the home directory of the container's *work* user (`/home/work`). This means that everything saved under the home folder inside the image (including Isabelle configurations under `~/.isabelle`) persists between invocations of `isabelle-docker`. A suitable UID/GID namespace mapping ensures that the user on the host and inside the image are correctly identified. To permit a X11 connection from the container to the host display, the host's `/tmp/.X11-unix` folder is moreover mapped into the image. It is hence advisable not to use the [isabelle-x11]() dockerhub image naked but always start it via the `isabelle-docker` script which implicitly provides all necessary docker run configuration.

The script was tested on a [Rocky Linux 8.6](https://rockylinux.org/news/rocky-linux-8-6-ga-release/) OS. If you do encounter issues with it, or have suggestions for improvement(s), please do not hesitate to contact the Isabelle/UTP team. Note that upon the first invocation of the `isabelle-docker` script, it may take a little bit of time (less than one minute) to set up the container due to the namespace mapping.

To start the Isabelle jedit IDE, simply execute:

`isabelle-docker jedit`

This furthermore opens a `Scratch.thy` theory file inside the image with a simple HOL example theory. Note that the full AFP is at your disposal for import.

## For Developers

Developers may be interested how image creation proceeds (for users this is not relevant, since the image is already being made available through [dockerhub](https://hub.docker.com/orgs/galoisinc/repositories), as explained above). In addition to the [Dockerfile](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/Dockerfile), the repository also includes a [makefile](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/makefile) that by and large drives the image creation process, downloading the relevant Isabelle and AFP archives deployed by the image from the web.

The makefile provides the following targets (**all** is the default target):

| Target         | Description |
| -------------- | ----------- |
| make all | Creates the isabelle-x11 image in the local docker/podman store. |
| make downloads | Downloads the Isabelle distribution and AFP release archives. |
| make image | Creates the isabelle-x11 docker/podman image in the local docker store. |
| make tidy-up | Removes dangling images from the local docker/podman store. |
| make create-work | Stages the `work` directory based on a respective template under `template/...`. (This is for the runtime release archive.) |
| make release | Creates the isabelle-x11 image as well as **isabelle-docker-runtime.tar.gz** runtime release archive. |
| make clean | Removes all dynamically generated files. |
| make sanitize | Like clean but also removes all downloaded files. |

We note that the [setenv.sh](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/setenv.sh) script can be used to add the *current* and *bin* subfolders to `PATH`. It should be run via:

`source setenv.sh`

This provides and additional script [run.sh](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/bin/run.sh) in `PATH` that is similar to the [isabelle-docker](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/isabelle-docker) script in the top-level folder, but executes a given shell command passed to the script rather than `isabelle ARGS`. If no argument(s) are given, `run.sh` just opens a bash shell into the container, which is useful for debugging and having look around.

Another useful utility script under [bin](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/bin) is [remove-dangling.sh](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/bin/remove-dangling.sh), which remove dangling images in the local docker/podman store.

### Start-up Behaviour

When the isabelle-x11 container starts, it automatically executes the [startup.sh](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/resources/startup.sh) script found under [resources](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/resources). This prints some informative message about deployed tool versions and adds the distributed AFP (found in the container under `/opt/afp-YYYY-MM-DD`) to the Isabelle `components` configuration file, providing that file does not yet exist.

**REVIEWED UNTIL HERE**

## Relationship to Isabelle/UTP

The repository [isabelle-utp-docker](https://github.com/isabelle-utp/isabelle-utp-docker) provides an *extended* version of the `isabelle-docker-runtime.tar.gz` archive that includes the entire collection of Isabelle/UTP theories of various repositories inside the extracted `work` folder, included pre-compiled Isabelle heaps for all of them. Note that this runtime archive (with ... GB) is not as compact as the one published here.
