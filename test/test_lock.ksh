#!/bin/ksh
#===============================================================================
#
#          FILE:  test_lock.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/test/test_lock.ksh 
# 
#   DESCRIPTION:  Simple test script that tests core functionality of the lock
#                 library.  Note this doesn't use the framework because if
#                 the library doesn't pass the tests then the framework won't
#                 work
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

if [[ -z "${AB_UNIT_HOME}" ]] ; then

    echo "ERROR: AB_UNIT_HOME environment variable is not set" >&2
    exit 1

fi

if [[ ! -e "${AB_UNIT_HOME}" ]] ; then

    echo "ERROR: AB_UNIT_HOME environment variable points to a directory that does not exist" >&2
    exit 2

fi

if [[ ! -d "${AB_UNIT_HOME}" && ! -L "${AB_UNIT_HOME}" ]] ; then

    echo "ERROR: AB_UNIT_HOME environment variable is not a valid directory" >&2
    exit 3

fi

if [[ ! -f "${AB_UNIT_HOME}/lib/process/lock.ksh" && ! -L "${AB_UNIT_HOME}/lib/process/lock.ksh" ]] ; then

    echo "ERROR: ${AB_UNIT_HOME}/lib/process/lock.ksh library could not be located/sourced" >&2
    exit 4

fi

. "${AB_UNIT_HOME}/lib/process/lock.ksh"


#---  GLOBALS   ----------------------------------------------------------------
#   DESCRIPTION:  Global variables used by this script
#-------------------------------------------------------------------------------


#---  TESTS   ------------------------------------------------------------------
#   DESCRIPTION:  tests run by this script
#-------------------------------------------------------------------------------

function test_lock_exists
{
    #===============================================================================
    #          NAME:  test_lock_exists
    #   DESCRIPTION:  Tests that the lock_exists function works
    #===============================================================================

    typeset LOCK_NAME="__internal_test_lock_exists_$$"

    lock_exists "${LOCK_NAME}"
    if [ $? -eq 0 ] ; then

        echo "ERROR: test_lock_exists: lock_exists function detected missing lock" >&2
        return 1

    fi

    lock_enter "${LOCK_NAME}" && lock_exists "${LOCK_NAME}"
    typeset LOCK_RESULT=$?
    lock_exit "${LOCK_NAME}"
    if [ ${LOCK_RESULT} -ne 0 ] ; then

        echo "ERROR: test_lock_exists: lock_exists function did not detect lock" >&2
        return 2

    fi

    return 0
}

function test_lock_get_metadata
{                     
    #===============================================================================
    #          NAME:  test_lock_get_metadata
    #   DESCRIPTION:  Tests the lock_get_metadata function
    #===============================================================================
                                                                                      
    typeset LOCK_NAME="__internal_test_lock_get_metadata_$$"

    lock_enter "${LOCK_NAME}"
    typeset LOCK_RESULT=$(lock_get_metadata "${LOCK_NAME}" USER)
                               
    if [ "${USER}" != "${LOCK_RESULT}" ] ; then

        echo "ERROR: test_lock_get_metadata: lock_get_metadata function did not find lock owner but found '${LOCK_RESULT}'" >&2
        return 1

    fi

    return 0
}

function test_lock_get_owner
{
    #===============================================================================
    #          NAME:  test_lock_get_owner
    #   DESCRIPTION:  Tests the lock_get_owner function
    #===============================================================================

    typeset LOCK_NAME="__internal_test_lock_get_owner_$$"
       
    lock_enter "${LOCK_NAME}"
    typeset LOCK_RESULT=$(lock_get_owner "${LOCK_NAME}")
       
    if [ "${USER}" != "${LOCK_RESULT}" ] ; then

        echo "ERROR: test_lock_get_owner: lock_get_owner function did not find owner name '${USER}' but found '${LOCK_RESULT}'" >&2
        return 1
       
    fi
       
    return 0
}

