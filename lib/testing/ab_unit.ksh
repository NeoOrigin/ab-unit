#!/bin/ksh
#===============================================================================
#
#          FILE:  ab_unit.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/testing/ab_unit.ksh
# 
#   DESCRIPTION:  Core unit testing functionality.  
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

if [ ! -e "${AB_UNIT_HOME}/lib/testing/logger.ksh" ] ; then

    echo "ERROR: Core library ${AB_UNIT_HOME}/lib/testing/logger.ksh not found" >&2
    return 4

fi

if [ ! -e "${AB_UNIT_HOME}/lib/system/system.ksh" ] ; then

    echo "ERROR: Core library ${AB_UNIT_HOME}/lib/system/system.ksh not found" >&2
    return 5

fi

if [ ! -e "${AB_UNIT_HOME}/etc/ab_unit.cfg" ] ; then

    echo "ERROR: Core configuration file ${AB_UNIT_HOME}/etc/ab_unit.cfg not found" >&2
    return 6

fi

if [ ! -e "${AB_UNIT_HOME}/lib/process/lock.ksh" ] ; then

    echo "ERROR: Core library ${AB_UNIT_HOME}/lib/process/lock.ksh not found" >&2
    return 7

fi

if [ ! -e "${AB_UNIT_HOME}/lib/io/stream.ksh" ] ; then

    echo "ERROR: Core library ${AB_UNIT_HOME}/lib/io/stream.ksh not found" >&2
    return 8

fi

if [ ! -e "${AB_UNIT_HOME}/etc/locale/ab_unit.locale" ] ; then

    echo "ERROR: Core localization file ${AB_UNIT_HOME}/etc/locale/ab_unit.locale not found" >&2
    return 9

fi

. "${AB_UNIT_HOME}/lib/testing/logger.ksh"
. "${AB_UNIT_HOME}/lib/system/system.ksh"
. "${AB_UNIT_HOME}/etc/ab_unit.cfg"
. "${AB_UNIT_HOME}/lib/process/lock.ksh"
. "${AB_UNIT_HOME}/lib/io/stream.ksh"
. "${AB_UNIT_HOME}/lib/system/string.ksh"
. "${AB_UNIT_HOME}/etc/locale/ab_unit.locale"


#---  GLOBALS   ----------------------------------------------------------------
#   DESCRIPTION: Defines global variables used within this script
#-------------------------------------------------------------------------------

AB_UNIT_LOCK_ROOT=ab_unit_${USER}_$$_$(system_get_datetime)
AB_UNIT_APP_LOCK="main.lock"                                          # Lock used for synchronisation of suites across application
AB_UNIT_UI_LOCK="ui.lock"                                             # A unique lock name to ensure output messages are ordered
AB_UNIT_APP_META="main.meta"                                          # A unique lock name for shared metadata across suites

AB_UNIT_REGISTERED_TESTS=""                                           # List of tests to run

AB_UNIT_ENABLE_FLAG="Y"                                               # Flag specifying an enabled test
AB_UNIT_DISABLE_FLAG="N"                                              # flag specifying a disabled test

export LOCK_WORKING_AREA="${LOCK_WORKING_AREA}/${AB_UNIT_LOCK_ROOT}"  # Override the lock area to include this run's name
export ORIG_APP_ROOT="${LOCK_WORKING_AREA}"


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function read_timeout
{
    trap "kill $pid 2>/dev/null; return 11" USR1
    trap 'kill "$pid" 2>/dev/null; return 11' EXIT

        #(sleep "${1:-1}" && kill -USR1 "$$") & pid=$!
        (sleep 1 && kill -USR1 "$$") & pid=$!
        
        read "$2"
        ret=$?

        kill "$pid" 2>/dev/null

    trap - USR1
    trap - EXIT

    return "$ret"
}

function ab_unit_get_valid_functions
{
    #===============================================================================
    #          NAME:  ab_unit_get_valid_functions
    #   DESCRIPTION:  Returns function names that matched the AB_UNIT_TEST_FUNC_REGX
    #                 regular expression
    #         USAGE:  ab_unit_get_valid_functions <suite>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    TEST_SUITE="${1}"

    ab_unit_get_function_names "${TEST_SUITE}" | grep "${AB_UNIT_TEST_FUNC_REGX}"
}

function ab_unit_register_test
{
    #===============================================================================
    #          NAME:  ab_unit_register_test
    #   DESCRIPTION:  Registers/appends a test to be run initially set to enable
    #         USAGE:  ab_unit_register_test <suite> <test>
    #       RETURNS:  NONE
    #===============================================================================

    TEST_SUITE="${1}"
    TEST_NAME="${2}"

    AB_UNIT_REGISTERED_TESTS=$(echo -e "${AB_UNIT_REGISTERED_TESTS}\n${AB_UNIT_ENABLE_FLAG}:${TEST_SUITE}:${TEST_NAME}" | grep "." | sort -u)
}

function ab_unit_unregister_test
{
    #===============================================================================
    #          NAME:  ab_unit_unregister_test
    #   DESCRIPTION:  Removes/unregisters a test, previously scheduled to be run
    #         USAGE:  ab_unit_unregister_test <suite> <test>
    #       RETURNS:  NONE
    #===============================================================================

    TEST_SUITE="${1}"
    TEST_NAME="${2}"

    AB_UNIT_REGISTERED_TESTS=$(echo "${AB_UNIT_REGISTERED_TESTS}" | grep -v "^.:${TEST_SUITE}:${TEST_NAME}$")
}

function ab_unit_register_suite
{
    #===============================================================================
    #          NAME:  ab_unit_register_suite
    #   DESCRIPTION:  Registers all tests defined within a suite
    #         USAGE:  ab_unit_register_suite <suite>
    #       RETURNS:  NONE
    #===============================================================================

    TEST_SUITE="${1}"

    VALID_FUNCS=$(ab_unit_get_valid_functions "${TEST_SUITE}")

    for VALID_FUNC in ${VALID_FUNCS} ; do

        ab_unit_register_test "${TEST_SUITE}" "${VALID_FUNC}"

    done
}

