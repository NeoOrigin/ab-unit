#!/bin/ksh
#===============================================================================
#
#          FILE:  ui.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/ui/ui.ksh
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Philip Bowditch
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  01/10/2008 21:14:58 GMT Daylight Time
#      REVISION:  ---
#===============================================================================

#---  INCLUDES  ----------------------------------------------------------------
#   DESCRIPTION: Defines the external scripts used by this script
#-------------------------------------------------------------------------------

if [ -z "${AB_UNIT_HOME}" ] ; then

    printf "%s: %s %s\n" ERROR AB_UNIT_HOME "environment variable is not set" >&2
    exit 1

fi

if [ ! -e "${AB_UNIT_HOME}" ] ; then

    printf "%s: %s %s\n" ERROR AB_UNIT_HOME "environment variable points to a directory that does not exist" >&2
    exit 2

fi

if [[ ! -d "${AB_UNIT_HOME}" && ! -L "${AB_UNIT_HOME}" ]] ; then

    printf "%s: %s %s\n" ERROR AB_UNIT_HOME "environment variable is not a valid directory" >&2
    exit 3

fi

. "${AB_UNIT_HOME}/lib/ui/terminal.ksh"
. "${AB_UNIT_HOME}/lib/io/stream.ksh"
. "${AB_UNIT_HOME}/lib/system/string.ksh"
. "${AB_UNIT_HOME}/lib/system/numeric.ksh"


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function ui_print_label
{
    #===============================================================================
    #          NAME:  ui_print_label
    #   DESCRIPTION:
    #         USAGE:  ui_print_label <text> <x> <y> <width> [( right | left )]
    #       RETURNS:
    #===============================================================================

    typeset UI_X="${2}"
    typeset UI_Y="${3}"
    typeset UI_WIDTH="${4}"
    typeset UI_ALIGN="${5}"

    typeset UI_TEMP_CHAR=""

    if [ "${UI_WIDTH}" -ge 0 ] ; then

        case "${UI_ALIGN}" in

            right ) UI_TEMP_CHAR="-R"
                    ;;
            left  ) UI_TEMP_CHAR="-L"
                    ;;

        esac

        UI_TEMP_CHAR="${UI_TEMP_CHAR}${UI_WIDTH}"

    fi

    typeset ${UI_TEMP_CHAR} UI_STR="${1}"

    terminal_mvclrtoeol "${UI_Y}" "${UI_X}"
    terminal_addstr "${UI_STR}"
}


function ui_print_pixel
{
    #===============================================================================
    #          NAME:  ui_print_pixel
    #   DESCRIPTION:
    #    PARAMETERS:
    #       RETURNS:
    #===============================================================================

    typeset UI_VALUE="${1}"
    typeset UI_X="${2}"
    typeset UI_Y="${3}"

    terminal_mvaddch "${UI_Y}" "${UI_X}" "${UI_VALUE}"
}


function ui_print_box
{
    #===============================================================================
    #          NAME:  ui_print_box
    #   DESCRIPTION:
    #    PARAMETERS:
    #       RETURNS:
    #===============================================================================

    typeset UI_X="${1}"
    typeset UI_Y="${2}"
    typeset UI_WIDTH="${3}"
    typeset UI_HEIGHT="${4}"

    ui_print_line "${UI_X}" "${UI_Y}" "${UI_WIDTH}"

    # Normalise the width to real X co-ordinates
    let UI_WIDTH="UI_WIDTH + UI_X"
    let UI_HEIGHT="UI_HEIGHT + UI_Y"

    typeset -i UI_Y_POS="${UI_Y}"
    while [ "${UI_Y_POS}" -lt "${UI_HEIGHT}" ] ; do

        ui_print_pixel "|" "${UI_X}"     "${UI_Y_POS}"
        ui_print_pixel "|" "${UI_WIDTH}" "${UI_Y_POS}"

        (( UI_Y_POS += 1 ))

    done

    ui_print_line "${UI_X}" "${UI_HEIGHT}" "${UI_WIDTH}"
}


