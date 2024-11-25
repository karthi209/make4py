# ----------------------------------------------------------------------------
# Makefile tailored for RHEL 8
#
# Based on make4py with adjustments for RHEL-specific settings.
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
#  OS Detection
# ----------------------------------------------------------------------------
ON_RHEL8 := 1

# ----------------------------------------------------------------------------
#  VENV Detection
# ----------------------------------------------------------------------------
ifdef VIRTUAL_ENV
    IN_VENV        := 1
    SWITCH_TO_VENV := 0
else
    IN_VENV        := 0
    SWITCH_TO_VENV := $(USE_VENV)
endif

# ----------------------------------------------------------------------------
#  FUNCTIONS
# ----------------------------------------------------------------------------

# Recursive wildcard function. Call with: $(call rwildcard,<start dir>,<pattern>)
rwildcard = $(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

# ----------------------------------------------------------------------------
#  SETTINGS
# ----------------------------------------------------------------------------

SHELL  := /bin/bash
PYTHON := python3

# Determine platform string (RHEL version and architecture)
ifeq (, $(shell which lsb_release))
    PLATFORM_STRING := RHEL$(shell uname -r | cut -d'.' -f1)_$(shell uname -m)
else
    PLATFORM_STRING := $(shell lsb_release -i -s)$(shell lsb_release -r -s | grep -o -E "[0-9]+.[0-9]+")_$(shell uname -m)
endif
SHORT_PLATFORM := RHEL
SET_PYTHONPATH := PYTHONPATH=$(PYTHONPATH)

# File and directory operations for RHEL
RMDIR    = rm -rf $1
RMDIRR   = find . -name "$1" -exec rm -rf {} \; 2>/dev/null || true
RMFILE   = rm -f $1
RMFILER  = find . -iname "$1" -exec rm -f {} \;
MKDIR    = mkdir -p $1
COPY     = cp -a $1 $2
MOVE     = mv $1 $2
ZIP      = cd $1 && tar cfz $3.tgz $2

# Docker-specific adjustments
ifeq ($(IN_DOCKER),1)
    PLATFORM_SUFFIX := _docker
else
    PLATFORM_SUFFIX :=
endif

# ----------------------------------------------------------------------------
#  EOF
# ----------------------------------------------------------------------------