function ab_unit_unregister_suite
{
    #===============================================================================
    #          NAME:  ab_unit_unregister_suite
    #   DESCRIPTION:  Unregisters all registered tests for a particular suite
    #         USAGE:  ab_unit_unregister_suite <suite>
    #       RETURNS:  NONE
    #===============================================================================

    TEST_SUITE_TO_FIND="${1}"
    
    REGISTERED_TESTS=$(ab_unit_get_registered_tests)

    for line in ${REGISTERED_TESTS} ; do

        TEST_SUITE=$(echo "${line}" | stream_split ":" 2)

        if [ "X${TEST_SUITE}" == "X${TEST_SUITE_TO_FIND}" ] ; then

            TEST_NAME=$(echo "${line}" | stream_split ":" 3)

            ab_unit_unregister_test "${TEST_SUITE}" "${TEST_NAME}"

        fi

    done
}

function ab_unit_get_registered_tests
{
    #===============================================================================
    #          NAME:  ab_unit_get_registered_tests
    #   DESCRIPTION:  Prints a list of newline delimited tests that are registered to be run
    #         USAGE:  ab_unit_get_registered_tests
    #       RETURNS:  NONE
    #===============================================================================

    echo "${AB_UNIT_REGISTERED_TESTS}"
}

function ab_unit_enable_test
{
    #===============================================================================
    #          NAME:  ab_unit_enable_test
    #   DESCRIPTION:  Sets a registered test to enabled
    #         USAGE:  ab_unit_enable_test <suite> <test>
    #       RETURNS:  NONE
    #===============================================================================

    TEST_SUITE="${1}"
    TEST_NAME="${2}"

    AB_UNIT_REGISTERED_TESTS=$(echo "${AB_UNIT_REGISTERED_TESTS}" | sed "s|^.:${TEST_SUITE}:${TEST_NAME}$|${AB_UNIT_ENABLE_FLAG}:${TEST_SUITE}:${TEST_NAME}|g")
}

function ab_unit_disable_test
{
    #===============================================================================
    #          NAME:  ab_unit_disable_test
    #   DESCRIPTION:  Sets a registered test to disabled
    #         USAGE:  ab_unit_disable_test <suite> <test>
    #       RETURNS:  NONE
    #===============================================================================

    TEST_SUITE="${1}"
    TEST_NAME="${2}"

    AB_UNIT_REGISTERED_TESTS=$(echo "${AB_UNIT_REGISTERED_TESTS}" | sed "s|^.:${TEST_SUITE}:${TEST_NAME}$|${AB_UNIT_DISABLE_FLAG}:${TEST_SUITE}:${TEST_NAME}|g")
}

function ab_unit_get_enabled_tests
{
    #===============================================================================
    #          NAME:  ab_unit_get_enabled_tests
    #   DESCRIPTION:  Prints all the registered tests set to enabled
    #         USAGE:  ab_unit_get_enabled_tests
    #       RETURNS:  NONE
    #===============================================================================

    echo "${AB_UNIT_REGISTERED_TESTS}" | grep "^${AB_UNIT_ENABLE_FLAG}:" | stream_split ":" "2-"
}

function ab_unit_get_disabled_tests
{
    #===============================================================================
    #          NAME:  ab_unit_get_disabled_tests
    #   DESCRIPTION:  Prints all the registered tests set to disabled
    #         USAGE:  ab_unit_get_disabled_tests
    #       RETURNS:  NONE
    #===============================================================================

    echo "${AB_UNIT_REGISTERED_TESTS}" | grep "^${AB_UNIT_DISABLE_FLAG}:" | stream_split ":" "2-"
}

function ab_unit_generate_message
{
    #===============================================================================
    #          NAME:  ab_unit_generate_message
    #   DESCRIPTION:  Prints a message to standard output in standard format
    #         USAGE:  ab_unit_generate_message <suite> <test> <stage> <msg_id> <message>
    #       RETURNS:  NONE
    #===============================================================================

    TEST_SUITE="${1}"
    TEST_NAME="${2}"
    TEST_STAGE="${3}"
    TEST_MESSAGE="${4}"
    TEST_DETAIL="${5}"

    echo "${TEST_DETAIL}" | ab_unit_generate_messages "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" N "${TEST_MESSAGE}"
}

