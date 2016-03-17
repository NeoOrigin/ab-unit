#!/bin/ksh
#===============================================================================
#
#          FILE:  stream.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/io/stream.ksh
# 
#   DESCRIPTION:  Utilities for stream / pipe manipulation
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

#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function stream_line_count
{
    #===============================================================================
    #          NAME:  stream_line_count
    #   DESCRIPTION:  From stdin returns the number of lines input on stdout
    #         USAGE:  stream_line_count
    #       RETURNS:  The return code of the operation
    #===============================================================================

    wc -l | stream_trim
}

function stream_char_count
{
    #===============================================================================
    #          NAME:  stream_char_count
    #   DESCRIPTION:  From stdin returns the number of characters input on stdout
    #         USAGE:  stream_char_count
    #       RETURNS:  The return code of the operation
    #===============================================================================

    wc -c | stream_trim
}

function stream_trim
{
    #===============================================================================
    #          NAME:  stream_trim
    #   DESCRIPTION:  From stdin removes all leading and trailing spaces on stdout
    #         USAGE:  stream_trim
    #       RETURNS:  The return code of the operation
    #===============================================================================

    stream_ltrim | stream_rtrim
}

function stream_ltrim
{
    #===============================================================================
    #          NAME:  stream_ltrim
    #   DESCRIPTION:  From stdin removes all leading spaces (and tabs) on stdout
    #         USAGE:  stream_ltrim
    #       RETURNS:  The return code of the operation
    #===============================================================================

    #
    # Sed expression contains a space and a tab character
    #
    sed 's|^[   ]*||g'
}

function stream_rtrim
{
    #===============================================================================
    #          NAME:  stream_rtrim
    #   DESCRIPTION:  From stdin removes all trailing spaces (and tabs) on stdout
    #         USAGE:  stream_rtrim
    #       RETURNS:  The return code of the operation
    #===============================================================================

    #
    # Sed expression contains a space and a tab character
    #
    sed 's|[    ]*$||g'
}

function stream_word_wrap
{
    #===============================================================================
    #          NAME:  stream_word_wrap
    #   DESCRIPTION:  Wraps a text string at word boundarys
    #         USAGE:  stream_word_wrap <max_width>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    typeset UTIL_WIDTH="${1}"

    fold -s -w ${UTIL_WIDTH}
}

function stream_char_wrap
{
    #===============================================================================
    #          NAME:  stream_char_wrap
    #   DESCRIPTION:  Wraps a text string at character count boundarys
    #         USAGE:  stream_char_wrap <max_width>
    #       RETURNS:  The return code of the operation
    #===============================================================================

    typeset UTIL_WIDTH="${1}"

    fold -w ${UTIL_WIDTH}
}

function stream_substring
{
    #===============================================================================
    #          NAME:  stream_substring
    #   DESCRIPTION:  Performs a substring on lines passed from stdin outputing the
    #                 new string
    #         USAGE:  stream_substring <start> [<length>]
    #       RETURNS:
    #===============================================================================

    typeset UTIL_START="${1}"
    typeset UTIL_LENGTH="${2}"

    #
    # If a length has been specified then turn it from relative length
    # to actual length 
    #

    if [ -n "${UTIL_LENGTH}" ] ; then

        (( UTIL_LENGTH += ( UTIL_START - 1 ) ))

    fi

    cut -c"${UTIL_START}"-"${UTIL_LENGTH}"
}

