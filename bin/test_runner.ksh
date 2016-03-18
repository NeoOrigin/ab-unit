#!/bin/ksh
#===============================================================================
#
#          FILE:  test_runner.ksh
# 
#         USAGE:  ${AB_UNIT_HOME}/bin/test_runner.ksh <subcommands>*
#
#                 subcommands:
#
#                    <+C | --enable_context>                     - Enable context sensitive modifications
#                    <-C | --disable_context>                    - Disable context sensitive modifications
#                    <+d | --include_directory> <dir_path>       - Add a directory containing tests
#                    <-d | --exclude_directory> <dir_path>       - Remove a directory containing tests
#                    <+s | --include_suite>     <suite_path>     - Add a suite of tests
#                    <-s | --exclude_suite>     <suite_path>     - Remove a suite of tests
#                    <+t | --include_test> [<suite_path>] <test> - Adds a test (suite not required in sensitive mode)
#                    <-t | --exclude_test> [<suite_path>] <test> - Remove a test (suite not required in sensitive mode)
#                    <-h | --help | ? | -?>                      - Displays the usage
#                    <-v | --version>                            - Displays version information
# 
#   DESCRIPTION:  This script is the main interface for the AB_UNIT test framework.
#                 Upon invocation a user interface is created and linked to the
#                 underlying framework before running the test suite/s.
#
#                 Note that the interface is usually configured to be overriden by
#                 pre-built interfaces that can be found in the ${AB_UNIT_HOME}/etc/ui
#                 directory based on the value of the TEST_RUNNER_DEFAULT_INTERFACE environment
#                 parameter.
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Philip Bowditch
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  19/09/2008 18:36:49 GMT Daylight Time
#      REVISION:  ---
#==============================================================================

trap "" INT QUIT KILL TERM USR1

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

. "${AB_UNIT_HOME}/lib/system/numeric.ksh"
. "${AB_UNIT_HOME}/lib/system/string.ksh"
. "${AB_UNIT_HOME}/lib/system/system.ksh"
. "${AB_UNIT_HOME}/lib/io/stream.ksh"
. "${AB_UNIT_HOME}/lib/testing/ab_unit.ksh"
. "${AB_UNIT_HOME}/lib/ui/ui.ksh"

. "${AB_UNIT_HOME}/etc/locale/ab_unit.locale"


#---  GLOBALS   ----------------------------------------------------------------
#   DESCRIPTION:  Global variables used by this script
#-------------------------------------------------------------------------------

TEST_RUNNER_RUNNING=true                    # Set to indicate running a test
TEST_RUNNER_VERSION=1.5                     # Set to version of framework
TEST_RUNNER_PID=$$                          # Set to process id of interface
TEST_RUNNER_STARTED=$(system_get_datetime)  # Set to the starting time of the interface

TEST_RUNNER_WIDTH=""                        # width of screen
TEST_RUNNER_HEIGHT=""                       # height of screen

TEST_RUNNER_STATUS_UNSTARTED=100            # Represents unstarted tests
TEST_RUNNER_STATUS_STARTING=200             # Represents tests currently starting
TEST_RUNNER_STATUS_INIT=300                 # Represents tests currently getting initialised
TEST_RUNNER_STATUS_RUNNING=400              # Represents running tests
TEST_RUNNER_STATUS_PASSED=500               # Represents passed tests
TEST_RUNNER_STATUS_IGNORED=600              # Represents ignored tests
TEST_RUNNER_STATUS_FAILED=700               # Represents failed tests
TEST_RUNNER_STATUS_ERRORED=800              # Represents errored tests

