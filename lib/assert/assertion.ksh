#!/bin/ksh
#===============================================================================
#
#          FILE:  assertion.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/assertion.ksh
# 
#   DESCRIPTION:  Contains base functions used to implement assert mechanisms in 
#                 the test framework
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

#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function assert
{
    #===============================================================================
    #          NAME:  assert
    #   DESCRIPTION:  Base function to be used by all specialised assert methods
    #         USAGE:  assert <function_name> <user_message> <default_message>
    #       RETURNS:  1
    #===============================================================================

    typeset NAMED_FUNCTION="${1}"
    typeset CUSTOM_ERR="${2}"
    typeset DEFAULT_ERR="${3}"

    #
    # If the user did not pass a message then use the inbuild default
    # else use failed if nothing specified before outputing the message
    # to stderr and returning false
    #

    if [ -z "${CUSTOM_ERR}" ] ; then

        CUSTOM_ERR="${DEFAULT_ERR}"

    fi

    if [ -z "${CUSTOM_ERR}" ] ; then

        CUSTOM_ERR="Failed"

    fi

    printf "%s: %s\n" "${NAMED_FUNCTION}" "${CUSTOM_ERR}" >&2
    return 1
}


function fail
{
    #===============================================================================
    #          NAME:  fail
    #   DESCRIPTION:  Base function to be used for unconditional failure messages
    #         USAGE:  fail <user_message>
    #       RETURNS:  1
    #===============================================================================

    typeset CUSTOM_ERR="${1}"

    assert fail "${CUSTOM_ERR}" "Failed"
}
