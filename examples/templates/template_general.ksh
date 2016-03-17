#!/bin/ksh
#===============================================================================
#
#          FILE:  template_general.ksh
#
#         USAGE:  ./template_general.ksh
#
#   DESCRIPTION:  A brief description of the script
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  John Smith, john.smith@my_company.com
#       COMPANY:  My Company PLC
#       VERSION:  1.0
#       CREATED:  21/10/2008 21:14:58 GMT Daylight Time
#      REVISION:  ---
#
#===============================================================================


#---  INCLUDES  ----------------------------------------------------------------
#   DESCRIPTION: Defines the external scripts used by this script
#-------------------------------------------------------------------------------

#---  GLOBALS   ----------------------------------------------------------------
#   DESCRIPTION:  Global variables used by this script
#-------------------------------------------------------------------------------


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function print_usage
{
	echo "$0: custom message" >&2
	exit 1
}

#===  FUNCTION  ================================================================
#          NAME:  my_function
#   DESCRIPTION:  A brief description of the function
#    PARAMETERS:  1 [Required] description, 2 [Optional] description
#       RETURNS:  0 if ...
#===============================================================================

function my_function
{
	return 0
}


#--  MAIN  ---------------------------------------------------------------------
#   DESCRIPTION:  
#-------------------------------------------------------------------------------

