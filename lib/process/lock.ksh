#!/bin/ksh
#===============================================================================
#
#          FILE:  lock.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/process/lock.ksh 
# 
#   DESCRIPTION:  Handles atomic locking within a shell environment.  Note that
#                 there are no native atomic actions so this script provides
#                 a best endeavours approach using directory manipulation.
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

. "${AB_UNIT_HOME}/lib/system/system.ksh"
. "${AB_UNIT_HOME}/etc/lock.cfg"


#---  GLOBALS   ----------------------------------------------------------------
#   DESCRIPTION:  Global variables used by this script
#-------------------------------------------------------------------------------

LOCK_METHOD="DIRECTORY"                        # change so we can use lockfile or flock etc


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function lock_exists
{
    #===============================================================================
    #          NAME:  lock_exists
    #   DESCRIPTION:  Determines if a lock of a given name already exists
    #         USAGE:  lock_exists [-root <area>] <lockname>
    #       RETURNS:  0 if the lock exists, 1 if it doesnt
    #===============================================================================

    typeset TEMP_WORKING_AREA="${LOCK_WORKING_AREA}"

    if [ "${1}" == "-root" ] ; then

        TEMP_WORKING_AREA="${2}"

        shift 2

    fi

    typeset LOCK_NAME="${1}"
    typeset LOCK_RESULT=1

    if [ -d "${TEMP_WORKING_AREA}/${LOCK_NAME}" ] ; then

        typeset LOCK_RESULT=0

    fi

    return ${LOCK_RESULT}
}

function lock_get_metadata
{                     
    #===============================================================================
    #          NAME:  lock_get_metadata
    #   DESCRIPTION:  Returns the metadata tag from the given lock
    #         USAGE:  lock_get_metadata [-root <area>] <lockname>
    #       RETURNS:  The tag value of the lock
    #===============================================================================
                                                                                      
    typeset TEMP_WORKING_AREA="${LOCK_WORKING_AREA}"

    if [ "${1}" == "-root" ] ; then

        TEMP_WORKING_AREA="${2}"

        shift 2

    fi

    typeset LOCK_NAME="${1}"
    typeset LOCK_META="${2}"
                               
    grep "^${LOCK_META} : " "${TEMP_WORKING_AREA}/${LOCK_NAME}/${LOCK_MANIFEST}" 2>/dev/null | cut -d":" -f2 | cut -c2-
}

function lock_get_owner
{
    #===============================================================================
    #          NAME:  lock_get_owner
    #   DESCRIPTION:  Returns the owner of a given lock
    #         USAGE:  lock_get_owner [-root <area>] <lockname>
    #       RETURNS:  The name of the owner of the lock
    #===============================================================================

    if [ "${1}" == "-root" ] ; then

        lock_get_metadata -root "${2}" "${3}" "USER"

    else

        lock_get_metadata "${1}" "USER"

    fi
}

function lock_get_process
{
    #===============================================================================
    #          NAME:  lock_get_process
    #   DESCRIPTION:  Returns the process id for the process that created this lock
    #         USAGE:  lock_get_process [-root <area>] <lockname>
    #       RETURNS:  The id of the process that created the lock
    #===============================================================================

    if [ "${1}" == "-root" ] ; then

        lock_get_metadata -root "${2}" "${3}" "PROCESS"

    else

        lock_get_metadata "${1}" "PROCESS"

    fi
}

function lock_get_parent
{
    #===============================================================================
    #          NAME:  lock_get_parent
    #   DESCRIPTION:  Returns the parent process id for the process that created this lock
    #         USAGE:  lock_get_parent [-root <area>] <lockname>
    #       RETURNS:  The id of the process parent that created the lock
    #===============================================================================

    if [ "${1}" == "-root" ] ; then

        lock_get_metadata -root "${2}" "${3}" "PARENT"

    else

        lock_get_metadata "${1}" "PARENT"

    fi
}

