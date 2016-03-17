#!/bin/ksh
#===============================================================================
#
#          FILE:  math.ksh
#
#         USAGE:  . ${AB_UNIT_HOME}/lib/assert/math.ksh
#
#   DESCRIPTION:
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Philip Bowditch
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  01/10/2008 21:14:58 GMT Daylight Time
#      REVISION:  ---
#===============================================================================


#---  INCLUDES   ---------------------------------------------------------------
# Libraries used by this script
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

. "${AB_UNIT_HOME}/lib/assert/assertion.ksh"
. "${AB_UNIT_HOME}/lib/system/numeric.ksh"


#---  GLOBALS   ----------------------------------------------------------------
# Global variables used by this script
#-------------------------------------------------------------------------------


#-- FUNCTIONS ------------------------------------------------------------------
# Functions to be used by external scripts
#-------------------------------------------------------------------------------

function assert_number_eq
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    numeric_is_equal "${1}" "${2}" && return 0

    assert "assert_number_eq" "${3}" "Result is not equal, expected ${1}, actual ${2}"
}

function assert_number_ne
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_number_eq "${1}" "${2}" >/dev/null 2>&1  || return 0

    assert "assert_number_ne" "${3}" "Numbers are equal '${1}'"
}

function assert_number_gt
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    numeric_is_greater_than "${1}" "${2}" && return 0

    assert "assert_number_gt" "${3}" "Result '${2}' is less than or equal to expected '${1}'"
}

function assert_number_le
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_number_gt "${1}" "${2}" >/dev/null 2>&1 || return 0

    assert "assert_number_le" "${3}" "Result '${2}' is greater than expected '${1}'"
}

function assert_number_lt
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    numeric_is_less_than "${1}" "${2}" && return 0
    
    assert "assert_number_gt" "${3}" "Result '${2}' is greater than or equal to expected '${1}'"
}

function assert_number_ge
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_number_lt "${1}" "${2}" >/dev/null 2>&1 || return 0

    assert "assert_number_ge" "${3}" "Result '${2}' is less than expected '${1}'"
}

function assert_is_number
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    numeric_is_numeric "${1}" && return 0

    assert "assert_is_number" "${2}" "'${1}' is not a number"
}