function test_lock_get_process
{                          
    #===============================================================================
    #          NAME:  test_lock_get_process
    #   DESCRIPTION:  Tests the lock_get_process function
    #===============================================================================
                                       
    typeset LOCK_NAME="__internal_test_lock_get_process_$$"
                              
    lock_enter "${LOCK_NAME}"
    typeset LOCK_RESULT=$(lock_get_process "${LOCK_NAME}")
                              
    if [ $$ -ne ${LOCK_RESULT} ] ; then
                              
        echo "ERROR: test_lock_get_process: lock_get_process function did not find process info '$$' bout found '${LOCK_RESULT}'" >&2
        return 1      
                              
    fi             
         
    return 0
}

function test_lock_get_parent
{
    #===============================================================================
    #          NAME:  test_lock_get_parent
    #   DESCRIPTION:  Tests the lock_get_parent function
    #===============================================================================

    typeset LOCK_NAME="__internal_test_lock_get_parent_$$"
                             
    lock_enter "${LOCK_NAME}"
    typeset LOCK_RESULT=$(lock_get_parent "${LOCK_NAME}")
                
    if [ ${PPID} -ne ${LOCK_RESULT} ] ; then
                                  
        echo "ERROR: test_lock_get_parent: lock_get_parent function did not find parent process info '${PPID}' but found '${LOCK_RESULT}'" >&2
        return 1 
                         
    fi               
        
    return 0
}

function test_lock_add_metadata
{
    #===============================================================================
    #          NAME:  test_lock_add_metadata
    #   DESCRIPTION:  Tests the lock_add_metadata function
    #===============================================================================

    typeset LOCK_NAME="__internal_test_lock_add_metadata_$$"
    typeset LOCK_TAG_USED="MY_STRING"
    typeset LOCK_EXPECTED_RESULT="hello world"
       
    lock_enter "${LOCK_NAME}"
    lock_add_metadata "${LOCK_NAME}" "${LOCK_TAG_USED}" "${LOCK_EXPECTED_RESULT}"
    typeset LOCK_RESULT=$(lock_get_metadata "${LOCK_NAME}" "${LOCK_TAG_USED}")
       
    if [ "${LOCK_EXPECTED_RESULT}" != "${LOCK_RESULT}" ] ; then

        echo "ERROR: test_lock_add_metadata: lock_add_metadata function did not find '${LOCK_EXPECTED_RESULT}' for tag '${LOCK_TAG_USED}' but found '${LOCK_RESULT}'" >&2
        return 1

    fi

    return 0
}

function test_lock_remove_metadata
{
    #===============================================================================
    #          NAME:  test_lock_remove_metadata
    #   DESCRIPTION:  Tests the lock_remove_metadata function
    #===============================================================================

    typeset LOCK_NAME="__internal_test_lock_remove_metadata_$$"
      
    lock_enter "${LOCK_NAME}"
    lock_remove_metadata "${LOCK_NAME}" "USER"
    typeset LOCK_RESULT=$(lock_get_owner "${LOCK_NAME}")
      
    if [ -n "${LOCK_RESULT}" ] ; then

        echo "ERROR: test_lock_remove_metadata: lock_remove_metadata function did not remove metadata for tag 'USER' as found '${LOCK_RESULT}'" >&2
        return 1    
                            
    fi             
         
    return 0
}

function test_lock_set_metadata
{
    #===============================================================================
    #          NAME:  test_lock_set_metadata
    #   DESCRIPTION:  Tests the lock_set_metadata function
    #===============================================================================

    typeset LOCK_NAME="__internal_test_lock_set_metadata_$$"
    typeset LOCK_EXPECTED_RESULT="${USER}_someone_else"

    lock_enter "${LOCK_NAME}"
    lock_set_metadata "${LOCK_NAME}" "USER" "${LOCK_EXPECTED_RESULT}"
    typeset LOCK_RESULT=$(lock_get_owner "${LOCK_NAME}")     
    if [ "${LOCK_RESULT}" != "${LOCK_EXPECTED_RESULT}" ] ; then

        echo "ERROR: test_lock_set_metadata: lock_set_metadata function did not set metadata for tag 'USER' to '${LOCK_EXPECTED_RESULT}' as found '${LOCK_RESULT}'" >&2
        return 1
             
    fi   
             
    return 0
}

