# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

# grep the version from the mix file
VERSION=$(shell cat ./version.txt)

# Get the current dir
#PWD := $(abspath $(lastword $(MAKEFILE_LIST)))
PWD := 'c:\\Users\\gleit\\dev\\servantscode.org'

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help build

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
# Build the container
build: ## Build the container
	docker.exe build -t gregleitheiser/$(APP_NAME) .

build-nc: ## Build the container without caching
	docker.exe build --no-cache -t gregleitheiser/$(APP_NAME) .

run: ## Run container on port configured in `config.env`
	docker.exe run -dit --env-file=./config.env -p=$(EXT_PORT):$(INT_PORT) --name=$(APP_NAME) gregleitheiser/$(APP_NAME)

up: build run ## Run container on port configured in `config.env` (Alias to run)

stop: ## Stop and remove a running container
	docker.exe stop $(APP_NAME); docker.exe rm $(APP_NAME)

release: build-nc publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers to ECR

# Docker publish
publish: publish-latest publish-version ## Publish the `{version}` ans `latest` tagged containers to ECR

publish-latest: tag-latest ## Publish the `latest` taged container to ECR
	@echo 'publish latest to $(DOCKER_REPO)'
	docker.exe push gregleitheiser/$(APP_NAME):latest

publish-version: tag-version ## Publish the `{version}` taged container to ECR
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	docker.exe push gregleitheiser/$(APP_NAME):$(VERSION)

# Docker tagging
tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

tag-latest: ## Generate container `{version}` tag
	@echo 'create tag latest'
	docker.exe tag gregleitheiser/$(APP_NAME) gregleitheiser/$(APP_NAME):latest

tag-version: ## Generate container `latest` tag
	@echo 'create tag $(VERSION)'
	docker.exe tag gregleitheiser/$(APP_NAME) gregleitheiser/$(APP_NAME):$(VERSION)

logs: ## Get logs from running container
	kubectl.exe logs $(shell kubectl.exe get pods | grep $(APP_NAME) | grep Running | cut -d ' ' -f 1)

# HELPERS
version: ## Output the current version
	@echo $(VERSION)
