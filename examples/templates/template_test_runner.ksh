#!/bin/ksh

#---  INCLUDES  ----------------------------------------------------------------
#   DESCRIPTION: Defines the external scripts used by this script
#-------------------------------------------------------------------------------

if [ -z "${AB_UNIT_HOME}" ] ; then

	echo "ERROR: AB_UNIT_HOME environment variable is not set" >&2
	exit 1

fi

. "${AB_UNIT_HOME}/lib/test_runner_control.ksh"


#---  GLOBALS   ----------------------------------------------------------------
#   DESCRIPTION:  Global variables used by this script
#-------------------------------------------------------------------------------


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------