function ui_print_text_area
{
    #===============================================================================
    #          NAME:  ui_print_text_area
    #   DESCRIPTION:
    #    PARAMETERS:
    #       RETURNS:
    #===============================================================================

    typeset UI_TEXT="${1}"
    typeset UI_X="${2}"
    typeset UI_Y="${3}"
    typeset UI_WIDTH="${4}"
    typeset UI_HEIGHT="${5}"
    typeset UI_WITH_BORDER="${6}"

    typeset H_VAR=0

    typeset UI_AREA="${UI_WIDTH}"

    if [ "X${UI_WITH_BORDER}" == "XY" ] ; then

        ui_print_line "${UI_X}" "${UI_Y}" "${UI_WIDTH}"

        H_VAR=1
        (( UI_AREA = UI_WIDTH - 2 ))        # Minus the 2 border characters |

    fi

    typeset -L${UI_AREA} UI_TEMP=""
    string_word_wrap "${UI_TEXT}" "${UI_AREA}" | while read line ; do

        if [ ${H_VAR} -ge ${UI_HEIGHT} ] ; then

            break

        fi

        UI_TEMP="${line}"

        if [ "X${UI_WITH_BORDER}" == "XY" ] ; then

            terminal_mvaddstr $(( ${UI_Y} + ${H_VAR} )) "${UI_X}" "|${UI_TEMP}|"

        else

            terminal_mvaddstr $(( ${UI_Y} + ${H_VAR} )) "${UI_X}" "${UI_TEMP}"
    
        fi

        (( H_VAR += 1 ))

    done

    while [ ${H_VAR} -lt ${UI_HEIGHT} ] ; do

        UI_TEMP=" "
        if [ "X${UI_WITH_BORDER}" == "XY" ] ; then

            terminal_mvaddstr $(( ${UI_Y} + ${H_VAR} )) "${UI_X}" "|${UI_TEMP}|"

        else

            terminal_mvaddstr $(( ${UI_Y} + ${H_VAR} )) "${UI_X}" "${UI_TEMP}"

        fi

        (( H_VAR += 1 ))

    done

    if [ "X${UI_WITH_BORDER}" == "XY" ] ; then

        ui_print_line "${UI_X}" $(( ${UI_Y} + ${H_VAR} )) "${UI_WIDTH}"

    fi
}

function ui_print_tree_row
{
    typeset UI_X="${1}"
    typeset UI_Y="${2}"
    typeset UI_WIDTH="${3}"

    typeset UI_LEVEL="${4}"

    typeset PAD_AMT=$(( ${UI_LEVEL} * 2 ))
    typeset -L${PAD_AMT} PADDED_INDENT=""

    typeset -L$(( ${UI_WIDTH} - ${PAD_AMT} )) UI_VALUE="${5}"

    terminal_mvaddstr "${UI_Y}" "${UI_X}" "${PADDED_INDENT}${UI_VALUE}"
}

function ui_print_line
{
    typeset UI_X="${1}"
    typeset UI_Y="${2}"
    typeset UI_WIDTH="${3}"

    typeset BORDER_SIZE=$(( ${UI_WIDTH} - 2 ))     # -2 for +'s
    typeset PADDED_STR=$(echo "$(printf +%${BORDER_SIZE}s+ ' ')" | sed 's/[ ]/-/g')

    terminal_mvclrtoeol "${UI_Y}" "${UI_X}"
    terminal_addstr "${PADDED_STR}"
}

function ui_print_spinner
{
    typeset UI_CNT=0

    while true; do

        (( UI_CNT += 1 ))

        case "${UI_CNT}" in

            1 ) echo -e "|\b\c";;
            2 ) echo -e "/\b\c";;
            3 ) echo -e "-\b\c";;
            4 ) echo -e "\0134\b\c"; UI_CNT=0;;

        esac

        sleep 1
    done

    return "${UI_CNT}"
}

