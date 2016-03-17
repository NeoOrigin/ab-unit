#!/bin/ksh
#===============================================================================
#
#          FILE:  system.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/system/system.ksh
# 
#   DESCRIPTION:  Handles access to operating system and shell specific functions
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


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function system_get_functions
{
    #===============================================================================
    #          NAME:  system_get_functions
    #   DESCRIPTION:  Prints all the defined functions loaded within the current shell
    #         USAGE:  system_get_functions
    #       RETURNS:  A newline delimited list of function names
    #===============================================================================

    typeset NAMES="$(declare -F 2>/dev/null || typeset +f 2>/dev/null)"

    echo "${NAMES}" | sed 's/declare -f //' | sed 's/^\([^ ]*\)() .*$/\1/'
}


function system_get_date
{
    #===============================================================================
    #          NAME:  system_get_date
    #   DESCRIPTION:  Returns the system date in YYYYMMDD format
    #         USAGE:  system_get_date
    #       RETURNS:  An 8 character string representing the system date at time of call
    #===============================================================================

    date '+%Y%m%d'
}

function system_get_epoch
{
    date '+%s'
}

function system_convert_date
{
    date -d "${1}" "${2}"
}

function system_get_datetime
{
    #===============================================================================
    #          NAME:  system_get_datetime
    #   DESCRIPTION:  Returns the system time in YYYYMMDDHH24MISS format
    #         USAGE:  system_get_datetime
    #       RETURNS:  A 14 character string representing the system time at time of call
    #===============================================================================

    date '+%Y%m%d%H%M%S'
}


function system_get_time
{
    #===============================================================================
    #          NAME:  system_get_time
    #   DESCRIPTION:  Returns the system time in HH24MISS format
    #         USAGE:  system_get_time
    #       RETURNS:  A 6 character string representing the system time at time of call
    #===============================================================================

    date '+%H%M%S'
}


function system_get_datetime_difference
{
    #===============================================================================
    #          NAME:  system_get_datetime_difference
    #   DESCRIPTION:  Returns the difference in seconds between two times in YYYYMMDDHH24MISS format
    #         USAGE:  system_get_datetime_difference <start> <end>
    #       RETURNS:  The number of seconds difference
    #===============================================================================

    true
}


function system_create_pipe
{
    #===============================================================================
    #          NAME:  system_create_pipe
    #   DESCRIPTION:
    #         USAGE:  system_create_pipe <filepath>
    #       RETURNS:
    #===============================================================================

    mkfifo "${1}"

    #mknod "${1}" p
}


function system_remove_pipe
{
    #===============================================================================
    #          NAME:  system_remove_pipe
    #   DESCRIPTION:
    #         USAGE:  system_remove_pipe <filepath>
    #       RETURNS:
    #===============================================================================

    rm "${1}"
}


function system_create_block_file
{
    #===============================================================================
    #          NAME:  system_create_block_file
    #   DESCRIPTION:
    #         USAGE:  system_create_block_file <filepath> <major> <minor>
    #       RETURNS:
    #===============================================================================

    mknod "${1}" b "${2}" "${3}"
}


function system_create_character_file
{
    #===============================================================================
    #          NAME:  system_create_character_file
    #   DESCRIPTION:
    #         USAGE:  system_create_character_file <filepath> <major> <minor>
    #       RETURNS:
    #===============================================================================

    mknod "${1}" c "${2}" "${3}"
}


function system_current_directory
{
    #===============================================================================
    #          NAME:  system_current_directory
    #   DESCRIPTION:
    #         USAGE:  system_current_directory [<real:Y>]
    #       RETURNS:
    #===============================================================================

    typeset SYSTEM_ALLOW_LOGICAL="${1}"
    typeset SYSTEM_ARGS=""

    if [ -n "${SYSTEM_ALLOW_LOGICAL}" ] ; then

        SYSTEM_ARGS="-P"

    fi

    pwd ${SYSTEM_ARGS}
}


function system_print
{
    #===============================================================================
    #          NAME:  system_print
    #   DESCRIPTION:  Prints arguments to standard output
    #         USAGE:  system_print [<args>]*
    #       RETURNS:
    #===============================================================================

    echo "${@}"
}
