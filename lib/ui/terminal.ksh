#!/bin/ksh
#===============================================================================
#
#          FILE:  terminal.ksh
#
#         USAGE:  . ${AB_UNIT_HOME}/lib/ui/terminal.ksh
#
#   DESCRIPTION:  Script functions to perform text based cursor movements to specified
#                 locations on the screen.  Functions work similar to 'C' language 'Curses' library.
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Philip Bowditch
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  23/09/2008 14:07:22 GMT Daylight Time
#      REVISION:  ---
#===============================================================================


#---  GLOBALS   ----------------------------------------------------------------
#   DESCRIPTION:  Global variables used by this script
#-------------------------------------------------------------------------------

export TERMINAL_FOREGROUND_BLACK="[30m"
export TERMINAL_FOREGROUND_RED="[31m"
export TERMINAL_FOREGROUND_GREEN="[32m"
export TERMINAL_FOREGROUND_YELLOW="[33m"
export TERMINAL_FOREGROUND_BLUE="[34m"
export TERMINAL_FOREGROUND_MAGENTA="[35m"
export TERMINAL_FOREGROUND_CYAN="[36m"
export TERMINAL_FOREGROUND_WHITE="[37m"

export TERMINAL_BACKGROUND_BLACK="[40m"
export TERMINAL_BACKGROUND_RED="[41m"
export TERMINAL_BACKGROUND_GREEN="[42m"
export TERMINAL_BACKGROUND_YELLOW="[43m"
export TERMINAL_BACKGROUND_BLUE="[44m"
export TERMINAL_BACKGROUND_MAGENTA="[45m"
export TERMINAL_BACKGROUND_CYAN="[46m"
export TERMINAL_BACKGROUND_WHITE="[47m"

export TERMINAL_NORMAL="[0m"
export TERMINAL_BOLD="[1m"
export TERMINAL_LOWINTENSITY="[2m"
export TERMINAL_ITALIC="[3m"
export TERMINAL_UNDERLINE="[4m"
export TERMINAL_BLINK="[5m"
export TERMINAL_RAPIDBLINK="[6m"
export TERMINAL_REVERSE="[7m"
export TERMINAL_INVISIBLE="[8m"


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function terminal_get_screen_height
{
    #===============================================================================
    #          NAME:  terminal_get_screen_height
    #   DESCRIPTION:
    #    PARAMETERS:
    #       RETURNS:
    #===============================================================================
    
    tput lines
}

function terminal_get_screen_width
{
    #===============================================================================
    #          NAME:  terminal_get_screen_width
    #   DESCRIPTION:
    #    PARAMETERS:
    #       RETURNS:
    #===============================================================================

    tput cols
}

function terminal_get_dimensions
{
    #===============================================================================
    #          NAME:  terminal_get_dimensions
    #   DESCRIPTION:
    #    PARAMETERS:
    #       RETURNS:
    #===============================================================================
    
    H=$(terminal_get_screen_height)
    W=$(terminal_get_screen_width)
    
    printf "%dx%d\n" "$W" "$H"
}

function terminal_addch
{
    #===============================================================================
    #          NAME:  terminal_addch
    #   DESCRIPTION:  Prints the character on the screen at the current position.
    #    PARAMETERS:  1 - A single character to display
    #       RETURNS:  The return code of the add operation
    #===============================================================================

    #typeset -L1 UI_CH="${1}"

    terminal_addstr "${1:0:1}"
    return $?
}

function terminal_addstr
{
    #===============================================================================
    #          NAME:  terminal_addstr
    #   DESCRIPTION:  Prints the value of the string on screen at the current position.  
    #    PARAMETERS:  1 - A string to display
    #       RETURNS:  The return code of the add operation
    #===============================================================================

    [[ "X${1}" != "X" ]] && BUF_SCREEN="${BUF_SCREEN}${1}"

    return $?
}

function terminal_attroff
{
    #===============================================================================
    #          NAME:  terminal_attroff
    #   DESCRIPTION:  Turn off all screen attributes
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the operation
    #===============================================================================

    terminal_addstr "${CMD_ATTROFF}"
    return ${?}
}

function terminal_attron
{
    #===============================================================================
    #          NAME:  terminal_attron
    #   DESCRIPTION:  Does Nothing.  Exists for curses backwards compatability
    #    PARAMETERS:  NONE
    #       RETURNS:  0 - TRUE
    #===============================================================================

    return 0
}