TEST_RUNNER_SUBSTATUS_SETUP=10
TEST_RUNNER_SUBSTATUS_TEARDOWN=20


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function print_test_runner_usage
{
    #===============================================================================
    #          NAME:  print_test_runner_usage
    #   DESCRIPTION:  Prints the usage information for this script
    #         USAGE:  print_test_runner_usage
    #       RETURNS:  NONE
    #===============================================================================

    cat <<EOF
Usage: ${0} <options>+

    Where options is at least one or a combination of the following

    ( +C | --enable_context    )                        - Turns on context sensitive matching
    ( -C | --disable_context   )                        - Turns off context sensitive matching
    ( +d | --include_directory ) <directory>            - A directory of test suites to run
    ( +s | --include_suite     ) <suite>                - A test suite to run
    ( +t | --include_test      ) [<suite>] <testcase>   - A test case to run
    ( -d | --exclude_directory ) <directory>            - A directory of test suites to exclude
    ( -s | --exclude_suite     ) <suite>                - A test suite to exclude
    ( -t | --exclude_test      ) [<suite>] <testcase>   - A test case to exclude
    ( -h | --help | -? | ?     )                        - Displays this message
    ( -v | --version           )                        - Displays the version number
EOF
}

function get_status_color
{
    #===============================================================================
    #          NAME:  get_status_color
    #   DESCRIPTION:  Converts a status id and prints a shell interpreted colour
    #         USAGE:  get_status_color <status>
    #       RETURNS:  NONE
    #===============================================================================

    typeset TEST_MAX_STATUS="${1}"

    #
    # Determine the color of the progress bar to paint
    #

    typeset TEST_BG_COLOR=""
    case "${TEST_MAX_STATUS}" in

        "${TEST_RUNNER_STATUS_STARTING}" ) TEST_BG_COLOR="${TEST_RUNNER_COLOR_STARTING}"
                                           ;;
        "${TEST_RUNNER_STATUS_INIT}"     ) TEST_BG_COLOR="${TEST_RUNNER_COLOR_INIT}"
                                           ;;
        "${TEST_RUNNER_STATUS_RUNNING}"  ) TEST_BG_COLOR="${TEST_RUNNER_COLOR_RUNNING}"
                                           ;;
        "${TEST_RUNNER_STATUS_PASSED}"   ) TEST_BG_COLOR="${TEST_RUNNER_COLOR_PASSED}"
                                           ;;
        "${TEST_RUNNER_STATUS_FAILED}"   ) TEST_BG_COLOR="${TEST_RUNNER_COLOR_FAILED}"
                                           ;;
        "${TEST_RUNNER_STATUS_ERRORED}"  ) TEST_BG_COLOR="${TEST_RUNNER_COLOR_ERRORED}"
                                           ;;
        "${TEST_RUNNER_STATUS_IGNORED}"  ) TEST_BG_COLOR="${TEST_RUNNER_COLOR_IGNORED}"
                                           ;;
        *                                ) ;;

    esac

    echo -e "${TEST_BG_COLOR}"
}