function ui_print_progress_bar
{
    typeset UI_PROGRESS="${1}"
    typeset UI_X="${2}"
    typeset UI_Y="${3}"
    typeset UI_WIDTH="${4}"
    typeset UI_COLOR="${5}"

    #
    # Set progress bar size to maximum, if however the percentage given is below then
    # calculate its actual
    #

    typeset PROGRESS_SIZE="${UI_WIDTH}"
    if [ "${UI_PROGRESS}" -lt 100 ] ; then

        typeset ONE_PERCENT=$(numeric_divide "${UI_WIDTH}" "100")
        PROGRESS_SIZE=$(numeric_multiply "${ONE_PERCENT}" "${UI_PROGRESS}") # Calculate percentage of progress
        PROGRESS_SIZE=$(numeric_round "${PROGRESS_SIZE}" "0")

        if [ ${PROGRESS_SIZE} -le 0 ] ; then

            PROGRESS_SIZE=1

        fi

    fi

    #
    # Print the upper border for the progress bar
    #
    ui_print_line "${UI_X}" "${UI_Y}" "${UI_WIDTH}"


    #
    # Print the progress bar to the appropriate size
    #

    typeset STRING_PADDED=$(printf "%${PROGRESS_SIZE}s" " ")

    terminal_mvaddstr $(( ${UI_Y} + 1 )) "${UI_X}" "${UI_COLOR}${STRING_PADDED}${TERMINAL_NORMAL}"

    #typeset PROGRESS_LEFT=$(( ${UI_WIDTH} - ${PROGRESS_SIZE} ))
    #typeset -R${PROGRESS_LEFT} PROGRESS_LEFT="${UI_PROGRESS}%"
    #addstr "${PROGRESS_LEFT}"


    #mvaddstr $(( ${UI_Y} + 1 )) $(( ${UI_WIDTH} - 5 )) "${UI_COLOR}${UI_PROGRESS}%${TERMINAL_NORMAL}"
    #ui_print_label "${UI_COLOR}${UI_PROGRESS}%${TERMINAL_NORMAL}" $(( ${UI_WIDTH} - 10 )) $(( ${UI_Y} + 1 )) 5 right

#                printf "%${PROGRESS_LEFT}s" "${UI_PROGRESS}%"

    

    #
    # Print the lower border for the progress bar
    #

    ui_print_line "${UI_X}" $(( ${UI_Y} + 2 )) "${UI_WIDTH}"
}

function ui_print_table_header
{
    typeset UI_COLS_SIZE="${1}"
    typeset UI_COLS_VALUES="${2}"
    typeset UI_X="${3}"
    typeset UI_Y="${4}"
    typeset UI_WIDTH="${5}"

    ui_print_line "${UI_X}" "${UI_Y}" "${UI_WIDTH}"

    ui_print_table_row "${UI_COLS_SIZE}" "${UI_COLS_VALUES}" "${UI_X}" $(( ${UI_Y} + 1 )) "${UI_WIDTH}"

    ui_print_line "${UI_X}" $(( ${UI_Y} + 2 )) "${UI_WIDTH}"
}

function ui_print_table_row
{
    typeset UI_COLS_SIZE="${1}"
    typeset UI_COLS_VALUES="${2}"
    typeset UI_X="${3}"
    typeset UI_Y="${4}"
    typeset UI_WIDTH="${5}"

    set -A COL_SIZE_ARR ${UI_COLS_SIZE}
    set -A COL_VALUE_ARR ${UI_COLS_VALUES}

    (( UI_WIDTH -= ((${#COL_SIZE_ARR[*]} * 3) + 1) )) # 2 spaces for every column, one border + one last border


    #
    # Determine space/percentage weighting to apply to the different columns
    #

    typeset ONE_PERCENT=$(numeric_divide "${UI_WIDTH}" "100")
    typeset i=0


    terminal_move "${UI_Y}" "${UI_X}"

    while [ ${i} -lt ${#COL_SIZE_ARR[*]} ] ; do

        typeset UI_PERCENT=$(numeric_multiply "${ONE_PERCENT}" "${COL_SIZE_ARR[$i]}")

        UI_PERCENT=$(numeric_round "${UI_PERCENT}" "0")

        typeset UI_PADDING=$(string_left_justify "${COL_VALUE_ARR[$i]}" "${UI_PERCENT}" | stream_substring 1 ${UI_PERCENT})
        terminal_addstr "| ${UI_PADDING} "


        (( i += 1 ))

    done

    terminal_addstr "|"
}

function ui_paint
{
    #===============================================================================
    #          NAME:  ui_paint
    #   DESCRIPTION:
    #    PARAMETERS:
    #       RETURNS:
    #===============================================================================

    terminal_refresh
}
