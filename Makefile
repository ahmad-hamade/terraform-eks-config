#
# this is a base makefile that includes the one from rp-tooling-general-scripts
#

include ../rp-tooling-general-scripts/update-terraform-repo/Makefile.inc

ifndef CE_MAKEFILE_INC_VERSION
$(error CE_MAKEFILE_INC_VERSION NOT FOUND - do you have rp-tooling-general-scripts update-terraform-docs?)
endif
ifneq "$(CE_MAKEFILE_INC_VERSION)" '1'
$(error CE_MAKEFILE_INC_VERSION MISMATCH - this repository supports version 1 only, not $(CE_MAKEFILE_INC_VERSION))
endif
