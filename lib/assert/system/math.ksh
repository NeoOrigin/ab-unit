#!/bin/ksh
#===============================================================================
#
#          FILE:  math.ksh
#
#         USAGE:  . ${AB_UNIT_HOME}/lib/assert/system/math.ksh
#
#   DESCRIPTION:
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Philip Bowditch
#       COMPANY:  Neo Origin Limited
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
    #          NAME:  assert_number_eq
    #   DESCRIPTION:  
    #         USAGE:  assert_number_eq <num1> <num2> [<usermessage>]
    #       RETURNS:  
    #===============================================================================

    numeric_is_equal "${1}" "${2}" && return 0

    assert "assert_number_eq" "${3}" "Result is not equal, expected ${1}, actual ${2}"
}

function assert_number_ne
{
    #===============================================================================
    #          NAME:  assert_number_ne
    #   DESCRIPTION:  
    #         USAGE:  assert_number_ne <num1> <num2> [<usermessage>]
    #       RETURNS:  
    #===============================================================================

    assert_number_eq "${1}" "${2}" >/dev/null 2>&1  || return 0

    assert "assert_number_ne" "${3}" "Numbers are equal '${1}'"
}

function assert_number_gt
{
    #===============================================================================
    #          NAME:  assert_number_gt
    #   DESCRIPTION:  
    #         USAGE:  assert_number_gt <num1> <num2> [<usermessage>]
    #       RETURNS:  
    #===============================================================================

    numeric_is_greater_than "${1}" "${2}" && return 0

    assert "assert_number_gt" "${3}" "Result '${2}' is less than or equal to expected '${1}'"
}

function assert_number_le
{
    #===============================================================================
    #          NAME:  assert_number_le
    #   DESCRIPTION:  
    #         USAGE:  assert_number_le <num1> <num2> [<usermessage>]
    #       RETURNS:  
    #===============================================================================

    assert_number_gt "${1}" "${2}" >/dev/null 2>&1 || return 0

    assert "assert_number_le" "${3}" "Result '${2}' is greater than expected '${1}'"
}

function assert_number_lt
{
    #===============================================================================
    #          NAME:  assert_number_lt
    #   DESCRIPTION:  
    #         USAGE:  assert_number_lt <num1> <num2> [<usermessage>]
    #       RETURNS:  
    #===============================================================================

    numeric_is_less_than "${1}" "${2}" && return 0
    
    assert "assert_number_gt" "${3}" "Result '${2}' is greater than or equal to expected '${1}'"
}

function assert_number_ge
{
    #===============================================================================
    #          NAME:  assert_number_ge
    #   DESCRIPTION:  
    #         USAGE:  assert_number_ge <num1> <num2> [<usermessage>]
    #       RETURNS:  
    #===============================================================================

    assert_number_lt "${1}" "${2}" >/dev/null 2>&1 || return 0

    assert "assert_number_ge" "${3}" "Result '${2}' is less than expected '${1}'"
}

function assert_is_number
{
    #===============================================================================
    #          NAME:  assert_is_number
    #   DESCRIPTION:  
    #         USAGE:  assert_is_number <num> [<usermessage>]
    #       RETURNS:  
    #===============================================================================

    numeric_is_numeric "${1}" && return 0

    assert "assert_is_number" "${2}" "'${1}' is not a number"
}

function assert_is_not_number
{
    #===============================================================================
    #          NAME:  assert_is_not_number
    #   DESCRIPTION:  
    #         USAGE:  assert_is_not_number <num> [<usermessage>]
    #       RETURNS:  
    #===============================================================================

    assert_is_number "${1}" >/dev/null 2>&1 || return 0

    assert "assert_is_not_number" "${2}" "'${1}' is a number"
}

function assert_is_zero
{
    #===============================================================================
    #          NAME:  assert_is_zero
    #   DESCRIPTION:  
    #         USAGE:  assert_is_zero <num> [<usermessage>]
    #       RETURNS:  
    #===============================================================================

    assert_number_eq 0 "${1}" >/dev/null 2>&1 || return 0

    assert "assert_is_zero" "${2}" "'${1}' is not equal to zero"
}

function assert_is_not_zero
{
    #===============================================================================
    #          NAME:  assert_is_not_zero
    #   DESCRIPTION:  
    #         USAGE:  assert_is_not_zero <num> [<usermessage>]
    #       RETURNS:  
    #===============================================================================

    assert_number_ne 0 "${1}" >/dev/null 2>&1 || return 0

    assert "assert_is_not_zero" "${2}" "'${1}' is equal to zero"
}

function assert_is_positive
{
    #===============================================================================
    #          NAME:  assert_is_positive
    #   DESCRIPTION:  
    #         USAGE:  assert_is_positive <num> [<usermessage>]
    #       RETURNS:  
    #===============================================================================

    assert_number_ge 0 "${1}" >/dev/null 2>&1 || return 0

    assert "assert_is_positive" "${2}" "'${1}' is not a positive number"
}

function assert_is_negative
{
    #===============================================================================
    #          NAME:  assert_is_negative
    #   DESCRIPTION:  
    #         USAGE:  assert_is_negative <num> [<usermessage>]
    #       RETURNS:  
    #===============================================================================

    assert_number_lt 0 "${1}" >/dev/null 2>&1 || return 0

    assert "assert_is_negative" "${2}" "'${1}' is not a negative number"
}
