# ----------------------------------------------------------------------------
# Makefile for make4py (RHEL 8 adaptation)
#
# Adapted for RHEL 8 systems.
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# CONFIGURATION
# ----------------------------------------------------------------------------
MAKE4PY_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
MAKE4PY_DIR_ABS := $(abspath $(MAKE4PY_DIR))
USE_VENV := $(or $(USE_VENV),1)

# Default settings
ALL_TARGET := $(or $(ALL_TARGET),help)
BUILD_DIR := $(or $(BUILD_DIR),build)
PYTHON_VERSION := 3.6  # Default RHEL 8 Python version
PYCODESTYLE_CONFIG := $(or $(PYCODESTYLE_CONFIG),$(MAKE4PY_DIR)/.pycodestyle)
SRC_DIRS := $(or $(SRC_DIRS),src test)
SOURCES := $(or $(SOURCES),$(call rwildcard,$(SRC_DIRS),*.py))
UNITTEST_DIR := $(or $(UNITTEST_DIR),test/unittests)
FUNCTEST_DIR := $(or $(FUNCTEST_DIR),test/functional_tests)
TEST_SUPPORT := $(or $(UNITTEST_DIR),$(FUNCTEST_DIR))
RELEASE_DIR := $(or $(RELEASE_DIR),releases)
CLEAN_FILES := $(or $(CLEAN_FILES),)
CLEAN_DIRS := $(or $(CLEAN_DIRS),)
CLEAN_DIRS_RECURSIVE := $(or $(CLEAN_DIRS_RECURSIVE),)
VARS_TO_PROPAGATE := $(or $(VARS_TO_PROPAGATE),UNITTESTS FUNCTESTS)

# ----------------------------------------------------------------------------
# TARGETS
# ----------------------------------------------------------------------------
.PHONY: all help clean distclean tests format style-check doc release

all: $(ALL_TARGET)

help:
	@echo "RHEL 8 Makefile for make4py:"
	@echo "Common Targets:"
	@echo "  help                   : Show this help message."
	@echo "  tests                  : Run all tests (unit and functional)."
	@echo "  format                 : Format code using black and isort."
	@echo "  style-check            : Run pylint, flake8, and mypy checks."
	@echo "  doc                    : Generate project documentation."
	@echo "  release                : Build the release for this platform."
	@echo "  clean                  : Remove temporary files."
	@echo "  distclean              : Remove all build artifacts and virtual environments."

# Tests
tests:
	@echo "Running tests..."
	@if [ -d "$(UNITTEST_DIR)" ]; then pytest $(UNITTEST_DIR); fi
	@if [ -d "$(FUNCTEST_DIR)" ]; then pytest $(FUNCTEST_DIR); fi

# Format code
format:
	@echo "Formatting source files..."
	black $(SRC_DIRS)
	isort $(SRC_DIRS)

# Check styles
style-check:
	@echo "Running style checks..."
	pylint $(SRC_DIRS)
	flake8 $(SRC_DIRS)
	mypy $(SRC_DIRS)

# Documentation
doc:
	@echo "Generating documentation..."
	@if [ -d "doc" ]; then sphinx-build -b html doc/source doc/build; fi

# Release
release:
	@echo "Building release..."
	pyinstaller --clean --onefile main.py -y

# Cleanup
clean:
	@echo "Cleaning temporary files..."
	rm -rf $(BUILD_DIR) dist .pytest_cache *.spec $(CLEAN_FILES)
	find $(SRC_DIRS) -name '*.pyc' -delete
	find $(SRC_DIRS) -name '__pycache__' -delete

distclean: clean
	@echo "Removing additional build artifacts..."
	rm -rf $(RELEASE_DIR) venv .mypy_cache *.egg-info $(CLEAN_DIRS_RECURSIVE)

# Environment setup
venv:
	@echo "Setting up virtual environment..."
	python3 -m venv venv
	. venv/bin/activate && pip install -r requirements.txt
