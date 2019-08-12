MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

include $(MKFILE_DIR)/docker.include.mk

ENVIRONMENT ?=
PROCESS_RUN_ARGS =

FIRST_ARG := $(firstword $(MAKECMDGOALS))
LAST_ARG := $(lastword $(MAKECMDGOALS))

# The main variant-in-docker execution rule.
# Add this rule only if the file exists in the same dir
# having the name of the first make (make FIRST_ARG) argument.
ifneq (,$(wildcard $(FIRST_ARG)))
# Process RUN_ARGS
ifeq ($(FIRST_ARG),$(firstword $(MAKECMDGOALS)))
  PROCESS_RUN_ARGS = yes
endif
ifdef PROCESS_RUN_ARGS
  # use the rest as arguments for the rule
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

ifdef VARIANT
.PHONY: $(FIRST_ARG)
$(FIRST_ARG):
	@$(MAKE) docker.run.variant.vars \
		DOCKER_CMD_TITLE="Execute './$(FIRST_ARG) $(RUN_ARGS)' variant command in the docker container" \
		FIRST_ARG=$(firstword $(MAKECMDGOALS)) \
		VARIANT_ENVIRONMENT=$(ENVIRONMENT) \
		DOCKER_CMD="$(strip ./$(FIRST_ARG) $(RUN_ARGS))"
else
.PHONY: $(FIRST_ARG)
$(FIRST_ARG):
	@$(MAKE) docker.run \
		DOCKER_CMD_TITLE="Execute './$(FIRST_ARG) $(RUN_ARGS)' command in the docker container" \
		FIRST_ARG=$(firstword $(MAKECMDGOALS)) \
		DOCKER_CMD="$(strip ./$(FIRST_ARG) $(RUN_ARGS))"
endif
endif

TEMP_DIR ?= $(TOOLBOX_DIR)/.tmp

BINDED_VARS_ROOT ?= .
BINDED_VARS_TEMP_FILE ?= .vars.tmp
BINDED_VARS_TEMP_FILE_PATH ?= $(TEMP_DIR)/$(BINDED_VARS_TEMP_FILE)
BINDED_VARS_CMD ?= yq r -j $(FIRST_ARG) | jq -r "'$(BINDED_VARS_ROOT)' | recurse(.tasks[]?) | select(.bindParamsFromEnv == true) | .parameters | .[]? | .name" | uniq

VARIANT_VARS_TEMP_FILE ?= .vars.variant.tmp
VARIANT_VARS_TEMP_FILE_PATH ?= $(TEMP_DIR)/$(VARIANT_VARS_TEMP_FILE)

.PHONY: docker.run.variant.vars
docker.run.variant.vars:
	@mkdir -p $(TEMP_DIR)
	@rm -f $(BINDED_VARS_TEMP_FILE_PATH)
	@rm -f $(VARIANT_VARS_TEMP_FILE_PATH)

	@(env | grep VARIANT_) > $(VARIANT_VARS_TEMP_FILE_PATH)

	$(eval ENV_CMD = $(if $(VARIANT_ENVIRONMENT),./$(FIRST_ARG) env set $(ENVIRONMENT); ,))

	@$(MAKE) docker.run \
		DOCKER_CMD_TITLE="Retrieve variable names from the variant file" \
		IMAGE="$(VARS_RETRIEVE_IMAGE)" \
		DOCKER_SSH_AUTH_SOCK_FORWARD_PARAMS="" \
		DOCKER_CMD='$(BINDED_VARS_CMD) > $(BINDED_VARS_TEMP_FILE_PATH)'
	
	@$(MAKE) docker.run \
		DOCKER_CMD_TITLE="$(DOCKER_CMD_TITLE)" \
		DOCKER_ENV_FILE="$(VARIANT_VARS_TEMP_FILE_PATH)" \
		DOCKER_ENV_FILE2="$(BINDED_VARS_TEMP_FILE_PATH)" \
		DOCKER_ENV_VARS="$(DOCKER_ENV_VARS)" \
		DOCKER_CMD="$(ENV_CMD)$(DOCKER_CMD)" \
		IMAGE="$(IMAGE)" \
		DOCKER_RUN_VOLUMES="$(DOCKER_RUN_VOLUMES)"
		DOCKER_SSH_AUTH_SOCK_FORWARD_PARAMS="$(DOCKER_SSH_AUTH_SOCK_FORWARD_PARAMS)"

	@rm -f $(BINDED_VARS_TEMP_FILE_PATH)
	@rm -f $(VARIANT_VARS_TEMP_FILE_PATH)