function ab_unit_generate_messages
{
    #===============================================================================
    #          NAME:  ab_unit_generate_messages
    #   DESCRIPTION:  
    #         USAGE:  ab_unit_generate_messages <suite> <test> <stage> [<sync:Y>] [<msg_id>]
    #       RETURNS:
    #===============================================================================

    TEST_SUITE="${1}"
    TEST_NAME="${2}"
    TEST_STAGE="${3}"
    TEST_SYNC="${4:-Y}"
    TEST_MESSAGE="${5}"

    if [ -n "${TEST_MESSAGE}" ] ; then

        TEST_MESSAGE="${TEST_MESSAGE} : "

    fi


    OUTPUT_MESSAGE=""
    typeset -i PREV_TIME=${SECONDS}
    typeset -i NOW_TIME=0
    typeset -i DIFF_TIME=0
    typeset -i SYS_DATE_TIME=$(system_get_datetime)
    typeset -i RANDOM_TIME=0
    typeset -i LOCK_RESULT=0
    typeset -i LOCK_BUFFER_SIZE=0;

    #
    # each process will get a random buffer/flush time in the range of 2 - 6 seconds
    #
    RANDOM_TIME=$(( ( ( $$ + PPID + RANDOM + SECONDS + SYS_DATE_TIME ) % 5 ) + 2 ))

    #echo $(date +%H%M%S)":${1}:${2}:${3}:STARTING:$RANDOM_TIME" >> /tmp/phils_messages.dat

    while read_timeout ${RANDOM_TIME} ab_unit_line ; do

        READ_HAS_DATA=$?
        if [ $READ_HAS_DATA -ne 11 ] ; then
            #OUTPUT_MESSAGE="${OUTPUT_MESSAGE}${AB_UNIT_SUITE_ID} : ${TEST_SUITE} : ${AB_UNIT_TEST_ID} : ${TEST_NAME} : ${AB_UNIT_STAGE_ID} : ${TEST_STAGE} : ${TEST_MESSAGE}$(date +%H%M%S)${ab_unit_line}\n"
            OUTPUT_MESSAGE="${OUTPUT_MESSAGE}${AB_UNIT_SUITE_ID} : ${TEST_SUITE} : ${AB_UNIT_TEST_ID} : ${TEST_NAME} : ${AB_UNIT_STAGE_ID} : ${TEST_STAGE} : ${TEST_MESSAGE}${ab_unit_line}\n"
        fi

        #echo $(date +%H%M%S)":${1}:${2}:${3}:READ:$READ_HAS_DATA" >> /tmp/phils_messages.dat

        #
        # Do not create a lock file if user requests it, i.e. if they created one manually
        #
        if [[ "X${TEST_SYNC}" != "XY" ]] ; then
        
            echo -e "${OUTPUT_MESSAGE}\c"
            echo -e "${OUTPUT_MESSAGE}\c" | logger_log_stream "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}"

            OUTPUT_MESSAGE=""

            #echo $(date +%H%M%S)":${1}:${2}:${3}:NOLOCK:$TEST_SYNC" >> /tmp/phils_messages.dat

        else

            (( LOCK_BUFFER_SIZE += 1 ))

            LOCK_RESULT=1
            NOW_TIME=${SECONDS}

            #
            # Diff time represents the number of seconds passed since last successful
            # lock obtained, each process will get a random buffler/flush time in the range of
            # 5 - 7 seconds, if this process has waiting longer than its allocated time it
            # starts attempting to obtain a lock
            #
            DIFF_TIME=$(( NOW_TIME - PREV_TIME ))

            #echo $(date +%H%M%S)":${1}:${2}:${3}:DIFF_TIME:$DIFF_TIME" >> /tmp/phils_messages.dat

            #
            # If we have exceeded the buffer size begin trying to obtain a lock
            #
            if [[ $READ_HAS_DATA -ne 11 || ${LOCK_BUFFER_SIZE} -ge "${AB_UNIT_MESSAGE_BUFFER}" ]] ; then

                #echo $(date +%H%M%S)":${1}:${2}:${3}:LOCK_BUFFER:$LOCK_BUFFER_SIZE" >> /tmp/phils_messages.dat

                lock_try_enter "${AB_UNIT_UI_LOCK}" 0
                LOCK_RESULT=$?

                #echo $(date +%H%M%S)":${1}:${2}:${3}:LOCK_TRY_GOT:$LOCK_RESULT" >> /tmp/phils_messages.dat

            fi

            #
            # If no lock is already obtained and we have exceeded maximum time allowed then
            # wait until lock is obtained
            #
            if [[ ${LOCK_RESULT} -ne 0 && ( $READ_HAS_DATA -ne 11 || ${DIFF_TIME} -ge ${RANDOM_TIME} ) ]] ; then

                #echo $(date +%H%M%S)":${1}:${2}:${3}:LOCK_ENTER:$RANDOM_TIME" >> /tmp/phils_messages.dat

                lock_enter "${AB_UNIT_UI_LOCK}"
                LOCK_RESULT=0

                #echo $(date +%H%M%S)":${1}:${2}:${3}:LOCK_GOT:" >> /tmp/phils_messages.dat

            fi

            #
            # If a lock has been obtained output item to log and ui and remove the lock
            # reset the next appropriate time to look for updates
            #
            if [[ ${LOCK_RESULT} -eq 0 ]] ; then

                lock_add_metadata "${AB_UNIT_UI_LOCK}" CALLER "ab_unit_generate_messages main"
                lock_add_metadata "${AB_UNIT_UI_LOCK}" SUITE  "${TEST_SUITE}"
                lock_add_metadata "${AB_UNIT_UI_LOCK}" TEST   "${TEST_NAME}"
                lock_add_metadata "${AB_UNIT_UI_LOCK}" STAGE  "${TEST_STAGE}"

                echo -e "${OUTPUT_MESSAGE}\c"
                echo -e "${OUTPUT_MESSAGE}\c" | logger_log_stream "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}"

                lock_exit "${AB_UNIT_UI_LOCK}" "Y"

                #
                # Once the lock has been exited reset the buffer and update the last
                # lock time
                #
                OUTPUT_MESSAGE=""
                LOCK_BUFFER_SIZE=0
                PREV_TIME=${SECONDS}

                #
                # Reset the buffer time limit potentially allowing slower processes to catch up
                #
                RANDOM_TIME=$(( ( ( $$ + PPID + RANDOM + SECONDS + SYS_DATE_TIME ) % 5 ) + 2 ))

            fi

        fi

    done

    #
    # Check if a final flush needs to be performed on the message buffer
    #
    if [[ "X${OUTPUT_MESSAGE}" != "X" ]] ; then

        if [[ "X${TEST_SYNC}" != "XY" ]] ; then

            echo -e "${OUTPUT_MESSAGE}\c"
            echo -e "${OUTPUT_MESSAGE}\c" | logger_log_stream "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}"

        else

            lock_enter "${AB_UNIT_UI_LOCK}"

                lock_add_metadata "${AB_UNIT_UI_LOCK}" CALLER "ab_unit_generate_messages flush"
                lock_add_metadata "${AB_UNIT_UI_LOCK}" SUITE  "${TEST_SUITE}"
                lock_add_metadata "${AB_UNIT_UI_LOCK}" TEST   "${TEST_NAME}"
                lock_add_metadata "${AB_UNIT_UI_LOCK}" STAGE  "${TEST_STAGE}"

                echo -e "${OUTPUT_MESSAGE}\c"
                echo -e "${OUTPUT_MESSAGE}\c" | logger_log_stream "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}"

            lock_exit "${AB_UNIT_UI_LOCK}" "Y"

        fi

    fi
}

