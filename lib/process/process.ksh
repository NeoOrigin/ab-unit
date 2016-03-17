#!/bin/ksh
#===============================================================================
#
#          FILE:  process.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/process/process.ksh 
# 
#   DESCRIPTION:  Handles process management.  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Philip Bowditch
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  13/09/2008 11:50:00 GMT Daylight Time
#      REVISION:  ---
#===============================================================================

#---  INCLUDES  ----------------------------------------------------------------
#   DESCRIPTION: Defines the external scripts used by this script
#-------------------------------------------------------------------------------

#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function process_run_cmd
{
    typeset PROCESS_CMD_NAME="${1}"
    typeset -u PROCESS_IN_BACKGROUND="${2}"

    shift 2

    case "${PROCESS_IN_BACKGROUND}" in

        Y | YES ) "${PROCESS_CMD_NAME}" "${@}" &
                  ;;
        *       ) "${PROCESS_CMD_NAME}" "${@}"
                  ;;

    esac
}

function process_get_ppid
{
    typeset -i PROCESS_PID="${1}"

    ps -ef | awk '{printf $2":"$3}' | grep "^${PROCESS_PID}:" | stream_split ":" 2
}

function process_get_user
{
    typeset -i PROCESS_PID="${1}"

    ps -ef | awk '{printf $2":"$1}' | grep "^${PROCESS_PID}:" | stream_split ":" 2
}

function process_get_children
{
    typeset -i PROCESS_PID="${1}"

    ps -ef | awk '{printf $2":"$3}' | grep ":${PROCESS_PID}$" | stream_split ":" 1
}

function process_get_user_processes
{
    typeset -i PROCESS_USER="${1:-$USER}"

    ps -ef | awk '{printf $1":"$2}' | grep "^${PROCESS_USER}:" | stream_split ":" 2
}