function stream_index
{
    #===============================================================================
    #          NAME:  stream_index
    #   DESCRIPTION:  Prints the record number and character index of the first matching
    #                 string
    #         USAGE:  stream_index <search_str>
    #       RETURNS:
    #===============================================================================

    typeset UTIL_SEARCH="${1}"

    awk "{
              MY_CHAR = index( \$0, \"${UTIL_SEARCH}\" );
              if (MY_CHAR > 0) {
                    printf( \"%s,%s\\n\", NR, MY_CHAR );
                    exit;
              }
        }"
}

function stream_split
{
    #===============================================================================
    #          NAME:  stream_split
    #   DESCRIPTION:  Prints the fields specified using a delimiter.  Fields can be
    #                 specified as comma delimited field numbers whereby '-' can be used
    #                 to denote all fields onwards and if followed by a number up to that
    #                 field, i.e. UNIX cut command syntax
    #         USAGE:  stream_split <delimiter> [<fields>]
    #       RETURNS:
    #===============================================================================

    typeset UTIL_DELIM="${1}"
    typeset UTIL_FIELDS="${2}"

    if [ -n "${UTIL_FIELDS}" ] ; then

        UTIL_FIELDS="-f${UTIL_FIELDS}"

    fi

    cut -d"${UTIL_DELIM}" ${UTIL_FIELDS}
}

function stream_keep_leading
{
    #===============================================================================
    #          NAME:  stream_keep_leading
    #   DESCRIPTION:  Prints to stdout all newline delimited strings where record number
    #                 is less than or equal to that passed (default 1)
    #         USAGE:  stream_keep_leading [<num:1>]
    #       RETURNS:
    #===============================================================================

    typeset UTIL_HEAD_NO="${1:-1}"

    head -${UTIL_HEAD_NO}
}

function stream_keep_trailing
{
    #===============================================================================
    #          NAME:  stream_keep_trailing
    #   DESCRIPTION:  Prints to stdout all newline delimited strings where reverse
    #                 record number is less than or equal to that passed (default 1)
    #         USAGE:  stream_keep_trailing [<num:1>]
    #       RETURNS:
    #===============================================================================

    typeset UTIL_HEAD_NO="${1:-1}"

    tail -${UTIL_HEAD_NO}
}

function stream_drop_leading
{
    #===============================================================================
    #          NAME:  stream_drop_leading
    #   DESCRIPTION:  Prints to stdout all newline delimited strings where record
    #                 number is greater than that passed (default 1)
    #         USAGE:  stream_drop_leading [<num:1>]
    #       RETURNS:
    #===============================================================================

    typeset UTIL_HEAD_NO="${1:-1}"

    typeset -i i=0
    while read line ; do

        if [ ${i} -ge ${UTIL_HEAD_NO} ] ; then

            echo "${line}"

        fi

        (( i += 1 ))

    done
}

function stream_drop_trailing
{
    #===============================================================================
    #          NAME:  stream_drop_trailing
    #   DESCRIPTION:  Prints to stdout all newline delimited strings where reverse
    #                 record number is greater than that passed (default 1)
    #         USAGE:  stream_drop_trailing [<num:1>]
    #       RETURNS:
    #===============================================================================

    typeset UTIL_HEAD_NO="${1:-1}"
    typeset UTIL_BUFFER=""

    typeset -i i=0
    while read line ; do

        UTIL_BUFFER="${UTIL_BUFFER}${line}\n"

        (( i += 1 ))

    done

    if [ ${i} -gt ${UTIL_HEAD_NO} ] ; then

        echo -e "${UTIL_BUFFER}\c" | head -$(( i - UTIL_HEAD_NO ))

    fi

    UTIL_BUFFER=""
}

function stream_to_hex
{
    #===============================================================================
    #          NAME:  stream_to_hex
    #   DESCRIPTION:  Prints the hexadecimal value of the string given on stdin
    #         USAGE:  stream_to_hex <text>
    #       RETURNS:  The result of the operation
    #===============================================================================

    od -x | stream_drop_trailing 1 | stream_split " " 2- | stream_replace '\n' ' '
}

function stream_to_octal
{
    #===============================================================================
    #          NAME:  stream_to_octal
    #   DESCRIPTION:  Prints the octal value of the string given on stdin
    #         USAGE:  stream_to_octal <text>
    #       RETURNS:  The result of the operation
    #===============================================================================

    od -b | stream_drop_trailing 1 | stream_split " " 2- | stream_replace '\n' ' '
}

function stream_replace
{
    #===============================================================================
    #          NAME:  stream_replace
    #   DESCRIPTION:  Replace a string with a given string
    #         USAGE:  stream_replace <search_str> <replace_str>
    #       RETURNS:  The result of the operation
    #===============================================================================

    typeset UTIL_TEXT1="${1}"
    typeset UTIL_TEXT2="${2}"

    tr "${UTIL_TEXT1}" "${UTIL_TEXT2}"
}
