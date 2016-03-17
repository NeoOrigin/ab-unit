#!/bin/ksh
#===============================================================================
#
#          FILE:  string.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/string.ksh
# 
#   DESCRIPTION:  Core functions to handle string/character/text manipulation
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

#-- INCLUDES -------------------------------------------------------------------
# Libraries used by this script
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

. "${AB_UNIT_HOME}/lib/io/stream.ksh"


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function string_char_count
{
    #===============================================================================
    #          NAME:  string_char_count
    #   DESCRIPTION:  Returns the number of characters input on stdout
    #         USAGE:  string_char_count <text>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    echo "${#1}"
}


function string_line_count
{
    #===============================================================================
    #          NAME:  string_line_count
    #   DESCRIPTION:  Returns the number of lines input on stdout
    #         USAGE:  string_line_count <text>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    echo "${1}" | stream_line_count
}


function string_trim
{
    #===============================================================================
    #          NAME:  string_trim
    #   DESCRIPTION:  Removes all leading and trailing spaces on stdout
    #         USAGE:  string_trim <text>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    echo "${1}" | stream_trim
}


function string_ltrim
{
    #===============================================================================
    #          NAME:  string_ltrim
    #   DESCRIPTION:  Removes all leading spaces on stdout
    #         USAGE:  string_ltrim <text>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    echo "${1}" | stream_ltrim
}


function string_rtrim
{
    #===============================================================================
    #          NAME:  string_rtrim
    #   DESCRIPTION:  Removes all trailing spaces on stdout
    #         USAGE:  string_rtrim <text>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    echo "${1}" | stream_rtrim
}


function string_left_justify
{
    #===============================================================================
    #          NAME:  string_left_justify
    #   DESCRIPTION:  Left justifies a string by a given amount.  Note that if the
    #                 string is greater than the size given it will be output untouched
    #                 else padded with trailing spaces
    #         USAGE:  string_left_justify <text> <size>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    typeset UTIL_VAL="${1}"
    typeset UTIL_SIZE="${2}"

    #
    # Get the number of characters in our item, using this we
    # can determine if we output the value untouched or if we need to justify
    #

    typeset UTIL_CHAR_COUNT=$(string_char_count "${UTIL_VAL}")

    if [ "${UTIL_CHAR_COUNT}" -ge "${UTIL_SIZE}" ] ; then

        echo "${UTIL_VAL}"

    else

        printf "%-${UTIL_SIZE}s" "${UTIL_VAL}"

    fi
}


function string_right_justify
{
    #===============================================================================
    #          NAME:  string_right_justify
    #   DESCRIPTION:  Right justifies a string by a given amount.  Note that if the
    #                 string is greater than the size given it will be output untouched
    #                 else padded with leading spaces
    #         USAGE:  string_right_justify <text> <size>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    typeset UTIL_VAL="${1}"
    typeset UTIL_SIZE="${2}"

    #
    # Get the number of characters in our item, using this we
    # can determine if we output the value untouched or if we need to justify
    #

    typeset UTIL_CHAR_COUNT=$(string_char_count "${UTIL_VAL}")

    if [ "${UTIL_CHAR_COUNT}" -ge "${UTIL_SIZE}" ] ; then

        echo "${UTIL_VAL}"

    else

        printf "%${UTIL_SIZE}s" "${UTIL_VAL}"

    fi
}


function string_to_lowercase
{   
    #===============================================================================
    #          NAME:  string_to_lowercase
    #   DESCRIPTION:  Converts all text to lowercase
    #         USAGE:  string_to_lowercase <text>
    #       RETURNS:  The return code of this operation
    #===============================================================================

    typeset -l UTIL_LOWER="${1}"

    echo "${UTIL_LOWER}"
}


function string_to_uppercase
{
    #===============================================================================
    #          NAME:  string_to_uppercase
    #   DESCRIPTION:  Converts all text to uppercase
    #         USAGE:  string_to_uppercase <text>
    #       RETURNS:  The return code of this operation
    #===============================================================================

    typeset -u UTIL_UPPER="${1}"

    echo "${UTIL_UPPER}"
}


function string_left_truncate
{
    #===============================================================================
    #          NAME:  string_left_truncate
    #   DESCRIPTION:  Left justifies a string and removes any characters from the right
    #                 end of the string that exceed size.
    #         USAGE:  string_left_truncate <text> <size>
    #       RETURNS:  The return code of this operation
    #===============================================================================

    typeset UTIL_VAL="${1}"
    typeset UTIL_SIZE="${2}"

    #
    # Get the number of characters in the string, if the string is smaller than the
    # limit return it else remove those characters
    #
    typeset UTIL_CHAR_COUNT=$(string_char_count "${UTIL_VAL}")

    if [ "${UTIL_CHAR_COUNT}" -le "${UTIL_SIZE}" ] ; then

        echo "${UTIL_VAL}"

    else

        typeset -L${UTIL_SIZE} UTIL_END_VAL="${UTIL_VAL}"

        echo "${UTIL_END_VAL}"

    fi
}