function ab_unit_get_function_names
{
    #===============================================================================
    #          NAME:  ab_unit_get_function_names
    #   DESCRIPTION:  Returns all the functions defined withing the test suite
    #         USAGE:  ab_unit_get_function_names <suite>
    #       RETURNS:  The names of all functions defined within the test suite
    #===============================================================================

    TEST_SUITE="${1}"

    if [ -f "${TEST_SUITE}" ] ; then

        grep "${AB_UNIT_FUNC_REGX}" "${TEST_SUITE}" | stream_split " " "2-"

    fi
}

function ab_unit_find_test
{
    #===============================================================================
    #          NAME:  ab_unit_find_test
    #   DESCRIPTION:  Inspects the test suite for a function of a particular name
    #         USAGE:  ab_unit_find_test <suite> <test>
    #       RETURNS:  The name of the function if found else nothing
    #===============================================================================

    TEST_SUITE="${1}"
    TEST_NAME="${2}"

    ab_unit_get_function_names "${TEST_SUITE}" | grep "${TEST_NAME}"
}

function ab_unit_run_test_setup
{
    #===============================================================================
    #          NAME:  ab_unit_run_test_setup
    #   DESCRIPTION:  Executes the setup_test function if it is defined within the test suite
    #         USAGE:  ab_unit_run_test_setup <suite> <test>
    #       RETURNS:  NONE
    #===============================================================================

    TEST_SUITE="${1}"
    TEST_NAME="${2}"

    TEST_FOUND_FUNCTION=$(ab_unit_find_test "${TEST_SUITE}" "${AB_UNIT_SETUP_REGX}")

    if [ -n "${TEST_FOUND_FUNCTION}" ] ; then

        ab_unit_run_command "${TEST_SUITE}" "${TEST_NAME}" "setup_test" ". ${TEST_SUITE}" &&
        ab_unit_run_command "${TEST_SUITE}" "${TEST_NAME}" "setup_test" "${TEST_FOUND_FUNCTION} ${TEST_SUITE} ${TEST_NAME}"

        return $?
    fi

    return 0
}

function ab_unit_run_suite_setup
{
    #===============================================================================
    #          NAME:  ab_unit_run_suite_setup
    #   DESCRIPTION:  Executes the setup_suite function if it is defined within the test suite
    #         USAGE:  ab_unit_run_suite_setup <suite>
    #       RETURNS:  NONE
    #===============================================================================

    TEST_SUITE="${1}"

    TEST_FOUND_FUNCTION=$(ab_unit_find_test "${TEST_SUITE}" "${AB_UNIT_SUITE_SETUP_REGX}")

    if [ -n "${TEST_FOUND_FUNCTION}" ] ; then

        ab_unit_run_command "${TEST_SUITE}" "" "setup_suite" ". ${TEST_SUITE}" &&
        ab_unit_run_command "${TEST_SUITE}" "" "setup_suite" "${TEST_FOUND_FUNCTION} ${TEST_SUITE}"

        return $?

    fi

    return 0
}

function ab_unit_run_test_teardown
{
    #===============================================================================
    #          NAME:  ab_unit_run_test_teardown
    #   DESCRIPTION:  Executes the teardown_test function if it is defined within the test suite
    #         USAGE:  ab_unit_run_test_teardown <suite> <test>
    #       RETURNS:  NONE
    #===============================================================================

    TEST_SUITE="${1}"
    TEST_NAME="${2}"

    TEST_FOUND_FUNCTION=$(ab_unit_find_test "${TEST_SUITE}" "${AB_UNIT_TEARDOWN_REGX}")

    if [ -n "${TEST_FOUND_FUNCTION}" ] ; then

        ab_unit_run_command "${TEST_SUITE}" "${TEST_NAME}" "teardown_test" ". ${TEST_SUITE}" &&
        ab_unit_run_command "${TEST_SUITE}" "${TEST_NAME}" "teardown_test" "${TEST_FOUND_FUNCTION} ${TEST_SUITE} ${TEST_NAME}"

        return ${?}

    fi

    return 0
}

function ab_unit_run_suite_teardown
{
    #===============================================================================
    #          NAME:  ab_unit_run_suite_teardown
    #   DESCRIPTION:  Executes the teardown_suite function if it is defined within the test suite
    #         USAGE:  ab_unit_run_suite_teardown <suite>
    #       RETURNS:  NONE
    #===============================================================================

    TEST_SUITE="${1}"

    TEST_FOUND_FUNCTION=$(ab_unit_find_test "${TEST_SUITE}" "${AB_UNIT_SUITE_TEARDOWN_REGX}")

    if [ -n "${TEST_FOUND_FUNCTION}" ] ; then

        ab_unit_run_command "${TEST_SUITE}" "" "teardown_suite" ". ${TEST_SUITE}" &&
        ab_unit_run_command "${TEST_SUITE}" "" "teardown_suite" "${TEST_FOUND_FUNCTION} ${TEST_SUITE}"

        return ${?}

    fi

    return 0
}