function terminal_attrset
{
    #===============================================================================
    #          NAME:  terminal_attrset
    #   DESCRIPTION:  Sets the screen attribute defined by the attribute parameter
    #    PARAMETERS:  1 - A string attribute definition
    #
    #           Values:
    #
    #               rev     - Reverse Video
    #               blink   - Blinking Mode
    #               bold    - Bold Video
    #               dim - Half Bright Video
    #               smul    - Start Underscore Mode
    #               rmul    - End Underscore Mode
    #               sgr0    - Exit All Attributes
    #               
    #       RETURNS:  The return code of the operation
    #===============================================================================

    terminal_addstr "$( ${CMD_ATTRSET} ${1} )"
    return $?
}

function terminal_beep
{
    #===============================================================================
    #          NAME:  terminal_beep
    #   DESCRIPTION:  Ring the display bell
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the operation
    #===============================================================================

    terminal_addstr "${CMD_BEEP}"
    return $?
}

function terminal_chkcols
{
    #===============================================================================
    #          NAME:  terminal_chkcols
    #   DESCRIPTION:  Determine if value of Nbr parameter is less than or equal to the number of lines on the screen.
    #    PARAMETERS:  1 - Numeric argument to check
    #       RETURNS:  The return code of the check operation
    #===============================================================================

    terminal_chkint ${1} ${2}         &&
            (( ${2} >= 0 ))           &&
            (( ${2} <= ${MAX_COLS} )) &&
            return 0

    ROW_NBR="24"
    COL_NBR="1"

    eval terminal_addstr \"${CMD_MOVE}\"              &&
    terminal_clrtoeol                                 &&
    terminal_addstr "${1}: Invalid column number" >&2 &&
    terminal_refresh                                  &&
    ${ERROR_PAUSE}                                    &&
    eval terminal_addstr \"${CMD_MOVE}\"              &&
    terminal_clrtoeol                                 &&
    terminal_refresh

    return 1
}

function terminal_chkint
{
    #===============================================================================
    #          NAME:  terminal_chkint
    #   DESCRIPTION:  Determine if value of Nbr parameter is numeric
    #    PARAMETERS:  1 - The numeric value to check
    #       RETURNS:  The return code of the check operation
    #===============================================================================

    let '${2} + 0' > "${DEV_NULL}" 2>&1 && return 0

    ROW_NBR="24"
    COL_NBR="1"

    eval terminal_addstr \"${CMD_MOVE}\"              &&
    terminal_clrtoeol                                 &&
    terminal_addstr "${1}: argument not a number" >&2 &&
    terminal_refresh                                  &&
    ${ERROR_PAUSE}                                    &&
    eval terminal_addstr \"${CMD_MOVE}\"              &&
    terminal_clrtoeol                                 &&
    terminal_refresh

    return 1
}

function terminal_chklines
{
    #===============================================================================
    #          NAME:  terminal_chklines
    #   DESCRIPTION:  Determine if value of Nbr parameter is less than or equal to the number of lines on the display
    #    PARAMETERS:  1 - The numeric value to check
    #       RETURNS:  The return code of the check operation
    #===============================================================================

    terminal_chkint ${1} ${2}      &&
        (( ${2} >= 0 ))            &&
        (( ${2} <= ${MAX_LINES} )) &&
        return 0

    ROW_NBR="24"
    COL_NBR="1"

    eval terminal_addstr \"${CMD_MOVE}\"            &&
    terminal_clrtoeol                               &&
    terminal_addstr "${1}: Invalid line number" >&2 &&
    terminal_refresh                                &&
    ${ERROR_PAUSE}                                  &&
    eval terminal_addstr \"${CMD_MOVE}\"            &&
    terminal_clrtoeol                               &&
    terminal_refresh

    return 1
}

function terminal_chkparm
{
    #===============================================================================
    #          NAME:  terminal_chkparm
    #   DESCRIPTION:  Determine if value of string parameter is null
    #    PARAMETERS:  1 - The alpha-numeric argument to check
    #       RETURNS:  The return code of the check operation
    #===============================================================================

    [[ "X${2}" = "X" ]]                               &&
        terminal_move 24 1                            &&
        terminal_clrtoeol                             &&
        terminal_addstr "${1}: Missing parameter" >&2 &&
        terminal_refresh                              &&
        ${ERROR_PAUSE}                                &&
        terminal_move 24 1                            &&
        terminal_clrtoeol                             &&
        return 1

    return 0
}

function terminal_clear
{
    #===============================================================================
    #          NAME:  terminal_clear
    #   DESCRIPTION:  Clears the screen
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the clear operation
    #===============================================================================

    terminal_addstr "${CMD_CLEAR}"
    return $?
}