function lock_add_metadata
{
    #===============================================================================
    #          NAME:  lock_add_metadata
    #   DESCRIPTION:  Adds a tag value pair in the manifest file
    #         USAGE:  lock_add_metadata [-root <area>] <lockname> <tagname> <value>
    #       RETURNS:  NONE
    #===============================================================================

    typeset TEMP_WORKING_AREA="${LOCK_WORKING_AREA}"

    if [ "${1}" == "-root" ] ; then

        TEMP_WORKING_AREA="${2}"

        shift 2

    fi

    typeset LOCK_NAME="${1}"
    typeset LOCK_TAG_NAME="${2}"
    typeset LOCK_TAG_VALUE="${3}"

    typeset LOCK_TMP_NAME="${TEMP_WORKING_AREA}/${LOCK_NAME}/${LOCK_MANIFEST}"
    
    printf "%s : %s\n" "${LOCK_TAG_NAME}" "${LOCK_TAG_VALUE}" >> "${LOCK_TMP_NAME}"
}

function lock_remove_metadata
{
    #===============================================================================
    #          NAME:  lock_remove_metadata
    #   DESCRIPTION:  Removes a tag value pair in the manifest file
    #         USAGE:  lock_remove_metadata [-root <area>] <lockname> <tagname>
    #       RETURNS:  NONE   
    #===============================================================================

    typeset TEMP_WORKING_AREA="${LOCK_WORKING_AREA}"

    if [ "${1}" == "-root" ] ; then

        TEMP_WORKING_AREA="${2}"

        shift 2

    fi

    typeset LOCK_NAME="${1}"
    typeset LOCK_TAG_NAME="${2}"

    typeset LOCK_TMP_NAME="${TEMP_WORKING_AREA}/${LOCK_NAME}/${LOCK_MANIFEST}"

    if [ ! -e "${LOCK_TMP_NAME}" ] ; then
        return 0
    fi
    
    #
    # Get all lines that do not match the tag and replace the original file
    #
    grep -v "^${LOCK_TAG_NAME} : " "${LOCK_TMP_NAME}" > "${LOCK_TMP_NAME}.tmp"
    mv "${LOCK_TMP_NAME}.tmp" "${LOCK_TMP_NAME}"
}


function lock_set_metadata
{
    #===============================================================================
    #          NAME:  lock_set_metadata
    #   DESCRIPTION:  Sets a tag value pair in the manifest file
    #         USAGE:  lock_set_metadata [-root <area>] <lockname> <tagname> <value>
    #       RETURNS:  NONE
    #===============================================================================

    if [ "${1}" == "-root" ] ; then

        typeset LOCK_NAME="${3}"
        typeset LOCK_TAG_NAME="${4}"
        typeset LOCK_TAG_VALUE="${5}"

        lock_remove_metadata -root "${2}" "${LOCK_NAME}" "${LOCK_TAG_NAME}" &&
        lock_add_metadata    -root "${2}" "${LOCK_NAME}" "${LOCK_TAG_NAME}" "${LOCK_TAG_VALUE}"

    else

        typeset LOCK_NAME="${1}"
        typeset LOCK_TAG_NAME="${2}"
        typeset LOCK_TAG_VALUE="${3}"

        lock_remove_metadata "${LOCK_NAME}" "${LOCK_TAG_NAME}" &&
        lock_add_metadata    "${LOCK_NAME}" "${LOCK_TAG_NAME}" "${LOCK_TAG_VALUE}"

    fi
}

function lock_enter
{
    #===============================================================================
    #          NAME:  lock_enter
    #   DESCRIPTION:  Call to obtain a lock used to synchronise processes
    #         USAGE:  lock_enter [-root <area>] <lockname>
    #       RETURNS:  NONE
    #===============================================================================

    typeset TEMP_WORKING_AREA="${LOCK_WORKING_AREA}"

    if [ "${1}" == "-root" ] ; then

        TEMP_WORKING_AREA="${2}"

        shift 2

    fi

    typeset LOCK_NAME="${1}"
    typeset IS_LOCKED=1

    #
    # Keep trying to create the lock, if succeeds write metadata to lock manifest file
    # else sleep for a second and try again
    #
    while [[ ${IS_LOCKED} -eq 1 ]] ; do

        mkdir "${TEMP_WORKING_AREA}/${LOCK_NAME}" 2>/dev/null

        if [[ $? -eq 0 ]] ; then

            printf "USER : %s\nPROCESS : %s\nPARENT : %s\nSHELL : %s\nPWD : %s\nTIME : %s\n" "${USER}" "$$" "${PPID}" "${SHELL}" "${PWD}" $(system_get_datetime) > "${TEMP_WORKING_AREA}/${LOCK_NAME}/${LOCK_MANIFEST}"

            IS_LOCKED=0

        else

            sleep 1

        fi

    done

    return 0
}

