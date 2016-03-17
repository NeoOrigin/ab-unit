#!/bin/ksh
#===============================================================================
#
#          FILE:  test_framework.ksh
# 
#         USAGE:  ${AB_UNIT_HOME}/bin/test_framework.ksh
#
#   DESCRIPTION:  This script is intended to perform low level testing of the
#                 AB_UNIT test framework upon installation.
#
#                 Note that external test scripts are called from the 'test'
#                 folder, for the most part these do not use the inbuilt
#                 functionality of the framework itself (because that is what
#                 we are testing) therefore these tests may be inconsistent
#                 across platforms.
#
#                 If platform errors do arise then please contact the developer
#                 to provide appropriate patches to these scripts.
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Philip Bowditch
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  19/09/2008 18:36:49 GMT Daylight Time
#      REVISION:  ---
#==============================================================================


#---  INCLUDES  ----------------------------------------------------------------
#   DESCRIPTION: Defines the external scripts used by this script
#-------------------------------------------------------------------------------

if [ -z "${AB_UNIT_HOME}" ] ; then

    echo "ERROR: AB_UNIT_HOME environment variable is not set" >&2
    exit 1

fi

if [ ! -e "${AB_UNIT_HOME}" ] ; then

    echo "ERROR: AB_UNIT_HOME environment variable points to a directory that does not exist" >&2
    exit 2

fi

if [[ ! -d "${AB_UNIT_HOME}" && ! -L "${AB_UNIT_HOME}" ]] ; then

    echo "ERROR: AB_UNIT_HOME environment variable is not a valid directory" >&2
    exit 3

fi


#---  GLOBALS   ----------------------------------------------------------------
#   DESCRIPTION:  Global variables used by this script
#-------------------------------------------------------------------------------


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------


#-- MAIN -----------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------

trap "" INT QUIT KILL TERM

    find "${AB_UNIT_HOME}/test/" -type f -a -name "*.ksh" -exec {} \;

trap - INT QUIT KILL TERM
