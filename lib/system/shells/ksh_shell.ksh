#!/bin/ksh
#===============================================================================
#
#          FILE:  ksh_shell.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/system/shells/ksh_shell.ksh
# 
#   DESCRIPTION:  Korn shell specific functions
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Philip Bowditch
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  12/09/2008 08:53:34 GMT Daylight Time
#      REVISION:  ---
#===============================================================================

#---  INCLUDES  ----------------------------------------------------------------
#   DESCRIPTION: Defines the external scripts used by this script
#-------------------------------------------------------------------------------

#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function ksh_load_script
{
    typeset TEST_SCRIPT="${@}"

    . "${TEST_SCRIPT}"
}


function ksh_syntax_check
{
    typeset TEST_COMMANDS="${@}"

    ksh -n "${TEST_COMMANDS}"
}

function ksh_print
{
    echo "${@}"
}

function ksh_function_definition
{
    typeset -f "${1}"
}

function ksh_function_metadata
{
    typeset TEST_FUNCTION_DEF=$(ksh_function_definition "${1}")

    typeset LINE_FOUND=false

    ksh_print "${TEST_FUNCTION_DEF}" | while read ksh_line ; do

        if [ -n "${ksh_line}" ] ; then

            LINE_FOUND=true

            typeset TEST_LINE=$(ksh_print "${ksh_line}" | sed 's|^[ ]*||g' | cut -d"#" -f2-)

        elif [ "${LINE_FOUND}" == "true" ] ; then

            break

        fi

    done
}