function string_right_truncate
{
    #===============================================================================
    #          NAME:  string_right_truncate
    #   DESCRIPTION:  Right justifies a string and removes any characters from the left
    #                 end that exceed size.
    #    PARAMETERS:  string_right_truncate <text> <size>
    #       RETURNS:  The return code of this operation
    #===============================================================================

    typeset UTIL_VAL="${1}"
    typeset UTIL_SIZE="${2}"

    #
    # Get the number of characters in the string, if less than limit return them
    # else right justify and truncate
    #
    typeset UTIL_CHAR_COUNT=$(string_char_count "${UTIL_VAL}")

    if [ "${UTIL_CHAR_COUNT}" -le "${UTIL_SIZE}" ] ; then

        echo "${UTIL_VAL}"

    else

        typeset -R${UTIL_SIZE} UTIL_END_VAL="${UTIL_VAL}"

        echo "${UTIL_END_VAL}"

    fi
}


function string_word_wrap
{
    #===============================================================================
    #          NAME:  string_word_wrap
    #   DESCRIPTION:  Wraps a string at word boundarys
    #         USAGE:  string_word_wrap <text> <max_width>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    typeset UTIL_TEXT="${1}"
    typeset UTIL_WIDTH="${2}"

    echo "${UTIL_TEXT}" | stream_word_wrap "${UTIL_WIDTH}"
}


function string_char_wrap
{
    #===============================================================================
    #          NAME:  string_char_wrap
    #   DESCRIPTION:  Wraps a string at a character count boundary
    #         USAGE:  string_char_wrap <text> <max_width>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    typeset UTIL_TEXT="${1}"
    typeset UTIL_WIDTH="${2}"

    echo "${UTIL_TEXT}" | stream_line_wrap "${UTIL_WIDTH}"
}


function string_substring
{
    #===============================================================================
    #          NAME:  string_substring
    #   DESCRIPTION:  Returns a subset of the original string
    #         USAGE:  string_substring <text> <start index> <length>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    typeset UTIL_TEXT="${1}"
    typeset UTIL_START="${2}"
    typeset UTIL_LENGTH="${3}"

    echo "${UTIL_TEXT}" | stream_substring "${UTIL_START}" "${UTIL_LENGTH}"
}


function string_split
{
    #===============================================================================
    #          NAME:  string_split
    #   DESCRIPTION:  Returns portions of the original string as cut out by the delimiter
    #                 and field numbers
    #         USAGE:  string_split <text> <delimiter> <fields>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    typeset UTIL_TEXT="${1}"
    typeset UTIL_DELIM="${2}"
    typeset UTIL_FIELDS="${3}"

    echo "${UTIL_TEXT}" | stream_split "${UTIL_DELIM}" "${UTIL_FIELDS}"
}


