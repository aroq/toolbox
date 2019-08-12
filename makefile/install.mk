export SHELL = /bin/bash
export TOOLBOX_ORG ?= aroq
export TOOLBOX_PROJECT ?= toolbox
export TOOLBOX_BRANCH ?= master
export TOOLBOX_DIR ?= .toolbox
export TOOLBOX_CORE_DIR ?= $(TOOLBOX_DIR)/core
export TOOLBOX_PATH ?= $(shell until [ -d "$(TOOLBOX_DIR)" ] || [ "`pwd`" == '/' ]; do cd ..; done; pwd)/$(TOOLBOX_DIR)

_TOOLBOX_CORE_TOOLS_TOOLBOX_IMAGE ?= aroq/toolbox

-include $(TOOLBOX_PATH)/core/makefile/Makefile

.PHONY : init
## Init toolbox
init::
	@curl -H 'Cache-Control: no-cache' --retry 5 --fail --silent --retry-delay 1 https://raw.githubusercontent.com/$(TOOLBOX_ORG)/$(TOOLBOX_PROJECT)/$(TOOLBOX_BRANCH)/bin/install.sh?$(date +%s) | \
		bash -s "$(TOOLBOX_ORG)" "$(TOOLBOX_PROJECT)" "$(TOOLBOX_BRANCH)" "$(TOOLBOX_DIR)"
	@$(MAKE) .toolbox/core/tools/toolbox deps install

.PHONY : clean
## Clean toolbox
clean::
	@[ "$(TOOLBOX_PATH)" == '/' ] || \
	 [ "$(TOOLBOX_PATH)" == '.' ] || \
	   rm -fR $(TOOLBOX_PATH)
