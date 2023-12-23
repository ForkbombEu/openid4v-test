.DEFAULT_GOAL := help
.PHONY: help

ROOT_DIR       = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
VENV 					 = .venv
VENV_PYTHON    = $(ROOT_DIR)/$(VENV)/bin/python
ACTIVATE 			 = $(ROOT_DIR)/$(VENV)/bin/activate
SYSTEM_PYTHON  = $(or $(shell which python3), $(shell which python))
PYTHON         = $(or $(wildcard $(VENV_PYTHON)), $(SYSTEM_PYTHON))
PIP            = $(ROOT_DIR)/$(VENV)/bin/pip
POETRY         = $(ROOT_DIR)/$(VENV)/bin/poetry
SERVERS				 = $(ROOT_DIR)/openid4v/examples/entities
LOGS					 = $(SERVERS)/log

DEPS = python
K := $(foreach exec,$(DEPS),\
        $(if $(shell which $(exec)),some string,$(error "🥶 `$(exec)` not found in PATH please install it")))

help: ## 🛟 Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf " \033[36m⦿ %-7s\033[0m %s\n\n", $$1, $$2}'

$(VENV_PYTHON):
	rm -rf $(VENV)
	$(SYSTEM_PYTHON) -m venv $(VENV)
	$(PIP) install poetry
	$(PIP) install setuptools

venv: $(VENV_PYTHON)

fedservice:
	git clone https://github.com/rohe/fedservice
	cd fedservice && $(PYTHON) setup.py install

idpy-oidc:
	git clone https://github.com/IdentityPython/idpy-oidc
	cd idpy-oidc && $(PYTHON) setup.py install

openid4v:
	git clone https://github.com/rohe/openid4v
	cd openid4v && $(PYTHON) setup.py install

idpy-sdjwt:
	git clone https://github.com/rohe/idpy-sdjwt
	. $(ACTIVATE) && cd idpy-sdjwt && poetry install

deps: venv openid4v fedservice idpy-sdjwt idpy-oidc 
	$(PIP) install flask

stop: ## 🚫 Stop all services
	cd $(SERVERS) && ./kill_all.sh

up: deps stop ## 🚀 Launch all services
	mkdir -p $(LOGS)
	. $(ACTIVATE) && \
		cd $(SERVERS) && \
		$(PYTHON) setup.py install && \
		./start_all.sh

logs: ## 🧻 Show logs
	tail -f $(LOGS)/*

clean: ## 🧹 Clean the project
	rm -rf $(VENV) idpy-sdjwt fedservice idpy-oidc openid4v