function terminal_clrtobol
{
    #===============================================================================
    #          NAME:  terminal_clrtobol
    #   DESCRIPTION:  Clear the line from the current column to the beginning of the line
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the clear operation
    #===============================================================================

    terminal_addstr "${CMD_CLRTOBOL}"
    return $?
}

function terminal_clrtobot
{
    #===============================================================================
    #          NAME:  terminal_clrtobot
    #   DESCRIPTION:  Clear the screen from the current column to the ens of the screen
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code for the clear operation
    #===============================================================================

    terminal_addstr "${CMD_CLRTOEOD}"
    return $?
}

function terminal_clrtoeol
{
    #===============================================================================
    #          NAME:  terminal_clrtoeol
    #   DESCRIPTION:  Clear the current line from the current column to end of the line
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the clear operation
    #===============================================================================

    terminal_addstr "${CMD_CLRTOEOL}"
    return $?
}

function terminal_delch
{
    #===============================================================================
    #          NAME:  terminal_delch
    #   DESCRIPTION:  Delete one character at the current screen position
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the delete operation
    #===============================================================================

    terminal_addstr "${CMD_DELCH}"
    return $?
}

function terminal_deleteln
{
    #===============================================================================
    #          NAME:  terminal_deleteln
    #   DESCRIPTION:  Delete the line at the current row
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the delete operation
    #===============================================================================

    terminal_addstr "${CMD_DELETELN}"
    return $?
}

function terminal_endwin
{
    #===============================================================================
    #          NAME:  terminal_endwin
    #   DESCRIPTION:  De-initializes the curses screen addressing system
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the de-initializing operation
    #===============================================================================

    unset MAX_LINES
    unset MAX_COLS
    unset BUF_SCREEN
    return $?
}

function terminal_getch
{
    #===============================================================================
    #          NAME:  terminal_getch
    #   DESCRIPTION:  Retrieve one character from standard input
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the read operation
    #===============================================================================

    IFS='' read -r -- TMP_GETCH
    STATUS="$?"
    eval \${CMD_ECHO} ${OPT_ECHO} \"\${TMP_GETCH}\"
    return ${STATUS}
}

function terminal_getstr
{
    #===============================================================================
    #          NAME:  terminal_getstr
    #   DESCRIPTION:  Retrieve a string of characters from standard input
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the read operation
    #===============================================================================

    IFS="${IFS_CR}"
    terminal_getch
    STATUS="$?"
    IFS="${IFS_NORM}"
    return ${STATUS}
}

function terminal_getwd
{
    #===============================================================================
    #          NAME:  terminal_getwd
    #   DESCRIPTION:  Retrieve one word from standard input
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the read operation
    #===============================================================================

    terminal_getch
    return $?
}