function ab_unit_run_command
{
    #===============================================================================
    #          NAME:  ab_unit_run_command
    #   DESCRIPTION:
    #         USAGE:  ab_unit_run_command <suite> <test> <stage> <cmds>*
    #       RETURNS:
    #===============================================================================

    TEST_SUITE="${1}"
    TEST_NAME="${2}"
    TEST_STAGE=$(echo "${3}" | sed 's| |_|g')

    shift 3

    TEST_COMMANDS="${@}"

    TEST_STATUS="${AB_UNIT_PASSED_STRING}"
    TEST_RESULT="0"
    TIME_OF_RUN=$(system_get_datetime)
    TIME_SAVED_SECONDS="${SECONDS:-0}"
    AB_UNIT_TEST_LOCK="ab_unit_${TEST_NAME}_${TEST_STAGE}_${TIME_OF_RUN}.lock"

    #
    # Create parameters to hold pipes used for interprocess communication across ui elements
    #
    PIPE_NAME_OUT="${LOCK_WORKING_AREA}/ab_unit_${USER}_$$_${TEST_NAME}_${TEST_STAGE}_${TIME_OF_RUN}_stdout.pipe"
    PIPE_NAME_ERR="${LOCK_WORKING_AREA}/ab_unit_${USER}_$$_${TEST_NAME}_${TEST_STAGE}_${TIME_OF_RUN}_stderr.pipe"

    #
    # Create parameters to hold shared lock variables for pipe keep alive routines
    #
    SLEEP_LOCK_OUT=ab_unit_${USER}_$$_${TEST_NAME}_${TEST_STAGE}_${TIME_OF_RUN}_stdout.lock
    SLEEP_LOCK_ERR=ab_unit_${USER}_$$_${TEST_NAME}_${TEST_STAGE}_${TIME_OF_RUN}_stderr.lock

    lock_enter "${AB_UNIT_TEST_META}"

        #
        # Once a lock for this test is established then add metadata
        #
        lock_add_metadata "${AB_UNIT_TEST_META}" CALLER "ab_unit_run_test"
        lock_add_metadata "${AB_UNIT_TEST_META}" SUITE  "${TEST_SUITE}"
        lock_add_metadata "${AB_UNIT_TEST_META}" TEST   "${TEST_NAME}"
        lock_add_metadata "${AB_UNIT_TEST_META}" STAGE  "${TEST_STAGE}"
        lock_add_metadata "${AB_UNIT_TEST_META}" CMDS   "${TEST_COMMANDS}"
        lock_add_metadata "${AB_UNIT_TEST_META}" PHASE  "STARTING"


        #
        # Send a message to the ui indicating the start time, command, directory and status
        # of current running test (i.e. RUNNING)
        #
        lock_enter "${AB_UNIT_UI_LOCK}"

            lock_add_metadata "${AB_UNIT_UI_LOCK}" CALLER "ab_unit_run_command start"
            lock_add_metadata "${AB_UNIT_UI_LOCK}" SUITE  "${TEST_SUITE}"
            lock_add_metadata "${AB_UNIT_UI_LOCK}" TEST   "${TEST_NAME}"
            lock_add_metadata "${AB_UNIT_UI_LOCK}" STAGE  "${TEST_STAGE}"
            lock_add_metadata "${AB_UNIT_UI_LOCK}" CMDS   "${TEST_COMMANDS}"

            ab_unit_generate_message  "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${AB_UNIT_START_ID}"  "${TIME_OF_RUN}"
            ab_unit_generate_message  "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${AB_UNIT_CMD_ID}"    "${TEST_COMMANDS}"
            ab_unit_generate_message  "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${AB_UNIT_PWD_ID}"    "${PWD}"
            ab_unit_generate_message  "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${AB_UNIT_STATUS_ID}" "${AB_UNIT_RUNNING_STRING}"

        lock_exit "${AB_UNIT_UI_LOCK}"



        SAVED_OUT_PID=""
        SAVED_ERR_PID=""
        SAVED_SLP_OUT_PID=""
        SAVED_SLP_ERR_PID=""
        DELETE_PIPES_ON_EXIT=""


        #
        # Depending on the stream being used to produce output determine if
        # they are a fifo file and if so delete them, also reassign variables to
        # point to trash if that output is not used
        #
        case "${AB_UNIT_OUTPUT_STREAMS}" in

            split  ) ;;
            merged ) PIPE_NAME_ERR="${PIPE_NAME_OUT}"
                     ;;
            stdout ) PIPE_NAME_ERR="/dev/null"
                     ;;
            stderr ) PIPE_NAME_OUT="/dev/null"
                     ;;
            *      ) PIPE_NAME_OUT="/dev/null"
                     PIPE_NAME_ERR="/dev/null"
                     ;;

        esac


        #
        # Create locks, we will attempt to create them again later, this will cause
        # the second lock attempts to hang indefinately until they can lock, this effectively
        # will allow a communication pipe to remain open until the lock is successful.  This will
        # only be once we have removed the existing lock after the test is run and the output is
        # finished
        #
        lock_enter "${SLEEP_LOCK_OUT}"
        lock_enter "${SLEEP_LOCK_ERR}"

        #
        # Check what action to perform for output streams, if split merged or stdout
        # then we need to create a pipe, when a pipe is created redirect its contents
        # to our custom messsage transformation function. Save its PID incase we need to
        # kill the background process later.
        # Then try to obtain a lock again, this will effectively keep alive the pipe in
        # a never ending loop.
        #
        case "${AB_UNIT_OUTPUT_STREAMS}" in

            split | merged | stdout )  system_create_pipe "${PIPE_NAME_OUT}"
                                       ab_unit_generate_messages "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" Y "${AB_UNIT_STDOUT_ID}" < "${PIPE_NAME_OUT}" &
                                       SAVED_OUT_PID=$!

                                       (lock_enter "${SLEEP_LOCK_OUT}" && lock_exit "${SLEEP_LOCK_OUT}") >>${PIPE_NAME_OUT} &
                                       SAVED_SLP_OUT_PID=$!

                                       lock_add_metadata "${AB_UNIT_TEST_META}" PROCESS1 "${SAVED_OUT_PID}"
                                       lock_add_metadata "${AB_UNIT_TEST_META}" PROCESS2 "${SAVED_SLP_OUT_PID}"
                                       ;;
            *                       )  ;;

        esac

        #
        # Check what action to perform for output streams, if split or stderr then we need
        # to create a pipe, when a pipe is created redirect its contents to our custom messsage
        # transformation function. Save its PID incase we need to kill the background process later.
        # Then try to obtain a lock again, this will effectively keep alive the pipe in
        # a never ending loop.
        #
        case "${AB_UNIT_OUTPUT_STREAMS}" in

            split | stderr ) system_create_pipe "${PIPE_NAME_ERR}"
                             ab_unit_generate_messages "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" Y "${AB_UNIT_STDERR_ID}" < "${PIPE_NAME_ERR}" &
                             SAVED_ERR_PID=$!

                             (lock_enter "${SLEEP_LOCK_ERR}" && lock_exit "${SLEEP_LOCK_ERR}") >>"${PIPE_NAME_ERR}" &
                             SAVED_SLP_ERR_PID=$!

                             lock_add_metadata "${AB_UNIT_TEST_META}" PROCESS3 "${SAVED_ERR_PID}"
                             lock_add_metadata "${AB_UNIT_TEST_META}" PROCESS4 "${SAVED_SLP_ERR_PID}"
                             ;;
            *              ) ;;

        esac

        #
        # Syntax check the test suite before we trying running it
        #
        if [ -n "${TEST_SUITE}" ] ; then

            lock_set_metadata "${AB_UNIT_TEST_META}" PHASE    "VALIDATING"

            ksh -n "${TEST_SUITE}" >"${PIPE_NAME_OUT}" 2>"${PIPE_NAME_ERR}"
            TEST_RESULT=$?

        fi

        #
        # If the syntax setting failed set the errored message, else
        # try executing the test, capturing a test failure if it returns
        # non zero
        #
        if [ "${TEST_RESULT}" -ne 0 ] ; then

            lock_set_metadata "${AB_UNIT_TEST_META}" PHASE    "ERRORED"

            TEST_STATUS="${AB_UNIT_ERRORED_STRING}"

        else

            lock_set_metadata "${AB_UNIT_TEST_META}" PHASE "EXECUTING"


            ${TEST_COMMANDS} >"${PIPE_NAME_OUT}" 2>"${PIPE_NAME_ERR}"
            TEST_RESULT=$?


            if [ "${TEST_RESULT}" -ne 0 ] ; then

                TEST_STATUS="${AB_UNIT_FAILED_STRING}"

            fi


            lock_set_metadata "${AB_UNIT_TEST_META}" PHASE "EXECUTED"

        fi

        #
        # Remove the locks, this allows the neverending streams to gracefully exit
        #
        lock_exit "${SLEEP_LOCK_ERR}"
        lock_exit "${SLEEP_LOCK_OUT}"

        lock_set_metadata "${AB_UNIT_TEST_META}" PHASE "CLOSING"

        #
        # Kill any processes that are waiting for pipes to close, these may hang
        #
        cat /dev/null >> "${PIPE_NAME_ERR}" &
        SAVED_SLP_ERR_PID="${SAVED_SLP_ERR_PID} $!"
        cat /dev/null >> "${PIPE_NAME_OUT}" &
        SAVED_SLP_OUT_PID="${SAVED_SLP_OUT_PID} $!"

        kill -9 "${SAVED_SLP_OUT_PID}" "${SAVED_SLP_ERR_PID}" >/dev/null 2>&1

        lock_set_metadata "${AB_UNIT_TEST_META}" PHASE "CLOSED"


        TEST_ENDTIME=$(system_get_datetime)
        #TEST_RUNTIME=$(system_get_time_difference "${TIME_OF_RUN}" "${TEST_ENDTIME}")
        TEST_RUNTIME=$(( SECONDS - TIME_SAVED_SECONDS ))

        lock_set_metadata "${AB_UNIT_TEST_META}" PHASE "EXITING"

        #
        # Lock the user interface, adding metadata to lock to show which process is locking
        # then signal to listeners the status of the job
        #
        lock_enter "${AB_UNIT_UI_LOCK}"

            lock_add_metadata "${AB_UNIT_UI_LOCK}" CALLER "ab_unit_run_command end"
            lock_add_metadata "${AB_UNIT_UI_LOCK}" SUITE  "${TEST_SUITE}"
            lock_add_metadata "${AB_UNIT_UI_LOCK}" TEST   "${TEST_NAME}"
            lock_add_metadata "${AB_UNIT_UI_LOCK}" STAGE  "${TEST_STAGE}"
            lock_add_metadata "${AB_UNIT_UI_LOCK}" CMDS   "${TEST_COMMANDS}"

            ab_unit_generate_message "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${AB_UNIT_RESULT_ID}"  "${TEST_RESULT}"
            ab_unit_generate_message "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${AB_UNIT_STATUS_ID}"  "${TEST_STATUS}"
            ab_unit_generate_message "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${AB_UNIT_END_ID}"     "${TEST_ENDTIME}"
            ab_unit_generate_message "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${AB_UNIT_RUNTIME_ID}" "${TEST_RUNTIME}"

        lock_exit "${AB_UNIT_UI_LOCK}"

    lock_exit "${AB_UNIT_TEST_META}"

    return ${TEST_RESULT}
}