function convert_to_internal_status
{
    #===============================================================================
    #          NAME:  convert_to_internal_status
    #   DESCRIPTION:  Converts a status string to an internally used id.  Allows for
    #                 finer control of test status changes/updates
    #         USAGE:  convert_to_internal_status <status> <stage>
    #       RETURNS:  NONE
    #===============================================================================

    typeset TEST_STATUS_NEW="${1}"
    typeset -l TEST_STAGE="${2}"

    #
    # Take the status string as output from AB_UNIT and turn into an
    # id as used by TEST_RUNNER
    #

    typeset TEST_STATUS_UPDATED="${TEST_RUNNER_STATUS_UNSTARTED}"
    case "${TEST_STATUS_NEW}" in

        "${AB_UNIT_UNSTARTED_STRING}" ) TEST_STATUS_UPDATED="${TEST_RUNNER_STATUS_UNSTARTED}"
                                        ;;
        "${AB_UNIT_RUNNING_STRING}"   ) TEST_STATUS_UPDATED="${TEST_RUNNER_STATUS_RUNNING}"
                                        ;;
        "${AB_UNIT_STARTING_STRING}"  ) TEST_STATUS_UPDATED="${TEST_RUNNER_STATUS_STARTING}"
                                        ;;
        "${AB_UNIT_INIT_STRING}"      ) TEST_STATUS_UPDATED="${TEST_RUNNER_STATUS_INIT}"
                                        ;;
        "${AB_UNIT_PASSED_STRING}"    ) TEST_STATUS_UPDATED="${TEST_RUNNER_STATUS_PASSED}"
                                        ;;
        "${AB_UNIT_IGNORED_STRING}"   ) TEST_STATUS_UPDATED="${TEST_RUNNER_STATUS_IGNORED}"
                                        ;;
        "${AB_UNIT_FAILED_STRING}"    ) TEST_STATUS_UPDATED="${TEST_RUNNER_STATUS_FAILED}"
                                        ;;
        "${AB_UNIT_ERRORED_STRING}"   ) TEST_STATUS_UPDATED="${TEST_RUNNER_STATUS_ERRORED}"
                                        ;;

    esac


    #
    # Allow for user defined 'hooks', if the status message was generated because of
    # performing a hook (i.e. running a test, a suite or just initialiazing) then
    # set new status to STARTING.
    #

    case "${TEST_STAGE}" in

        start_run_event | start_suite_event | start_test_event ) if [ "${TEST_STATUS_NEW}" == "${AB_UNIT_RUNNING_STRING}" ] ; then
                                                                     TEST_STATUS_UPDATED="${TEST_RUNNER_STATUS_STARTING}"
                                                                 fi
                                                                 ;;
        setup_test                                             ) if [ "${TEST_STATUS_NEW}" == "${AB_UNIT_RUNNING_STRING}" ] ; then
                                                                     TEST_STATUS_UPDATED="${TEST_RUNNER_STATUS_INIT}"
                                                                 fi
                                                                 ;;

    esac

    printf "%s\n" "${TEST_STATUS_UPDATED}"
}

function convert_to_external_status
{
    #===============================================================================
    #          NAME:  convert_to_external_status
    #   DESCRIPTION:  Converts an internal TEST_RUNNER status id to an externally
    #                 recognizable string printed to stdout.
    #         USAGE:  convert_to_external_status <status>
    #       RETURNS:  NONE
    #===============================================================================

    typeset TEST_STATUS_NEW="${1}"

    typeset TEST_STATUS_STRING=""

    case "${TEST_STATUS_NEW}" in

        "${TEST_RUNNER_STATUS_UNSTARTED}" ) TEST_STATUS_STRING="${AB_UNIT_UNSTARTED_STRING}"
                                            ;;
        "${TEST_RUNNER_STATUS_STARTING}"  ) TEST_STATUS_STRING="${AB_UNIT_STARTING_STRING}"
                                            ;;
        "${TEST_RUNNER_STATUS_INIT}"      ) TEST_STATUS_STRING="${AB_UNIT_INIT_STRING}"
                                            ;;
        "${TEST_RUNNER_STATUS_RUNNING}"   ) TEST_STATUS_STRING="${AB_UNIT_RUNNING_STRING}"
                                            ;;
        "${TEST_RUNNER_STATUS_PASSED}"    ) TEST_STATUS_STRING="${AB_UNIT_PASSED_STRING}"
                                            ;;
        "${TEST_RUNNER_STATUS_IGNORED}"   ) TEST_STATUS_STRING="${AB_UNIT_IGNORED_STRING}"
                                            ;;
        "${TEST_RUNNER_STATUS_FAILED}"    ) TEST_STATUS_STRING="${AB_UNIT_FAILED_STRING}"
                                            ;;
        "${TEST_RUNNER_STATUS_ERRORED}"   ) TEST_STATUS_STRING="${AB_UNIT_ERRORED_STRING}"
                                            ;;
        *                                 ) TEST_STATUS_STRING="${AB_UNIT_UNKNOWN_STRING}"
                                            ;;

    esac

    printf "%s\n" "${TEST_STATUS_STRING}"
}

function on_status_change
{
    #===============================================================================
    #          NAME:  on_status_change
    #   DESCRIPTION:  Handler for status change events, default is no action
    #         USAGE:  on_status_change <suite> <test> <stage> <status>
    #       RETURNS:  NONE
    #===============================================================================

    :
}

