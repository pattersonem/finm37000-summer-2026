default: help

help: ## Show make commands. Most commands require a dev env (e.g., `make dev`), but dev is not a dependency to allow alternate env workflows.
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# If you see "python-not-found" then you need to depend on python-installed.
PYTHON:=python-not-found

.PHONY: python-venv
python-venv:
ifndef VIRTUAL_ENV
	$(error VIRTUAL_ENV is undefined. Please activate a Python virtual environment.)
endif

# All targets that need python must depend on this to ensure the PYTHON variable
# is appropriately set.
.PHONY: python-installed
python-installed: python-venv
	@$(eval PYTHON:=$(shell which python))

.PHONY: uv-installed
uv-installed:
	@$(eval UV:=$(shell which uv))

.PHONY: info
info: python-installed uv-installed  ## Print out some variables to check your environment.
	@echo Using venv $(VIRTUAL_ENV)
	@echo Using python from $(PYTHON)
	@echo Using uv from $(UV)

.PHONY: package
package: uv-installed  ## Install Python package with uv (venv should be active before invoking make!!).
	$(UV) pip install -e .

.PHONY: dev
dev: uv-installed python-installed  ## Install dev packages with uv (venv should be active before invoking make!!).
	$(UV) pip install --group dev

.PHONY: demo
demo: uv-installed  ## Install packages to run notebooks with uv (venv should be active before invoking make!!).
	$(UV) pip install --group demo

.PHONY: setup
setup: package dev demo  ## Install package, dev tools, and demo to run notebooks with uv (venv should be active before invoking make!!).
	@echo All dependencies installed to your virtual env. Pick a name for the ipython kernel if you want to run notebooks:
	@echo   python -m ipykernel install --user --name=my_env_name --display-name=\"My Environment Name\"

.PHONY: lint
lint: python-installed  ## Checks if the source currently matches code conventions.
	$(PYTHON) -m ruff check

.PHONY: lint-fix
lint-fix: python-installed  ## Checks if everything matches code conventions & fixes those which are trivial to do so.
	$(PYTHON) -m ruff check --fix

.PHONY: format
format: python-installed  ## Format source files.
	$(PYTHON) -m ruff format

.PHONY: typecheck
typecheck: python-installed  ## Format source files.
	$(PYTHON) -m mypy

.PHONY: test
test: python-installed  ## Runs the tests.
	$(PYTHON) -m pytest
	@echo Tests pass

.PHONY: check
check: lint typecheck test  ## Runs all checks required before committing.

.PHONY: pre-commit  ## Runs all checks required before committing (fixing trivial things automatically).
pre-commit: lint-fix typecheck format

.PHONY: clean
clean:  ## Cleans up everything
	@echo Edit Makefile if there is stuff that needs cleaning.