function ab_unit_run_test
{
    #===============================================================================
    #          NAME:  ab_unit_run_test
    #   DESCRIPTION:
    #    PARAMETERS:  1 [Required] The test suite being run
    #                 2 [Required] The test name
    #       RETURNS:
    #===============================================================================

    TEST_SUITE="${1}"
    TEST_NAME="${2}"

    #
    # Obtain a lock on the parent suite object.  This ensures all tests wait so critical information
    # can be shared between them.  Get the number of already running tests, if more tests are running
    # within this suite than allowed then this test must wait for another to finish.  Once a resource
    # is released increment the count and proceed
    #
    lock_enter "${AB_UNIT_SUITE_LOCK}"

        lock_add_metadata "${AB_UNIT_SUITE_LOCK}" CALLER "ab_unit_run_test"
        lock_add_metadata "${AB_UNIT_SUITE_LOCK}" SUITE  "${TEST_SUITE}"
        lock_add_metadata "${AB_UNIT_SUITE_LOCK}" TEST   "${TEST_NAME}"

        AB_UNIT_TESTS_RUNNING=$(lock_get_metadata "${AB_UNIT_SUITE_META}" "TEST_COUNT")

        #
        # If we have reached the maximum number of threads to run in parallel
        # then wait for one to finish, once ready then run test
        #
        while [ "${AB_UNIT_TESTS_RUNNING}" -ge "${AB_UNIT_MAX_TEST_PARALLEL}" ] ; do

            lock_exit "${AB_UNIT_SUITE_LOCK}"

            sleep 1

            lock_enter "${AB_UNIT_SUITE_LOCK}"

            lock_add_metadata "${AB_UNIT_SUITE_LOCK}" CALLER "ab_unit_run_test"
            lock_add_metadata "${AB_UNIT_SUITE_LOCK}" SUITE  "${TEST_SUITE}"
            lock_add_metadata "${AB_UNIT_SUITE_LOCK}" TEST   "${TEST_NAME}"

            AB_UNIT_TESTS_RUNNING=$(lock_get_metadata "${AB_UNIT_SUITE_META}" "TEST_COUNT")

        done

        lock_set_metadata "${AB_UNIT_SUITE_META}" "TEST_COUNT" $(( AB_UNIT_TESTS_RUNNING + 1 ))

    lock_exit "${AB_UNIT_SUITE_LOCK}"


    TEST_FOUND_FUNCTION=$(ab_unit_find_test "${TEST_SUITE}" "^${TEST_NAME}$")
    TEST_RESULT=0


    #
    # If the test was not found in the suite then set to ignored
    #
    if [ -n "${TEST_FOUND_FUNCTION}" ] ; then

        AB_UNIT_TEST_LOCK="${TEST_NAME}.lock"
        AB_UNIT_TEST_META="${TEST_NAME}.meta"


        #lock_enter "${AB_UNIT_TEST_META}"

            ab_unit_run_event "${TEST_SUITE}" "${TEST_NAME}" "start_test_event" "${AB_UNIT_START_TEST_EVENT}" "${TEST_SUITE}" "${TEST_NAME}"

            #
            # Syntax is correct, try loading the script into memory for execution
            # of individual functions
            #
            ab_unit_run_test_setup "${TEST_SUITE}" "${TEST_NAME}"                                  &&
            ab_unit_run_command    "${TEST_SUITE}" "${TEST_NAME}" "load_test"    ". ${TEST_SUITE}" &&
            ab_unit_run_command    "${TEST_SUITE}" "${TEST_NAME}" "execute_test" "${TEST_NAME}"

            TEST_RESULT=$?

            ab_unit_run_test_teardown "${TEST_SUITE}" "${TEST_NAME}"

            ab_unit_run_event "${TEST_SUITE}" "${TEST_NAME}" "end_test_event" "${AB_UNIT_END_TEST_EVENT}" "${TEST_SUITE}" "${TEST_NAME}"

        #lock_exit "${AB_UNIT_TEST_META}"

    fi


    #
    # Once the test has finished lock the suite and update the metadata by
    # indicating the released resource by decrementing the count
    #
    lock_enter "${AB_UNIT_SUITE_LOCK}"

        lock_add_metadata "${AB_UNIT_SUITE_LOCK}" CALLER "ab_unit_run_test"
        lock_add_metadata "${AB_UNIT_SUITE_LOCK}" SUITE  "${TEST_SUITE}"
        lock_add_metadata "${AB_UNIT_SUITE_LOCK}" TEST   "${TEST_NAME}"

        AB_UNIT_TESTS_RUNNING=$(lock_get_metadata "${AB_UNIT_SUITE_META}" "TEST_COUNT")

        lock_set_metadata "${AB_UNIT_SUITE_META}" "TEST_COUNT" $(( AB_UNIT_TESTS_RUNNING - 1 ))

        lock_exit "${AB_UNIT_SUITE_LOCK}"


    return ${TEST_RESULT}
}