function on_runtime_change
{
    #===============================================================================
    #          NAME:  on_runtime_change
    #   DESCRIPTION:  Handler for run time change events, default is no action
    #         USAGE:  on_runtime_change <suite> <test> <stage> <runtime>
    #       RETURNS:
    #===============================================================================

    :
}

function on_output_change
{
    #===============================================================================
    #          NAME:  on_output_change
    #   DESCRIPTION:  Handler for stdout change events, default is no action
    #         USAGE:  on_output_change <suite> <test> <stage> <output>
    #       RETURNS:
    #===============================================================================

    :
}

function on_stderr_change
{
    #===============================================================================
    #          NAME:  on_stderr_change
    #   DESCRIPTION:  Handler for stderr change events, default is no action
    #         USAGE:  on_stderr_change <suite> <test> <stage> <stderr>
    #       RETURNS:
    #===============================================================================

    :
}

function on_start_change
{
    #===============================================================================
    #          NAME:  on_start_change
    #   DESCRIPTION:  Handler for start change events, default is no action
    #         USAGE:  on_start_change <suite> <test> <stage> <starttime>
    #       RETURNS:
    #===============================================================================

    :
}

function on_end_change
{
    #===============================================================================
    #          NAME:  on_end_change
    #   DESCRIPTION:  Handler for end change events, default is no action
    #         USAGE:  on_end_change <suite> <test> <stage> <endtime>
    #       RETURNS:  NONE
    #===============================================================================

    :
}

function on_cmd_change
{
    #===============================================================================
    #          NAME:  on_cmd_change
    #   DESCRIPTION:  Handler for command change events, default is no action
    #         USAGE:  on_cmd_change <suite> <test> <stage> <command>
    #       RETURNS:  NONE
    #===============================================================================

    :
}

function on_pwd_change
{
    #===============================================================================
    #          NAME:  on_pwd_change
    #   DESCRIPTION:  Handler for working directory change events, default is no action
    #         USAGE:  on_pwd_change <suite> <test> <stage> <directory>
    #       RETURNS:  NONE
    #===============================================================================

    :
}

function on_result_change
{
    #===============================================================================
    #          NAME:  on_result_change
    #   DESCRIPTION:  Handler for result change events, default is no action
    #         USAGE:  on_result_change <suite> <test> <stage> <return code>
    #       RETURNS:  NONE
    #===============================================================================

    :
}


function on_raw_input_change
{
    #===============================================================================
    #          NAME:  on_raw_input_change
    #   DESCRIPTION:  Hander for raw input from the AB_UNIT framework, output is
    #                 parsed by this function and passed onto the appropriate handler
    #         USAGE:  on_raw_input_change [<message>]
    #       RETURNS:  NONE
    #===============================================================================

    typeset line="${1}"

    #
    # Obtain the key fields from the ab unit message
    #
    typeset TEST_SUITE=$(   printf "%s\n" "${line}" | stream_split ":" 2  | stream_trim )
    typeset TEST_NAME=$(    printf "%s\n" "${line}" | stream_split ":" 4  | stream_trim )
    typeset TEST_STAGE=$(   printf "%s\n" "${line}" | stream_split ":" 6  | stream_trim )
    typeset MESSAGE_TYPE=$( printf "%s\n" "${line}" | stream_split ":" 7  | stream_trim )
    typeset MESSAGE_VALUE=$(printf "%s\n" "${line}" | stream_split ":" 8- | stream_ltrim)

    #
    # Used to handle status update events, runtime update events and stdout
    # Note that other events are silently dropped
    #

    case "${MESSAGE_TYPE}" in

        "${AB_UNIT_STDOUT_ID}"  ) on_output_change  "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${MESSAGE_VALUE}"
                                  ;;
        "${AB_UNIT_STDERR_ID}"  ) on_stderr_change  "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${MESSAGE_VALUE}"
                                  ;;
        "${AB_UNIT_STATUS_ID}"  ) on_status_change  "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${MESSAGE_VALUE}"
                                  ;;
        "${AB_UNIT_RUNTIME_ID}" ) on_runtime_change "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${MESSAGE_VALUE}"
                                  ;;
        "${AB_UNIT_START_ID}"   ) on_start_change   "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${MESSAGE_VALUE}"
                                  ;;
        "${AB_UNIT_END_ID}"     ) on_end_change     "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${MESSAGE_VALUE}"
                                  ;;
        "${AB_UNIT_CMD_ID}"     ) on_cmd_change     "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${MESSAGE_VALUE}"
                                  ;;
        "${AB_UNIT_PWD_ID}"     ) on_pwd_change     "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${MESSAGE_VALUE}"
                                  ;;
        "${AB_UNIT_RESULT_ID}"  ) on_result_change  "${TEST_SUITE}" "${TEST_NAME}" "${TEST_STAGE}" "${MESSAGE_VALUE}"
                                  ;;
        *                       ) ;;

    esac
}


