# Helm
HELM_UNITTEST_VERSION = 3.16.1-0.6.2
HELM_DOCS_VERSION = v1.14.2
HELM_DIR ?= charts/powerdns-operator
DOC_DIR ?= docs

OUTPUT_DIR ?= bin

# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

# ====================================================================================
# Colors

BLUE         := $(shell printf "\033[34m")
YELLOW       := $(shell printf "\033[33m")
RED          := $(shell printf "\033[31m")
GREEN        := $(shell printf "\033[32m")
CNone        := $(shell printf "\033[0m")

# ====================================================================================
# Logger

TIME_LONG	= `date +%Y-%m-%d' '%H:%M:%S`
TIME_SHORT	= `date +%H:%M:%S`
TIME		= $(TIME_SHORT)

INFO	= echo ${TIME} ${BLUE}[ .. ]${CNone}
WARN	= echo ${TIME} ${YELLOW}[WARN]${CNone}
ERR		= echo ${TIME} ${RED}[FAIL]${CNone}
OK		= echo ${TIME} ${GREEN}[ OK ]${CNone}
FAIL	= (echo ${TIME} ${RED}[FAIL]${CNone} && false)

# ====================================================================================

##@ Helm
helm-docs:
	@cd $(HELM_DIR); \
	docker run --rm -v $(shell pwd)/$(HELM_DIR):/helm-docs -u $(shell id -u) jnorwood/helm-docs:$(HELM_DOCS_VERSION)
	cp $(HELM_DIR)/README.md $(DOC_DIR)/README.md

HELM_VERSION ?= $(shell helm show chart $(HELM_DIR) | grep '^version:' | sed 's/version: //g')

helm-build:
	@$(INFO) helm package
	@helm package $(HELM_DIR) --dependency-update --destination $(OUTPUT_DIR)/chart
	@mv $(OUTPUT_DIR)/chart/powerdns-operator-$(HELM_VERSION).tgz $(OUTPUT_DIR)/chart/powerdns-operator.tgz
	@$(OK) helm package

helm-test:
	@cd $(HELM_DIR); \
	docker run --rm -v $(shell pwd)/$(HELM_DIR):/apps -u $(shell id -u) helmunittest/helm-unittest:$(HELM_UNITTEST_VERSION) .

helm-test-update:
	@cd $(HELM_DIR); \
	docker run --rm -v $(shell pwd)/$(HELM_DIR):/apps -u $(shell id -u) helmunittest/helm-unittest:$(HELM_UNITTEST_VERSION) -u .