function ab_unit_run_suite
{
    #===============================================================================
    #          NAME:  ab_unit_run_suite
    #   DESCRIPTION:
    #         USAGE:  ab_unit_run_suite <suite>
    #       RETURNS:
    #===============================================================================

    TEST_SUITE="${1}"
    shift

    #
    # Obtain a lock to the parent application, this ensures all other suites that are attempting the
    # same action will have to wait
    #
    # Obtain the number of suites already running if there are too many then release the lock waiting
    # until a resource is released (i.e. a suite has finished).  Once a resource is free increment
    # the count tosignal this suite is running and release the lock
    #
    lock_enter "${AB_UNIT_APP_LOCK}"

        lock_add_metadata "${AB_UNIT_APP_LOCK}" CALLER "ab_unit_run_suite"
        lock_add_metadata "${AB_UNIT_APP_LOCK}" SUITE  "${TEST_SUITE}"

        AB_UNIT_SUITES_RUNNING=$(lock_get_metadata "${AB_UNIT_APP_META}" "SUITE_COUNT")


        #
        # If we have reached the maximum number of threads to run in parallel
        # then wait for one to finish, once ready then run test
        #
        while [ "${AB_UNIT_SUITES_RUNNING}" -ge "${AB_UNIT_MAX_SUITE_PARALLEL}" ] ; do

            lock_exit "${AB_UNIT_APP_LOCK}"

            sleep 1

            lock_enter "${AB_UNIT_APP_LOCK}"

            lock_add_metadata "${AB_UNIT_APP_LOCK}" CALLER "ab_unit_run_suite"
            lock_add_metadata "${AB_UNIT_APP_LOCK}" SUITE  "${TEST_SUITE}"

            AB_UNIT_SUITES_RUNNING=$(lock_get_metadata "${AB_UNIT_APP_META}" "SUITE_COUNT")

        done

        lock_set_metadata "${AB_UNIT_APP_META}" "SUITE_COUNT" $(( AB_UNIT_SUITES_RUNNING + 1 ))

    lock_exit "${AB_UNIT_APP_LOCK}"

    #
    # Create variables to hold the suite lock name and the suite specific file it uses to
    # share metadata with tests
    #
    AB_UNIT_SUITE_LOCK=$(echo -e "${TEST_SUITE}.lock" | sed 's|/|_|g')
    AB_UNIT_SUITE_META=$(echo -e "${TEST_SUITE}.meta" | sed 's|/|_|g')

    #
    # Create the suite metadata file (implemented as a lock) this is used to allow
    # tests within a suite to share information such as counting how many exist etc
    #
    lock_enter "${AB_UNIT_SUITE_META}"

        lock_add_metadata "${AB_UNIT_SUITE_META}" CALLER      "ab_unit_run_suite"
        lock_add_metadata "${AB_UNIT_SUITE_META}" SUITE       "${TEST_SUITE}"
        lock_add_metadata "${AB_UNIT_SUITE_META}" TEST        "none"
        lock_add_metadata "${AB_UNIT_SUITE_META}" TEST_COUNT  0

        ab_unit_run_event "${TEST_SUITE}" "" "start_suite_event" "${AB_UNIT_START_SUITE_EVENT}" "${TEST_SUITE}"

        ab_unit_run_suite_setup "${TEST_SUITE}"

        TEST_RUNNING_PIDS=""
        TEST_RUNNING_PID=""

        while [ "${#}" -gt 0 ] ; do

            ab_unit_run_test "${TEST_SUITE}" "${1}" &

            TEST_RUNNING_PID=$!

            renice "${AB_UNIT_NICE}" -p "${TEST_RUNNING_PID}" >/dev/null 2>&1

            TEST_RUNNING_PIDS="${TEST_RUNNING_PIDS} ${TEST_RUNNING_PID}"

            shift

            sleep 1

        done

        for TEST_PID in ${TEST_RUNNING_PIDS}; do

            wait "${TEST_PID}"

        done


        ab_unit_run_suite_teardown "${TEST_SUITE}"

        ab_unit_run_event "${TEST_SUITE}" "" "end_suite_event" "${AB_UNIT_END_SUITE_EVENT}" "${TEST_SUITE}"

    lock_exit "${AB_UNIT_SUITE_META}"


    lock_enter "${AB_UNIT_APP_LOCK}"

        lock_add_metadata "${AB_UNIT_APP_LOCK}" CALLER "ab_unit_run_suite"
        lock_add_metadata "${AB_UNIT_APP_LOCK}" SUITE  "${TEST_SUITE}"

        AB_UNIT_SUITES_RUNNING=$(lock_get_metadata "${AB_UNIT_APP_META}" "SUITE_COUNT")

        lock_set_metadata "${AB_UNIT_APP_META}" "SUITE_COUNT" $(( ${AB_UNIT_SUITES_RUNNING} - 1 ))

    lock_exit  "${AB_UNIT_APP_LOCK}"
}