function on_suite_register
{
    #===============================================================================
    #          NAME:  on_suite_register
    #   DESCRIPTION:  Handler for the register suite change events, default is no action
    #         USAGE:  on_suite_register <suite>
    #       RETURNS:  NONE
    #===============================================================================

    :
}

function on_suite_registered
{
    #===============================================================================
    #          NAME:  on_suite_registered
    #   DESCRIPTION:  Handler for the on registered suite change events, default is no action
    #         USAGE:  on_suite_registered <suite>
    #       RETURNS:  NONE
    #===============================================================================

    :
}

function on_suite_unregister
{
    #===============================================================================
    #          NAME:  on_suite_unregister
    #   DESCRIPTION:  Handler for the unregister suite change events, default is no action
    #         USAGE:  on_suite_unregister <suite>
    #       RETURNS:  NONE
    #===============================================================================

    :
}

function on_suite_unregistered
{
    #===============================================================================
    #          NAME:  on_suite_unregistered
    #   DESCRIPTION:  Handler for the unregistered suite change events, default is no action
    #         USAGE:  on_suite_unregistered <suite>
    #       RETURNS:  NONE
    #===============================================================================

    :
}

function on_test_register
{
    #===============================================================================
    #          NAME:  on_test_register
    #   DESCRIPTION:  Handler for the test register change events, default is no action
    #         USAGE:  on_test_register <suite> <test>
    #       RETURNS:  NONE
    #===============================================================================

    :
}

function on_test_registered
{
    #===============================================================================
    #          NAME:  on_test_registered
    #   DESCRIPTION:  Handler for the test registered change events, default is no action
    #         USAGE:  on_test_registered <suite> <test>
    #       RETURNS:  NONE
    #===============================================================================

    :
}

function on_test_unregister
{
    #===============================================================================
    #          NAME:  on_test_unregister
    #   DESCRIPTION:  Handler for the test unregister change events, default is no action
    #         USAGE:  on_test_unregister <suite> <test>
    #       RETURNS:  NONE
    #===============================================================================

    :
}

function on_test_unregistered
{
    #===============================================================================
    #          NAME:  on_test_unregistered
    #   DESCRIPTION:  Handler for the test unregistered change events, default is no action
    #         USAGE:  on_test_unregistered <suite> <test>
    #       RETURNS:  NONE
    #===============================================================================

    :
}


function initialize_ui
{
    #===============================================================================
    #          NAME:  initialize_ui
    #   DESCRIPTION:  Used to setup/initialise the user interface before running
    #                 tests and processing messages but after arguments have been
    #                 parsed
    #         USAGE:  initialize_ui
    #       RETURNS:  NONE
    #===============================================================================

    :
}


function destroy_ui
{
    #===============================================================================
    #          NAME:  destroy_ui
    #   DESCRIPTION:  Used to destroy the user interface before script completion
    #         USAGE:  destroy_ui
    #       RETURNS:  NONE
    #===============================================================================

    :
}


