################################################################################
# Makefile to create the isabelle-x11 Docker image and runtime release archive #
# 2022 (c) by Frank Zeyda (frank.zeyda@gmail.com) for Galois, Inc.             #
################################################################################

# Directory for downloading installation software.
SOFTWARE_DIR = downloads

# Distribution of Isabelle to install into the image.
ISABELLE_DIST = Isabelle2021-1
ISABELLE_TAR  = Isabelle2021-1_linux.tar.gz

# AFP release of theories to install into the image.
AFP_RELEASE = afp-2022-10-01

# Build arguments for isabelle-x11 image creation.
BUILD_ARGS = --build-arg ISABELLE_DIST=$(ISABELLE_DIST) \
             --build-arg ISABELLE_TAR=$(ISABELLE_TAR) \
             --build-arg AFP_RELEASE=$(AFP_RELEASE)

# Includes variables for ANSI escape sequences to beautify output.
include makefile.ansi

all: downloads create-work image tidy-up

# Target to download installation software from the web.
downloads: $(SOFTWARE_DIR)/$(ISABELLE_TAR) \
           $(SOFTWARE_DIR)/$(AFP_RELEASE).tar.gz

# The below fetches the Isabelle tar archive from the TUM site.
$(SOFTWARE_DIR)/$(ISABELLE_TAR):
	@echo -e "$(ANSI_BLUE)Downloading $(ISABELLE_TAR) ...$(ANSI_RESET)"
	wget -P $(SOFTWARE_DIR) https://isabelle.in.tum.de/dist/$(ISABELLE_TAR)
	@echo -e "$(ANSI_BLUE)Extracting $(ISABELLE_TAR) ...$(ANSI_RESET)"
	cd downloads && tar xzf $(ISABELLE_TAR)

# The below fetches the AFP tar archive from AFP release site.
$(SOFTWARE_DIR)/$(AFP_RELEASE).tar.gz:
	@echo -e "$(ANSI_BLUE)Downloading $(AFP_RELEASE) ...$(ANSI_RESET)"
	wget -P $(SOFTWARE_DIR) https://www.isa-afp.org/release/$(AFP_RELEASE).tar.gz
	@echo -e "$(ANSI_BLUE)Extracting $(AFP_RELEASE) ...$(ANSI_RESET)"
	cd downloads && tar xzf $(AFP_RELEASE).tar.gz

# Create work directory from template if it does not already exist.
create-work: | work

# Target to create the work directory from template/work.
work:
	@echo -e "$(ANSI_BLUE)Creating 'work' directory from template ...$(ANSI_RESET)"
	cp -r template/work work

# Target to build the isabelle-x11 docker image in the local store.
image:
	@echo -e "$(ANSI_BLUE)Creating isabelle-x11 docker image ...$(ANSI_RESET)"
	docker build $(BUILD_ARGS) -t isabelle-x11 .

# Target to tidy up by removing dangling images.
tidy-up:
	@echo -e "$(ANSI_BLUE)Removing dangling images ...$(ANSI_RESET)"
	docker images --quiet --filter=dangling=true | xargs --no-run-if-empty docker rmi

# Create docker image as well as the runtime relase archive.
release: clean all
	@echo -e "$(ANSI_BLUE)Creating isabelle-docker-runtime.tar.gz ...$(ANSI_RESET)"
	rm -f work/.isabelle/$(ISABELLE_DIST)/jedit/settings-backup/*
	rm -f work/.isabelle/$(ISABELLE_DIST)/jedit/activity.log
	tar czf isabelle-docker-runtime.tar.gz isabelle-docker work

# Target to remove all dynamically generated files.
clean:
	rm -rf work
	rm -f isabelle-docker-runtime.tar.gz

# Target to additional remove all downloaded files.
sanitize: clean
	rm -rf downloads

.PHONY: all downloads create-work image tidy-up release clean sanitize