function string_compare
{
    #===============================================================================
    #          NAME:  string_compare
    #   DESCRIPTION:  Compares two strings, return 0 if equal non zero on differences
    #         USAGE:  string_compare <text> <text2>
    #       RETURNS:  The result of the comparison, 0 if equal, 255(-1) if <text> less than
    #                 <text2>, 1 if <text> is greater than <text2>
    #===============================================================================

    typeset UTIL_TEXT=$( echo "${1}" | sed 's|"|\\"|g')
    typeset UTIL_TEXT2=$(echo "${2}" | sed 's|"|\\"|g')

    #
    # Use inbuilt awk comparison operators
    #
    typeset -i RESULT=$(echo "" | awk "{     if ( \"${UTIL_TEXT}\" < \"${UTIL_TEXT2}\" ) print \"-1\";
                                        else if ( \"${UTIL_TEXT}\" > \"${UTIL_TEXT2}\" ) print \"1\";
                                        else                                             print \"0\"}")

    return ${RESULT}
}


function string_starts_with
{
    #===============================================================================
    #          NAME:  string_starts_with
    #   DESCRIPTION:  Returns whether the string starts with a particular search string
    #         USAGE:  string_starts_with <text> <search_str>
    #       RETURNS:  True/0 if it does, non zero if not
    #===============================================================================

    typeset UTIL_TEXT="${1}"
    typeset UTIL_TEXT2="${2}"
    typeset UTIL_TEXT1=""

    typeset UTIL_TEXT1_COUNT=$(string_char_count "${UTIL_TEXT}" )
    typeset UTIL_TEXT2_COUNT=$(string_char_count "${UTIL_TEXT2}")

    #
    # Return true if not searching for anything
    #
    if [ ${UTIL_TEXT2_COUNT:-0} -le 0 ] ; then

        return 0

    fi

    #
    # Check firstly that the original string has more characters if not then
    # it cannot possibly contain the other string
    #
    if [ ${UTIL_TEXT1_COUNT} -ge ${UTIL_TEXT2_COUNT} ] ; then

        UTIL_TEXT1=$(string_substring "${UTIL_TEXT}" 1 ${UTIL_TEXT2_COUNT})

        string_compare "${UTIL_TEXT1}" "${UTIL_TEXT2}"

    else

        return 1

    fi
}


function string_ends_with
{
    #===============================================================================
    #          NAME:  string_ends_with
    #   DESCRIPTION:  Returns whether the text ends with the search string
    #         USAGE:  string_ends_with <text> <search_str>
    #       RETURNS:  True/0 if it doees, non zero if not
    #===============================================================================

    typeset UTIL_TEXT="${1}"
    typeset UTIL_TEXT2="${2}"
    typeset UTIL_TEXT1=""

    typeset UTIL_TEXT1_COUNT=$(string_char_count "${UTIL_TEXT}" )
    typeset UTIL_TEXT2_COUNT=$(string_char_count "${UTIL_TEXT2}")

    #
    # Return true if not searching for anything
    #
    if [ ${UTIL_TEXT2_COUNT} -le 0 ] ; then

        return 0

    fi

    if [ ${UTIL_TEXT1_COUNT} -ge ${UTIL_TEXT2_COUNT} ] ; then

        typeset UTIL_TEST_START=$(expr 1 + ${UTIL_TEXT1_COUNT} \- ${UTIL_TEXT2_COUNT} )
        UTIL_TEXT1=$(string_substring "${UTIL_TEXT}" ${UTIL_TEST_START} ${UTIL_TEXT2_COUNT})

        string_compare "${UTIL_TEXT1}" "${UTIL_TEXT2}"

    else

        return 1

    fi
}


function string_enclosed_with
{
    #===============================================================================
    #          NAME:  string_enclosed_with
    #   DESCRIPTION:  Returns whether the string starts and ends with the search string
    #         USAGE:  string_enclosed_with <text> <search_str>
    #       RETURNS:  True/0 if it does else non zero
    #===============================================================================

    typeset UTIL_TEXT="${1}"
    typeset UTIL_TEXT2="${2}"

    string_starts_with "${UTIL_TEXT}" "${UTIL_TEXT2}" &&
    string_ends_with   "${UTIL_TEXT}" "${UTIL_TEXT2}"
}


function string_index
{
    #===============================================================================
    #          NAME:  string_index
    #   DESCRIPTION:  Prints the index of the first matching characters within the string
    #                 -1 if not found
    #         USAGE:  string_index <text> <search_str>
    #       RETURNS:  The result of the operation
    #===============================================================================

    typeset UTIL_TEXT="${1}"
    typeset UTIL_SEARCH="${2}"

    typeset UTIL_RESULT=$(echo "${UTIL_TEXT}" | stream_index "${UTIL_SEARCH}" | stream_split "," 2-)

    echo "${UTIL_RESULT:--1}"
}

function string_to_hex
{
    #===============================================================================
    #          NAME:  string_to_hex
    #   DESCRIPTION:  Prints the hexadecimal value of the string
    #         USAGE:  string_to_hex <text>
    #       RETURNS:  The result of the operation
    #===============================================================================

    echo -e "${1}\c" | stream_to_hex
}


function string_to_octal
{
    #===============================================================================
    #          NAME:  string_to_octal
    #   DESCRIPTION:  Prints the octal value of the string
    #         USAGE:  string_to_octal <text>
    #       RETURNS:  The result of the operation
    #===============================================================================

    echo -e "${1}\c" | stream_to_octal
}


function string_replace
{
    #===============================================================================
        #          NAME:  string_replace
        #   DESCRIPTION:  Replaces a string within the text
        #         USAGE:  string_replace <text> <search_str> <replace_str>
        #       RETURNS:  The result of the operation
        #===============================================================================

    typeset UTIL_TEXT="${1}"
    typeset UTIL_TEXT1="${2}"
    typeset UTIL_TEXT2="${3}"

    echo "${UTIL_TEXT}" | stream_replace "${UTIL_TEXT1}" "${UTIL_TEXT2}"
}