function parse_arguments
{
    #===============================================================================
    #          NAME:  parse_arguments
    #   DESCRIPTION:  Parses the command line arguments passed to the test runner
    #                 and sets the appropriate states such as registering tests
    #                 or even just printing the help menu before exiting
    #         USAGE:  parse_arguments <subcommands>*
    #
    #                 subcommands:
    #
    #                    <+C | --enable_context>                     - Enable context sensitive modifications
    #                    <-C | --disable_context>                    - Disable context sensitive modifications
    #                    <+d | --include_directory> <dir_path>       - Add a directory containing tests
    #                    <-d | --exclude_directory> <dir_path>       - Remove a directory containing tests
    #                    <+s | --include_suite>     <suite_path>     - Add a suite of tests
    #                    <-s | --exclude_suite>     <suite_path>     - Remove a suite of tests
    #                    <+t | --include_test> [<suite_path>] <test> - Adds a test (suite not required in sensitive mode)
    #                    <-t | --exclude_test> [<suite_path>] <test> - Remove a test (suite not required in sensitive mode)
    #                    <-h | --help | ? | -?>                      - Displays the usage
    #
    #       RETURNS:  NONE
    #===============================================================================

    typeset CONTEXT_SENSITIVE=true
    typeset SAVED_DIRECTORY=""
    typeset SAVED_SUITE=""

    while [ $# -gt 0 ] ; do

        typeset TEST_OPTION="${1}"

        case "${TEST_OPTION}" in

            \+C | \--enable_context    ) CONTEXT_SENSITIVE=true
                                         ;;
            \-C | \--disable_context   ) CONTEXT_SENSITIVE=false
            
                                         # Reset any saved context we may have built tup
                                         SAVED_DIRECTORY=""
                                         SAVED_SUITE=""
                                         ;;
            \+d | \--include_directory ) typeset TEST_DIRECTORY="${2}"
                                         typeset TEST_SUITE=""

                                         shift

                                         # Remember last directory
                                         [ "${CONTEXT_SENSITIVE}" == true ] && SAVED_DIRECTORY="${TEST_DIRECTORY}"

                                         TEST_SUITES=$(find "${TEST_DIRECTORY}" -name "${AB_UNIT_TEST_SUITE_REGX}" -a -type f)
                                         
                                         for TEST_SUITE in ${TEST_SUITES}; do

                                             # Remember last suite
                                             [ "${CONTEXT_SENSITIVE}" == true ] && SAVED_SUITE="${TEST_SUITE}"

                                             # Register the suite and call before and after hooks
                                             on_suite_register      "${TEST_SUITE}" &&
                                             ab_unit_register_suite "${TEST_SUITE}" &&
                                             on_suite_registered    "${TEST_SUITE}"

                                         done
                                         ;;
            \-d | \--exclude_directory ) typeset TEST_DIRECTORY="${2}"
                                         typeset TEST_SUITE=""

                                         shift

                                         # Remember last directory
                                         [ "${CONTEXT_SENSITIVE}" == true ] && SAVED_DIRECTORY="${TEST_DIRECTORY}"

                                         TEST_SUITES=$(find "${TEST_DIRECTORY}" -name "${AB_UNIT_TEST_SUITE_REGX}" -a -type f)
                                         
                                         for TEST_SUITE in ${TEST_SUITES} ; do

                                             # Remember last suite
                                             [ "${CONTEXT_SENSITIVE}" == true ] && SAVED_SUITE="${TEST_SUITE}"

                                             # Unregister the suite and call the before and after hooks
                                             on_suite_unregister      "${TEST_SUITE}" &&
                                             ab_unit_unregister_suite "${TEST_SUITE}" &&
                                             on_suite_unregistered    "${TEST_SUITE}"

                                         done
                                         ;;
            \+s | \--include_suite     ) typeset TEST_SUITE="${2}"
                                         shift

                                         if [ "${CONTEXT_SENSITIVE}" == true ] ; then

                                             # Check where the suite can be found, might be in a common directory
                                             if [[ -n "${SAVED_DIRECTORY}" && -f "${SAVED_DIRECTORY}/${TEST_SUITE}" ]] ; then

                                                 TEST_SUITE="${SAVED_DIRECTORY}/${TEST_SUITE}"

                                             fi

                                             # Remember last suite
                                             SAVED_SUITE="${TEST_SUITE}"

                                         fi

                                         # Register the suite and call the before and after hooks
                                         on_suite_register      "${TEST_SUITE}" &&
                                         ab_unit_register_suite "${TEST_SUITE}" &&
                                         on_suite_registered    "${TEST_SUITE}"
                                         ;;
            \-s | \--exclude_suite     ) typeset TEST_SUITE="${2}"
                                         shift

                                         if [ "${CONTEXT_SENSITIVE}" == true ] ; then

                                             # Check where the suite can be found, might be in a common directory
                                             if [[ -n "${SAVED_DIRECTORY}" && -f "${SAVED_DIRECTORY}/${TEST_SUITE}" ]] ; then

                                                 TEST_SUITE="${SAVED_DIRECTORY}/${TEST_SUITE}"

                                             fi

                                             # Remember last suite
                                             SAVED_SUITE="${TEST_SUITE}"

                                         fi

                                         # Unregister the suite and call the before and after hooks
                                         on_suite_unregister      "${TEST_SUITE}" &&
                                         ab_unit_unregister_suite "${TEST_SUITE}" &&
                                         on_suite_unregistered    "${TEST_SUITE}"
                                         ;;
            \+t | \--include_test      ) typeset TEST_SUITE=""

                                         # Use the last suite if applicable else we are assuming a suite and test were passed
                                         if [[ "${CONTEXT_SENSITIVE}" == true && -n "${SAVED_SUITE}" ]] ; then

                                             TEST_SUITE="${SAVED_SUITE}"

                                         else

                                             TEST_SUITE="${2}"

                                             shift

                                         fi

                                         # Register the test and call the before and after hooks
                                         on_test_register      "${TEST_SUITE}" "${2}" &&
                                         ab_unit_register_test "${TEST_SUITE}" "${2}" &&
                                         on_test_registered    "${TEST_SUITE}" "${2}"

                                         shift
                                         ;;
            \-t | \--exclude_test      ) typeset TEST_SUITE=""

                                         # Use the last suite if applicable else we are assuming a suite and test were passed
                                         if [ "${CONTEXT_SENSITIVE}" == true ] && [ -n "${SAVED_SUITE}" ]; then

                                             TEST_SUITE="${SAVED_SUITE}"

                                         else

                                             TEST_SUITE="${2}"

                                             shift

                                         fi

                                         # Unregister the test and call the before and after hooks
                                         on_test_unregister      "${TEST_SUITE}" "${2}" &&
                                         ab_unit_unregister_test "${TEST_SUITE}" "${2}" &&
                                         on_test_unregistered    "${TEST_SUITE}" "${2}"

                                         shift
                                         ;;
            \-h | \--help | \? | \-?   ) print_test_runner_usage
                                         exit 0
                                         ;;
            \-v | \--version           ) printf "%s: %s\n" "${0}" "${TEST_RUNNER_VERSION}"
                                         exit 0
                                         ;;
            *                          ) print_test_runner_usage >&2
                                         exit 1
                                         ;;

        esac

        shift

    done
}


#-- MAIN -----------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------

#
# As this script and library make use of many background jobs turn off
# automatic 'nicing' for performance
#
# Only applicable for ksh ?
# set +o bgnice

#
# Check if user is pointing to a script otherwise its a variable referencing
# an inbuilt interface, call it to setup the overrides
#
TEST_RUNNER_INTERFACE="${TEST_RUNNER_DEFAULT_INTERFACE}"
if [ ! -e "${TEST_RUNNER_INTERFACE}" ] ; then

    TEST_RUNNER_INTERFACE="${AB_UNIT_HOME}/etc/ui/test_runner_${TEST_RUNNER_DEFAULT_INTERFACE:-text}.ui"

fi

. "${TEST_RUNNER_INTERFACE}"

parse_arguments "${@}"

initialize_ui

#
# Un the tests, capturing its output so we can use event handlers to update the
# interface on change
#

ab_unit_run_tests | while read line ; do

    on_raw_input_change "${line}"

done

destroy_ui

unset TEST_RUNNER_RUNNING
unset TEST_RUNNER_VERSION

trap - INT QUIT KILL TERM USR1

exit 0
