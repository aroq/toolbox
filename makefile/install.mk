export SHELL = /bin/bash
export TOOLBOX_ORG ?= aroq
export TOOLBOX_PROJECT ?= toolbox
export TOOLBOX_BRANCH ?= master
export TOOLBOX_DIR ?= .toolbox
# export TOOLBOX_CORE_DIR ?= $(TOOLBOX_DIR)/core
# export TOOLBOX_PATH ?= $(shell until [ -d "$(TOOLBOX_DIR)" ] || [ "`pwd`" == '/' ]; do cd ..; done; pwd)/$(TOOLBOX_DIR)

export TOOLBOX_DOCKER_IMAGE_VERSION ?= $(shell if [ -f .toolbox/core/VERSION ]; then cat .toolbox/core/VERSION; else echo 'latest'; fi)

export _TOOLBOX_CORE_TOOLS_TOOLBOX_IMAGE ?= aroq/toolbox:$(TOOLBOX_DOCKER_IMAGE_VERSION)
export VARS_RETRIEVE_IMAGE ?= aroq/toolbox:$(TOOLBOX_DOCKER_IMAGE_VERSION)
export TOOLBOX_DOCKER_SSH_FORWARD ?= false

check2:
	echo "$(TOOLBOX_PROJECT)/$(TOOLBOX_DIR)/deps/toolbox/makefile/Makefile"

-include $(TOOLBOX_PROJECT)/$(TOOLBOX_DIR)/deps/toolbox/makefile/Makefile

## Clean toolbox
.PHONY : clean
clean::
	@[ "$(TOOLBOX_PATH)" == '/' ] || \
	 [ "$(TOOLBOX_PATH)" == '.' ] || \
	   rm -fR $(TOOLBOX_PATH)