function test_lock_enter
{
    #===============================================================================
    #          NAME:  test_lock_enter
    #   DESCRIPTION:  Tests that the lock_enter function allocates a lock
    #===============================================================================

    typeset LOCK_NAME="__internal_test_lock_enter_$$"

    typeset LOCK_START=${SECONDS}
    typeset LOCK_TIMEOUT=60
    typeset LOCK_DIFFERENCE=0

    lock_enter "${LOCK_NAME}" &
    typeset LOCK_PID=$!

    typeset LOCK_ENTER_RUNNING=$(ps -p ${LOCK_PID} | tail -1 | awk '{print $1}' )

    while [ "${LOCK_ENTER_RUNNING}" == "${LOCK_PID}" ] ; do

        if [ ${LOCK_DIFFERENCE} -ge ${LOCK_TIMEOUT} ] ; then

            kill -9 ${LOCK_PID} 2>/dev/null

            echo "ERROR: test_lock_enter: lock_enter function did not allocate lock or timed out" >&2

            return 1

        fi

        LOCK_ENTER_RUNNING=$(ps -p ${LOCK_PID} | tail -1 | awk '{print $1}' )

        (( LOCK_DIFFERENCE = ( SECONDS - LOCK_START ) ))

    done

    return 0
}

function test_lock_exit
{
    #===============================================================================
    #          NAME:  test_lock_exit
    #   DESCRIPTION:  Tests the lock_exit function
    #===============================================================================

    typeset LOCK_NAME="__internal_test_lock_exit_$$"

    lock_enter "${LOCK_NAME}"
    lock_exit  "${LOCK_NAME}"

    lock_exists "${LOCK_NAME}"
    if [ ${?} -eq 0 ] ; then

        echo "ERROR: test_lock_exit: lock_exit function did not remove lock" >&2
        return 1

    fi

    return 0
}

function test_lock_try_enter
{
    #===============================================================================
    #          NAME:  test_lock_try_enter
    #   DESCRIPTION:  Tests the lock_try_enter function
    #===============================================================================

    typeset LOCK_NAME="__internal_test_lock_try_enter_$$"

    typeset LOCK_START=${SECONDS}

    lock_try_enter "${LOCK_NAME}" 0

    lock_exists "${LOCK_NAME}"
    if [ ${?} -ne 0 ] ; then 
                                 
        echo "ERROR: test_lock_try_enter: lock_try_enter function did not create a lock" >&2
        return 1                                   
                                                           
    fi             
         
    return 0
}

function test_lock_try_enter_when_exists
{
    #===============================================================================
    #          NAME:  test_lock_try_enter_when_exists
    #   DESCRIPTION:  Tests the lock_try_enter function when lock already exists
    #===============================================================================

    typeset LOCK_NAME="__internal_test_lock_try_enter_when_exists_$$"
    typeset LOCK_MAX_WAIT=2

    lock_enter "${LOCK_NAME}"

    typeset LOCK_START=${SECONDS}

    lock_try_enter "${LOCK_NAME}" ${LOCK_MAX_WAIT}

    typeset LOCK_END=${SECONDS}

    if [ $(( LOCK_END  - LOCK_START )) -lt ${LOCK_MAX_WAIT} ] ; then

        echo "ERROR: test_lock_try_enter_when_exists: lock_try_enter function did not wait '${LOCK_MAX_WAIT}' seconds " >&2
        return 1

    fi

    return 0
}


#-- MAIN -----------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------

trap "[ -d '${LOCK_WORKING_AREA}'/__internal_test_lock_*_$$ ] && rm -Rf '${LOCK_WORKING_AREA}'/__internal_test_lock_*_$$" ERR HUP INT EXIT

    test_lock_enter                 &&
    test_lock_exit                  &&
    test_lock_try_enter             &&
    test_lock_try_enter_when_exists &&
    test_lock_exists                &&
    test_lock_get_metadata          &&
    test_lock_get_owner             &&
    test_lock_get_process           &&
    test_lock_get_parent            &&
    test_lock_add_metadata          &&
    test_lock_remove_metadata       &&
    test_lock_set_metadata     
    RC=$?

trap - INT QUIT KILL TERM USR1

return $RC