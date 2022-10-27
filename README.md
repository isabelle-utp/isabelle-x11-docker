# Isabelle docker image with X11 support

This repository contains resources (Dockerfile, scripts, makefile, etc.) to create a docker/podman image with **X11 support** for the current version of the Isabelle theorem prover ([Isabelle2022](https://isabelle.in.tum.de/)). The image can thus be used to start up Isabelle's jedit IDE via docker/podman on the host display. Currently, only Linux host systems are supported.

Here are a few further features and highlights:
- The image includes the entire [Archive of Formal Proofs](https://www.isa-afp.org/) developments, preconfigured in the local user's `ROOTS` file.
- A script `isabelle-docker` is provided that can be used as a drop-in replacement for `isabelle` to execute commands within the container as well as start up jedit inside the container i.e. via `isabelle-docker jedit`.
- Using the script, the home directory of the (regular) user *inside the container* is automatically mapped to a local `work` directory on the host, so that configuration changes and work on theories persist after shutting down the jedit IDE and thereby destroying the container.

The image is based on a recent version of Ubuntu ([22.10, Kinetic Kudu](https://www.omgubuntu.co.uk/2022/08/ubuntu-22-10-release-new-features)) and is with 3.89 GB more on the bulky side. This is, however, primarily due to the size of the Isabelle installation files (1.6 GB) and AFP (441 MB), as well as texlive installation and packages (~1.27 GB). The prerequisite packages for X11 support have actually little impact on the image size.

## Tool Versions

Images are public and obtained via the **Galois Inc** organization on [dockerhub](https://hub.docker.com/repositories).

The latest [isabelle-x11](https://hub.docker.com/repository/docker/galoisinc/isabelle-x11) image (version 1.1) provides:
- [Isabelle2022](https://isabelle.in.tum.de/) (October 2022)
- [afp-2022-10-05.tar.gz](https://www.isa-afp.org/release/afp-2022-10-05.tar.gz) (01 September 2022)

## For Users

A small runtime archive `isabelle-docker-runtime.tar.gz` is need to run the image. It is provided through the [Releases](https://github.com/isabelle-utp/isabelle-x11-docker/releases) site of this repository and ought be extracted via:

`tar xzvf isabelle-docker-runtime.tar.gz`

This creates (in the current folder)
- a script `isabelle-docker`;
- a directory `work`.

The script is used to run Isabelle in the same way that one would execute the `isabelle` command in a local installation. The respective docker image ([isabelle-x11:latest](https://hub.docker.com/repository/docker/galoisinc/isabelle-x11)) is automatically downloaded from the respective Galois Inc dockerhub repository.

Note that the local `work` subdirectory is mapped into the container as the home directory of the container's *work* user (`/home/work`). This means that everything saved there inside the container (including local Isabelle settings under `~/.isabelle`) persists between invocations of `isabelle-docker`. A suitable UID/GID namespace mapping ensures that the user on the host and inside the image are correctly related. To permit a X11 connection from the container to the host display, the host's `/tmp/.X11-unix` folder is moreover mapped into the image. It is hence advisable not to use the [isabelle-x11](https://hub.docker.com/repository/docker/galoisinc/isabelle-x11) dockerhub image naked but always start it via the `isabelle-docker` script which implicitly provides all necessary docker run configurations.

The script was tested on a [Rocky Linux 8.6](https://rockylinux.org/news/rocky-linux-8-6-ga-release/) OS. If you do encounter issues with it using another Linux Distribution, or have suggestions for improvement(s), please do not hesitate to contact the Isabelle/UTP team. Note that upon the first invocation of the `isabelle-docker` script, it may take a little bit of time (usually less than one minute) to set up the container due to the namespace mapping.

To start the Isabelle jedit IDE, simply execute:

`isabelle-docker jedit`

This furthermore opens a `Scratch.thy` theory file inside the image with a simple HOL example theory. Note that the full AFP is at your disposal for import, and implicitly configured as an additional entry in `~/.isabelle/Isabelle2022/ROOTS`. If you like to **blank out** certain entries of the AFP (which sometimes is necessary to avoid clashes and duplication with respect to local developments), simply add a file `.patch-afp` under the local `work` folder and add a corresponding line to that file for each entry to be blanked out. When the container starts, a script automatically then patches the `ROOTS` file of the AFP to remove such entries. (Beware, however, of superfluous spaces at the start end end of each entry.)

## For Developers

Developers may be interested how image creation proceeds (for users this is not relevant, since the image is already being made available through [dockerhub](https://hub.docker.com/repository/docker/galoisinc/isabelle-x11), as explained above). In addition to the [Dockerfile](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/Dockerfile), the repository also includes a [makefile](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/makefile) that by and large drives the image creation process, downloading and extracting the deployed Isabelle and AFP archives from the web.

The makefile provides the following targets (`all` is the default target):

| Target         | Description |
| -------------- | ----------- |
| make all | Complete process to create the isabelle-x11 image in the local docker/podman store. |
| make downloads | Downloads the deployed Isabelle distribution and AFP release and extracts them. |
| make image | Creates the isabelle-x11 docker/podman image in the local docker store. |
| make tidy-up | Removes dangling images from the local docker/podman store. |
| make create-work | Stages the `work` directory based on a respective template under `template/...`. |
| make release | Creates the isabelle-x11 image as well as **isabelle-docker-runtime.tar.gz** runtime release archive. |
| make clean | Removes all dynamically generated files. |
| make sanitize | Like the `clean` target but also removes all downloaded and extracted files. |

We note that the [setenv.sh](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/setenv.sh) script can be used to add the current and `bin` subfolders to `PATH`. It should be run via:

`source setenv.sh`

This provides and additional script [run.sh](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/bin/run.sh) in `PATH` that is similar to the [isabelle-docker](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/isabelle-docker) script in the top-level folder, but executes a given shell command passed to the script rather than `isabelle <SCRIPT ARGS>`. If no argument(s) are given, `run.sh` just opens a bash shell into the container, which is useful for debugging and 'having a look around'.

Another useful utility script under [bin](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/bin) is [remove-dangling.sh](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/bin/remove-dangling.sh), which remove dangling images in the local docker/podman store.

### Start-up Behaviour

When the isabelle-x11 container starts, it automatically executes the [startup.sh](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/resources/startup.sh) script found under [resources](https://github.com/isabelle-utp/isabelle-x11-docker/blob/main/resources). This prints some informative message about deployed tool versions and, if a `.patch-afp` file is present in the home folder, potentially removes some entries from the `ROOTS` file of the AFP installation under `/opt/afp-...`. Note that in order to disable the *entire* AFP, it is, however, easier to modify the `work/.isabelle/Isabelle2022/ROOTS` instead by removing or commenting out the entry `$AFP_THYS` there.

## Relationship to Isabelle/UTP

The repository [isabelle-utp-docker](https://github.com/isabelle-utp/isabelle-utp-docker) of the Isabelle/UTP GitHub organization provides an *extended* version of the `isabelle-docker-runtime.tar.gz` archive that includes the entire collection of Isabelle/UTP theories of various repositories inside the extracted `work` folder, included pre-compiled Isabelle heaps. Note that this runtime archive is not as compact as the one published here. It, however, uses the same [isabelle-x11](https://hub.docker.com/repository/docker/galoisinc/isabelle-x11) docker image presented here.
