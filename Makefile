# Variables
PROJECT_NAME := $(notdir $(CURDIR))
PROJECT_INSIDE_CONTAINER := /workspace/$(PROJECT_NAME)
CONTAINER_NAME := $(PROJECT_NAME)_devcontainer

# Set the default target
.DEFAULT_GOAL := run


# Target to enter the development container
.PHONY: run
run:
# If the container doesn't exist yet, create it and enter it
# Otherwise, start and endter it
	@if [ -z $$(docker ps -aqf "name=$(CONTAINER_NAME)") ]; then \
		docker run -it \
			--name $(CONTAINER_NAME) \
			--volume $(CURDIR):$(PROJECT_INSIDE_CONTAINER) \
			--workdir $(PROJECT_INSIDE_CONTAINER) \
			ghcr.io/gauthsvenkat/development-environment; \
	else \
		docker start -i $(CONTAINER_NAME); \
	fi

.PHONY: clean
clean:
	docker rm $(CONTAINER_NAME)