function lock_exit
{
    #===============================================================================
    #          NAME:  lock_exit
    #   DESCRIPTION:  Call to release a lock to allow other processes to continue
    #         USAGE:  lock_exit [-root <area>] <lockname> [<force:Y>]
    #       RETURNS:  NONE
    #===============================================================================

    typeset TEMP_WORKING_AREA="${LOCK_WORKING_AREA}"

    if [ "${1}" == "-root" ] ; then

        TEMP_WORKING_AREA="${2}"

        shift 2

    fi

    typeset LOCK_NAME="${1}"
    typeset LOCK_FORCED="${2:-Y}"

    typeset -i LOCK_REMOVED=1

    if [[ "X${LOCK_FORCED}" == "XN" ]] ; then

        rm -Rf "${TEMP_WORKING_AREA}/${LOCK_NAME}" 2>/dev/null
        LOCK_REMOVED=$?

    else

        while [[ "${LOCK_REMOVED}" -ne 0 && -d "${TEMP_WORKING_AREA}/${LOCK_NAME}" ]] ; do

            rm -Rf "${TEMP_WORKING_AREA}/${LOCK_NAME}" 2>/dev/null
            LOCK_REMOVED=$?

            sleep 1

        done

    fi

    return ${LOCK_REMOVED}
}

function lock_try_enter
{
    #===============================================================================
    #          NAME:  lock_try_enter
    #   DESCRIPTION:  Attempts to obtain a lock for synchronisation of multiple processes
    #                 note that an attempt may time out
    #         USAGE:  lock_try_enter [-root <area>] <lockname> [<maxwait:=0>]
    #       RETURNS:  0 if lock obtained else 1 if unsuccessful
    #===============================================================================

    typeset TEMP_WORKING_AREA="${LOCK_WORKING_AREA}"

    #
    # If root is specified re-point to new base
    #
    if [ "${1}" == "-root" ] ; then

        TEMP_WORKING_AREA="${2}"

        shift 2

    fi

    typeset LOCK_NAME="${1}"
    typeset -i LOCK_MAX_WAIT="${2:-0}"

    typeset -i LOCK_START=${SECONDS}
    typeset -i LOCK_CURRENT_TIME=""
    typeset -i LOCK_DIFFERENCE=0

    typeset LOCK_RETURN_CODE=1

    #
    # While we havent exceeded the maximum waiting time try to obtain the lock
    # if unsuccessful check if we are performing any waiting at all, if so
    # sleep for 1 second and reset the time difference between the time function started
    # and now
    #
    while [[ ${LOCK_RETURN_CODE} -ne 0 && ${LOCK_DIFFERENCE} -le ${LOCK_MAX_WAIT} ]] ; do

        #
        # Use to exit main while loop, note this only override if max wait
        # has been set
        #
        LOCK_DIFFERENCE=$(( LOCK_MAX_WAIT + 1 ))

        mkdir "${TEMP_WORKING_AREA}/${LOCK_NAME}" 2>/dev/null

        if [[ $? -ne 0 ]] ; then

            if [[ ${LOCK_MAX_WAIT} -gt 0 ]] ; then

                sleep 1
    
                LOCK_CURRENT_TIME=${SECONDS}
                LOCK_DIFFERENCE=$(( LOCK_CURRENT_TIME - LOCK_START ))

            fi

        else

            printf "USER : %s\nPROCESS : %s\nPARENT : %s\nSHELL : %s\nPWD : %s\nTIME : %s\n" "${USER}" "$$" "${PPID}" "${SHELL}" "${PWD}" $(system_get_datetime) > "${TEMP_WORKING_AREA}/${LOCK_NAME}/${LOCK_MANIFEST}"

            LOCK_RETURN_CODE=0

        fi

    done

    return ${LOCK_RETURN_CODE}
}