function terminal_initscr
{
    #===============================================================================
    #          NAME:  terminal_initscr
    #   DESCRIPTION:  Initializes the shell curses screen addressing system
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the initializing operation
    #===============================================================================

    PGMNAME="Korn Shell Terminal"
    DEV_NULL="/dev/null"
    CMD_TPUT="tput"                     # Terminal "put" command

    eval CMD_MOVE=\`echo -e \"`tput cup`\" \| sed \\\
-e \"s/%p1%d/\\\\\${1}/g\" \\\
-e \"s/%p2%d/\\\\\${2}/g\" \\\
-e \"s/%p1%02d/\\\\\${1}/g\" \\\
-e \"s/%p2%02d/\\\\\${2}/g\" \\\
-e \"s/%p1%03d/\\\\\${1}/g\" \\\
-e \"s/%p2%03d/\\\\\${2}/g\" \\\
-e \"s/%p1%03d/\\\\\${1}/g\" \\\
-e \"s/%d\\\;%dH/\\\\\${1}\\\;\\\\\${2}H/g\" \\\
-e \"s/%p1%c/'\\\\\\\`echo -e \\\\\\\${1} P | dc\\\\\\\`'/g\" \\\
-e \"s/%p2%c/'\\\\\\\`echo -e \\\\\\\${2} P | dc\\\\\\\`'/g\" \\\
-e \"s/%p1%\' \'%+%c/'\\\\\\\`echo -e \\\\\\\${1} 32 + P | dc\\\\\\\`'/g\" \\\
-e \"s/%p2%\' \'%+%c/'\\\\\\\`echo -e \\\\\\\${2} 32 + P | dc\\\\\\\`'/g\" \\\
-e \"s/%p1%\'@\'%+%c/'\\\\\\\`echo -e \\\\\\\${1} 100 + P | dc\\\\\\\`'/g\" \\\
-e \"s/%p2%\'@\'%+%c/'\\\\\\\`echo -e \\\\\\\${2} 100 + P | dc\\\\\\\`'/g\" \\\
-e \"s/%i//g\;s/%n//g\"\`

    CMD_CLEAR="$( ${CMD_TPUT} clear 2>${DEV_NULL} )"      # Clear display
    CMD_LINES="$( ${CMD_TPUT} lines 2>${DEV_NULL} )"      # Number of lines on display
    CMD_COLS="$( ${CMD_TPUT} cols 2>${DEV_NULL} )"        # Number of columns on display
    CMD_CLRTOEOL="$( ${CMD_TPUT} el 2>${DEV_NULL} )"      # Clear to end of line
    CMD_CLRTOBGN="$( ${CMD_TPUT} el1 2>${DEV_NULL} )"     # Clear to beginning of line
    CMD_CLRTOEOD="$( ${CMD_TPUT} ed 2>${DEV_NULL} )"      # Clear to end of display
    CMD_DELCH="$( ${CMD_TPUT} dch1 2>${DEV_NULL} )"       # Delete current character
    CMD_DELETELN="$( ${CMD_TPUT} dl1 2>${DEV_NULL} )"     # Delete current line
    CMD_INSCH="$( ${CMD_TPUT} ich1 2>${DEV_NULL} )"       # Insert 1 character
    CMD_INSERTLN="$( ${CMD_TPUT} il1 2>${DEV_NULL} )"     # Insert 1 Line
    CMD_ATTROFF="$( ${CMD_TPUT} sgr0 2>${DEV_NULL} )"     # All Attributes OFF
    CMD_ATTRSET="${CMD_TPUT}"                             # requires arg ( rev, blink, etc )
    CMD_BEEP="$( ${CMD_TPUT} bel 2>${DEV_NULL} )"         # ring bell
    CMD_LISTER="cat"
    CMD_SYMLNK="ln -s"
    #CMD_ECHO="echo"
    #OPT_ECHO='-e -n'
    CMD_ECHO="print"
    OPT_ECHO='-n --'
    CMD_MAIL="mail"
    WHOAMI="${LOGNAME}@$( uname -n )"
    WRITER="philip.bowditch"
    CMD_NOTIFY="\${CMD_ECHO} ${OPT_ECHO} \"\${PGMNAME} - \${WHOAMI} - \$( date )\" | \${CMD_MAIL} \${WRITER}"
    ERROR_PAUSE="sleep 2"

    case "_$( uname -s )" in

        "_Windows_NT" ) DEV_NULL="NUL"
                        CMD_SYMLNK="cp"
                        ;;
        "_Linux"      ) #CMD_ECHO="echo -e"
                        ;;

    esac

    IFS_CR="$'\n'"
    IFS_CR="
"
    IFS_NORM="$' \t\n'"
    IFS_NORM="
"

    MAC_TIME="TIMESTAMP=\`date +\"%y:%m:%d:%H:%M:%S\"\`"
    MAX_LINES=$( terminal_get_screen_height )
    MAX_COLS=$(  terminal_get_screen_width )
    BUF_SCREEN=""
    BUF_TOT=""

    return 0
}

function terminal_insch
{
    #===============================================================================
    #          NAME:  terminal_insch
    #   DESCRIPTION:  Insert a character at the current screen position
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the insert operation
    #===============================================================================

    terminal_addstr "${CMD_INSCH}"
    return ${?}
}

function terminal_insertln
{
    #===============================================================================
    #          NAME:  terminal_insertln
    #   DESCRIPTION:  Insert one line at the current screen position
    #    PARAMETERS:  NONE
    #       RETURNS:  The return code of the insert operation
    #===============================================================================

    terminal_addstr "${CMD_INSERTLN}"
    return $?
}

function terminal_move
{
    #===============================================================================
    #          NAME:  terminal_move
    #   DESCRIPTION:  Moves the logical cursor to the row and column specified
    #    PARAMETERS:  1 - The row, 2 - The column to move to
    #       RETURNS:  The return code of the move operation
    #===============================================================================

    eval terminal_addstr \"${CMD_MOVE}\"

    return $?
}

function terminal_mvaddch
{
    #===============================================================================
    #          NAME:  terminal_mvaddch
    #   DESCRIPTION:  Moves the logical cursor to the row and column specified.  Prints the character specified.
    #    PARAMETERS:  1 - The row, 2 - The column, 3 - The character to add
    #       RETURNS:  The return code of the add operation
    #===============================================================================

    terminal_move "${1}" "${2}" && terminal_addch "${3}"

    return $?
}

function terminal_mvaddstr
{
    #===============================================================================
    #          NAME:  terminal_mvaddstr
    #   DESCRIPTION:  Moves the logical cursor to the row and column specified.  Prints the value of string o nthe screen.  
    #    PARAMETERS:  1 - The row, 2 - The column, 3 - The string to add
    #       RETURNS:  The return code of the add operation
    #===============================================================================

    terminal_move "${1}" "${2}" && terminal_addstr "${3}"

    return $?
}

function terminal_mvclrtobol
{
    #===============================================================================
    #          NAME:  terminal_mvclrtobol
    #   DESCRIPTION:  Moves the logical cursor to the row and column specified.  Clear the line from the current column to the beginning of the line
    #    PARAMETERS:  1 - The row, 2 - The column to move to
    #       RETURNS:  The return code of the clear operation
    #===============================================================================

    terminal_move "${1}" "${2}" && terminal_clrtobol

    return $?
}


function terminal_mvclrtobot
{
    #===============================================================================
    #          NAME:  terminal_mvclrtobot
    #   DESCRIPTION:  Moves the logical cursor to the row and column specified.  Clear
    #                 the display from the current column to the end of the display.
    #         USAGE:  terminal_mvclrtobot <row> <column>
    #       RETURNS:  The return code of the clear operation
    #===============================================================================

    terminal_move "${1}" "${2}" && terminal_clrtobot

    return $?
}

function terminal_mvclrtoeol
{
    #===============================================================================
    #          NAME:  terminal_mvclrtoeol
    #   DESCRIPTION:  Moves the logical cursor to the row and column specified.
    #         USAGE:  terminal_mvclrtoeol <row> <column>
    #       RETURNS:  The return code of the clear operation
    #===============================================================================

    terminal_move "${1}" "${2}" && terminal_clrtoeol

    return $?
}


function terminal_mvcur
{
    #===============================================================================
    #          NAME:  terminal_mvcur
    #   DESCRIPTION:  Move the physical cursor to the row and column specified.
    #         USAGE:  terminal_mvcur <row> <column>
    #       RETURNS:  The return code of the move operation
    #===============================================================================

    terminal_chklines "${0}" "${1}" &&
    terminal_chkcols  "${0}" "${2}" &&
    eval \"${CMD_MOVE}\"

    return $?
}

function terminal_mvdelch
{
    #===============================================================================
    #          NAME:  terminal_mvdelch
    #   DESCRIPTION:  Moves the logical cursor to the row and column specified.  Delete
    #                 one character at the specified position.
    #         USAGE:  terminal_mvdelch <row> <column>
    #       RETURNS:  The return code of the move operation
    #===============================================================================

    terminal_move "${1}" "${2}" && terminal_addstr "${CMD_DELCH}"

    return $?
}

function terminal_mvinsch
{
    #===============================================================================
    #          NAME:  terminal_mvinsch
    #   DESCRIPTION:  Moves the logical cursor to the row and column specified.  Insert
    #                 character at the specified position
    #         USAGE:  terminal_mvinsch <row> <column>
    #       RETURNS:  The return code of the insert operation
    #===============================================================================

    terminal_move "${1}" "${2}" && terminal_addstr "${CMD_INSCH}"

    return $?
}

function terminal_refresh
{
    #===============================================================================
    #          NAME:  terminal_refresh
    #   DESCRIPTION:  Empties the logical buffer to the screen.  If an argument is given the
    #                 specified buffer will be used
    #         USAGE:  terminal_refresh [<buffer_name>]
    #       RETURNS:  The return code of the refresh operation
    #===============================================================================

    if [[ "_${1}" != "_" ]] ; then

        eval \${CMD_ECHO} \${OPT_ECHO} \"\${${1}}\"

    else

        ${CMD_ECHO} ${OPT_ECHO} "${BUF_SCREEN}"
        BUF_TOT="${BUF_TOT}${BUF_SCREEN}"
        BUF_SCREEN=""

    fi

    return 0
}

function terminal_savescr
{
    #===============================================================================
    #          NAME:  terminal_savescr
    #   DESCRIPTION:  Saves the logical screen buffer into an environment variable defined by buffer parameter
    #         USAGE:  terminal_savescr <buffer_name>
    #       RETURNS:  The return code of the save operation
    #===============================================================================

    [[ "X${DEV_NULL}" != "X${1}" ]] && eval ${1}="\"\${BUF_TOT}\""

    BUF_TOT=""
    return $?
}
