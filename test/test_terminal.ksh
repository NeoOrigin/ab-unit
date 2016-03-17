#!/bin/ksh
#===============================================================================
#
#          FILE:  test_terminal.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/test/test_terminal.ksh 
# 
#   DESCRIPTION:  Simple test script that tests core functionality of the terminal
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

if [[ ! -f "${AB_UNIT_HOME}/lib/ui/terminal.ksh" && ! -L "${AB_UNIT_HOME}/lib/ui/terminal.ksh" ]] ; then

    echo "ERROR: ${AB_UNIT_HOME}/lib/ui/terminal.ksh library could not be located/sourced" >&2
    exit 4

fi

. "${AB_UNIT_HOME}/lib/ui/terminal.ksh"


#---  GLOBALS   ----------------------------------------------------------------
#   DESCRIPTION:  Global variables used by this script
#-------------------------------------------------------------------------------


#---  FUNCTIONS   --------------------------------------------------------------
#   DESCRIPTION:  Helper functions
#-------------------------------------------------------------------------------

function run_and_pause
{
    FUNC_NAME="$1"
    PROMPT="$2"
    
    clear
    echo "${PROMPT}"
    
    ${FUNC_NAME}
    
    printf "Continue [Y/N] ? "
    read RESULT
    
    case "${RESULT:-Y}" in
    
         y | Y | yes | YES | 1 | true | TRUE | True | Yes ) return 0
                                                            ;;
    esac
    
    return 1
}


#---  TESTS   ------------------------------------------------------------------
#   DESCRIPTION:  tests run by this script
#-------------------------------------------------------------------------------

function test_screen_test
{
    #===============================================================================
    #          NAME:  test_screen_test
    #   DESCRIPTION:  Outputs different colors to the screen for manual analysis
    #         USAGE:  test_screen_test
    #       RETURNS:
    #===============================================================================

    echo -e "${TERMINAL_FOREGROUND_BLACK}${TERMINAL_BACKGROUND_WHITE}This should be a black foreground [on white]${TERMINAL_NORMAL}"
    echo -e "${TERMINAL_FOREGROUND_RED}This should be a red foreground${TERMINAL_NORMAL}"
    echo -e "${TERMINAL_FOREGROUND_GREEN}This should be a green foreground${TERMINAL_NORMAL}"
    echo -e "${TERMINAL_FOREGROUND_YELLOW}This should be a yellow foreground${TERMINAL_NORMAL}"
    echo -e "${TERMINAL_FOREGROUND_BLUE}This should be a blue foreground${TERMINAL_NORMAL}"
    echo -e "${TERMINAL_FOREGROUND_MAGENTA}This should be a magenta foreground${TERMINAL_NORMAL}"
    echo -e "${TERMINAL_FOREGROUND_CYAN}This should be a cyan foreground${TERMINAL_NORMAL}"

    echo -e "${TERMINAL_BACKGROUND_BLACK}${TERMINAL_FOREGROUND_WHITE}This should be a white foreground [on black]${TERMINAL_NORMAL}"
    echo -e "${TERMINAL_BACKGROUND_RED}This should be a red background${TERMINAL_NORMAL}"
    echo -e "${TERMINAL_BACKGROUND_GREEN}This should be a green background${TERMINAL_NORMAL}"
    echo -e "${TERMINAL_BACKGROUND_YELLOW}This should be a yellow background${TERMINAL_NORMAL}"
    echo -e "${TERMINAL_BACKGROUND_BLUE}This should be a blue background${TERMINAL_NORMAL}"
    echo -e "${TERMINAL_BACKGROUND_MAGENTA}This should be a magenta background${TERMINAL_NORMAL}"
    echo -e "${TERMINAL_BACKGROUND_CYAN}This should be a cyan background${TERMINAL_NORMAL}"

    echo -e "Does this contain ${TERMINAL_BOLD}Bold${TERMINAL_NORMAL} Text?"
    echo -e "Is This low ${TERMINAL_LOWINTENSITY}intensity${TERMINAL_NORMAL}?"
    echo -e "Is this ${TERMINAL_ITALIC}italic${TERMINAL_NORMAL}?"
    echo -e "Is this ${TERMINAL_UNDERLINE}underlined${TERMINAL_NORMAL}?"
    echo -e "Is this ${TERMINAL_BLINK}blinking${TERMINAL_NORMAL}?"
    echo -e "Is this ${TERMINAL_RAPIDBLINK}rapid blinking${TERMINAL_NORMAL}?"
    echo -e "Foreground/Background ${TERMINAL_REVERSE}reversed${TERMINAL_NORMAL}?"
    echo -e "${TERMINAL_INVISIBLE}invisible${TERMINAL_NORMAL}"

    return 0
}

function test_terminal_get_screen_height
{
    terminal_get_screen_height
}

function test_terminal_get_screen_width
{
    terminal_get_screen_width
}

function test_terminal_get_dimensions
{
    terminal_get_dimensions
}

function test_terminal_clear
{
    terminal_clear
}


#-- MAIN -----------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------

trap "" ERR HUP INT EXIT

    terminal_initscr &&
      run_and_pause   test_screen_test                  "Do the following colors look accurately represented?"            &&
      run_and_pause   test_terminal_get_screen_height   "Does the following accurately return the screen height?"         &&
      run_and_pause   test_terminal_get_screen_width    "Does the following accurately return the screen width?"          &&
      run_and_pause   test_terminal_get_dimensions      "Does the following accurately return the screen dimensions?"
    RC=$?

trap - INT QUIT KILL TERM USR1

return $RC