function ab_unit_run_event
{
    #===============================================================================
    #          NAME:  ab_unit_run_event
    #   DESCRIPTION:
    #         USAGE:  ab_unit_run_event <suite> <test> <stage> <event> [<args>]*
    #       RETURNS:
    #===============================================================================

    if [ $# -ge 4 ] ; then

        TEST_SUITE="${1}"
        TEST_NAME="${2}"
        TEST_STAGE="${3}"
        TEST_EVENT="${4}"

        shift 4

        if [ -n "${TEST_EVENT}" ] ; then

            ab_unit_run_command "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${TEST_EVENT}" $@

        fi

    fi
}


function ab_unit_run_tests
{
    #===============================================================================
    #          NAME:  ab_unit_run_tests
    #   DESCRIPTION:
    #         USAGE:  ab_unit_run_tests
    #       RETURNS:  0/1 whether the test failed or passed
    #===============================================================================

    TESTS_TO_RUN=$(ab_unit_get_enabled_tests | sort)
    TESTS_UNIQUE_SUITES=$(ab_unit_get_enabled_tests | stream_split ":" 1 | sort -u)
    SUITE_RUNNING_PIDS=""

    mkdir -p "${LOCK_WORKING_AREA}"
    mkdir -p "${LOGGER_LOG_DIR}" 

    #
    # Create the metadata file that all suites about to be run share for common info
    #
    lock_enter "${AB_UNIT_APP_META}"

        lock_add_metadata "${AB_UNIT_APP_META}" CALLER      "ab_unit_run_tests"
        lock_add_metadata "${AB_UNIT_APP_META}" SUITE       "none"
        lock_add_metadata "${AB_UNIT_APP_META}" SUITE_COUNT 0

        #
        # Run the start event before any parallel suites are kicked off
        #
        ab_unit_run_event "" "" "start_run_event" "${AB_UNIT_START_RUN_EVENT}"

        # Unfortunately in bash the while loop is implemented as a subshell, changes to parameters e.g.
        # SUITE_RUNNING_PIDS are not made to enclosing logic
        #echo "${TESTS_UNIQUE_SUITES}" | while read TEST_SUITE ; do
        
        for TEST_SUITE in ${TESTS_UNIQUE_SUITES}; do

            TESTS_IN_SUITE=$(echo "${TESTS_TO_RUN}"  | grep "^${TEST_SUITE}:" | stream_split ":" 2-)

            ab_unit_run_suite "${TEST_SUITE}" ${TESTS_IN_SUITE} &

            SUITE_RUNNING_PIDS="${SUITE_RUNNING_PIDS} $!"

            sleep 1

        done

        #
        # Wait for all parallel running suites to finish before running the end event
        #
        for SUITE_PID in ${SUITE_RUNNING_PIDS}; do

            wait ${SUITE_PID}

        done


        ab_unit_run_event "" "" "end_run_event" "${AB_UNIT_END_RUN_EVENT}"

    lock_exit "${AB_UNIT_APP_META}"

    #[ -d "${LOCK_WORKING_AREA}" ] && rm -Rf "${LOCK_WORKING_AREA}"
}
