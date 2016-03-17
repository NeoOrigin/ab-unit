#!/bin/ksh
#===============================================================================
#
#          FILE:  logger.ksh
#
#         USAGE:  . ${AB_UNIT_HOME}/lib/io/logger.ksh
#
#   DESCRIPTION:  Core logging functionality for the test runner application
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Philip Bowditch
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  12/09/2008 09:04:14 GMT Daylight Time
#      REVISION:  ---
#===============================================================================



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

if [ ! -e "${AB_UNIT_HOME}/lib/system/system.ksh" ] ; then

    echo "ERROR: Core library ${AB_UNIT_HOME}/lib/system/system.ksh not found" >&2
    exit 4

fi

if [ ! -e "${AB_UNIT_HOME}/etc/logger.cfg" ] ; then

    echo "ERROR: Core configuration file ${AB_UNIT_HOME}/etc/logger.cfg not found" >&2
    exit 5

fi

. "${AB_UNIT_HOME}/lib/system/system.ksh"
. "${AB_UNIT_HOME}/lib/io/stream.ksh"
. "${AB_UNIT_HOME}/etc/logger.cfg"


#---  GLOBALS   ----------------------------------------------------------------
#   DESCRIPTION: Defines global variables used within this script
#-------------------------------------------------------------------------------

LOGGER_RUN_HOST=$(uname -n)
LOGGER_RUN_TIME=$(system_get_datetime)
LOGGER_RUN_DATE=$(echo "${LOGGER_RUN_TIME}" | stream_substring 1 8)


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function logger_eval_string
{
    #===============================================================================
    #          NAME:  logger_eval_string
    #   DESCRIPTION:  Performs %value% substitution on the string passed in
    #
    #                 Known values include:
    #
    #                 %USER%  - Replaced with the user name (value of ${USER} variable)
    #                 %HOST%  - Replaced with the host name this script is running on
    #                 %DATE%  - Replaced with the date this script was called in YYYYMMDD format
    #                 %TIME%  - Replaced with the time this script was called in YYYYMMDDHH24MISS format
    #                 %PPID%  - Replaced with the process id for the parent process that called this function (value of ${PPID})
    #                 %PID%   - Replaced with the process id for the process that called this function
    #
    #         USAGE:  logger_eval_string <string>
    #       RETURNS:  NONE
    #===============================================================================

    echo "${1}" | sed "s|%USER%|${USER}|g"            \
                | sed "s|%DATE%|${LOGGER_RUN_DATE}|g" \
                | sed "s|%TIME%|${LOGGER_RUN_TIME}|g" \
                | sed "s|%PPID%|${PPID}|g"            \
                | sed "s|%HOST%|${LOGGER_RUN_HOST}|g" \
                | sed "s|%PID%|$$|g"
}

function logger_log_stream
{
    #===============================================================================
    #          NAME:  logger_log_stream
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  NONE
    #===============================================================================

    #
    # Perform logging if variable is set, replacing known ids for actual values
    #

    if [[ "X${LOGGER_TEST_LOGGING}" == "Xverbose" ]] ; then

        typeset TEST_SUITE="${1}"
        typeset TEST_NAME="${2}"
        typeset TEST_STAGE="${3}"


        #
        # Remove the path and extension from the suite name, don't use basename to remove the extension
        # as don't know which extension to remove .sh, .ksh etc
        # Remove path first incase there is a . in the path
        #

        typeset TEST_SUITE_TEMP=""
        if [[ -n "${TEST_SUITE}" ]] ; then

            TEST_SUITE_TEMP=$(basename "${TEST_SUITE}")
            TEST_SUITE_TEMP="${TEST_SUITE_TEMP%%.*}"

        fi

        typeset TEST_LOG=$(logger_eval_string "${LOGGER_LOG_DIR}/${LOGGER_LOG_NAME}" | sed "s|%TEST%|${TEST_NAME}|g" | sed "s|%SUITE%|${TEST_SUITE_TEMP}|g" | sed "s|%STAGE%|${TEST_STAGE}|g")

        while read log_str ; do

            #
            # If there is a filter defined then perform substitution on it and pass
            # entry through the filter else ignore the filter
            #

            if [[ -n "${LOGGER_OUTPUT_FILTER}" ]] ; then

                typeset TEST_LOG_FILTER=$(logger_eval_string "${LOGGER_OUTPUT_FILTER}" | sed "s|%TEST%|${TEST_NAME}|g" | sed "s|%SUITE%|${TEST_SUITE_TEMP}|g" | sed "s|%STAGE%|${TEST_STAGE}|g")

                echo "${log_str}" | ${TEST_LOG_FILTER} >> "${TEST_LOG}"

            else

                echo "${log_str}" >> "${TEST_LOG}"

            fi

        done

    fi
}

function logger_log_entry
{
    #================================================================================
    #          NAME:  logger_log_entry
    #   DESCRIPTION:  Prints a message to the log as identified by the LOGGER_TEST_LOG_TEMPLATE configuation variable.
    #                 Note that %value% substitution is performed on the filename
    #
    #                 Known values include:
    #
    #                 %USER%  - Replaced with the user name (value of ${USER} variable)
    #                 %HOST%  - Replaced with the host name this script is running on
    #                 %DATE%  - Replaced with the date this script was called in YYYYMMDD format
    #                 %TIME%  - Replaced with the time this script was called in YYYYMMDDHH24MISS format
    #                 %PPID%  - Replaced with the process id for the parent process that called this function (value of ${PPID})
    #                 %PID%   - Replaced with the process id for the process that called this function
    #                 %TEST%  - Replaced with the test name this function was called with
    #                 %SUITE% - Replaced with the test suite name this function was called with (extension dropped)
    #                 %STAGE% - Replaced with the stage this run is performing within
    #
    #         USAGE:  logger_log_entry <suite> <test> <stage> [<message> ...]
    #       RETURNS:  NONE
    #===============================================================================

    typeset TEST_SUITE="${1}"
    typeset TEST_NAME="${2}"
    typeset TEST_STAGE="${3}"

    shift 3

    echo "${@}" | logger_log_stream "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}"
}
