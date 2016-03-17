#!/bin/ksh
#===============================================================================
#
#          FILE:  numeric.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/system/numeric.ksh
# 
#   DESCRIPTION:  Utility functions for numeric manipulations
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

function numeric_pad
{
    #===============================================================================
    #          NAME:  numeric_pad
    #   DESCRIPTION:
    #         USAGE:  numeric_pad <num> <size>
    #       RETURNS:
    #===============================================================================

    typeset UTIL_VAL="${1}"
    typeset UTIL_SIZE="${2}"

    if [ ${#UTIL_VAL} -gt ${UTIL_SIZE} ] ; then

        echo "${UTIL_VAL}"

    else

        typeset -Z${UTIL_SIZE} UTIL_END_VAL="${UTIL_VAL}"
        echo "${UTIL_END_VAL}"

    fi
}

function numeric_round
{
    #===============================================================================
    #          NAME:  numeric_round
    #   DESCRIPTION:
    #         USAGE:  numeric_round <value> <amount>
    #       RETURNS:
    #===============================================================================

    typeset UTIL_VAL="${1}"
    typeset UTIL_ROUND_AMT="${2}"

    printf "%.${UTIL_ROUND_AMT}f" "${UTIL_VAL}"
}

function numeric_divide
{
    #==============================================================================
    #          NAME:  numeric_divide
    #   DESCRIPTION:          
    #         USAGE:  numeric_divide <num> <num>
    #       RETURNS:
    #==============================================================================

    typeset UTIL_LEFT="${1}"
    typeset UTIL_RIGHT="${2}"

    if [ "${UTIL_RIGHT}" -eq "0" ] ; then

        echo "ERROR: numeric_divide: divide_by_zero_exception '${UTIL_LEFT} / ${UTIL_RIGHT}'"
        return 1

    fi

    echo "" | awk "{print (${UTIL_LEFT} / ${UTIL_RIGHT})}"
    return 0
}

function numeric_multiply
{
    typeset UTIL_LEFT="${1}"
    typeset UTIL_RIGHT="${2}"

    echo "" | awk "{print (${UTIL_LEFT} * ${UTIL_RIGHT})}"
}

function numeric_add
{
    typeset UTIL_LEFT="${1}"
    typeset UTIL_RIGHT="${2}"

    echo "" | awk "{print (${UTIL_LEFT} + ${UTIL_RIGHT})}"
}

function numeric_subtract
{
    typeset UTIL_LEFT="${1}"
    typeset UTIL_RIGHT="${2}"

    echo "" | awk "{print (${UTIL_LEFT} - ${UTIL_RIGHT})}"
}

function numeric_mod
{
    #===============================================================================
    #          NAME:  numeric_mod
    #   DESCRIPTION:
    #         USAGE:  numeric_mod <num> <num>
    #       RETURNS:
    #===============================================================================

    typeset UTIL_LEFT="${1}"
    typeset UTIL_RIGHT="${2}"

    if [ "${UTIL_RIGHT}" -eq "0" ] ; then

        echo "ERROR: numeric_mod: divide_by_zero_exception '${UTIL_LEFT} % ${UTIL_RIGHT}'"
        return 1

    fi

    echo "" | awk "{print (${UTIL_LEFT} % ${UTIL_RIGHT})}"
}

function numeric_is_equal
{
    typeset MATH_RESULT=$(echo | awk "{if ( ${1} == ${2} ) print \"true\"; else print \"false\"}")
    if [ "${MATH_RESULT}" == "false" ] ; then

        return 1

    fi

    return 0
}

function numeric_is_not_equal
{
    numeric_is_equal "${1}" "${2}"
    if [ ${?} -eq 0 ] ; then

        return 1

    fi

    return 0
}

function numeric_is_less_than
{
    typeset MATH_RESULT=$(echo | awk "{if ( ${1} < ${2} ) print \"true\"; else print \"false\"}")
    if [ "${MATH_RESULT}" == "false" ] ; then

        return 1

    fi

    return 0
}

function numeric_is_greater_than
{
    typeset MATH_RESULT=$(echo | awk "{if ( ${1} > ${2} ) print \"true\"; else print \"false\"}")
    if [ "${MATH_RESULT}" == "false" ] ; then

        return 1

    fi

    return 0
}

function numeric_is_greater_than_equal
{
    numeric_is_less_than "${1}" "${2}"
    if [ ${?} -eq 0 ] ; then

        return 1

    fi

    return 0
}

function numeric_is_less_than_equal
{
    numeric_is_greater_than "${1}" "${2}"
    if [ ${?} -eq 0 ] ; then

        return 1

    fi

    return 0
}

function numeric_strip
{
    #===============================================================================
    #          NAME:  numeric_strip
    #   DESCRIPTION:  Strips all non digits from the input
    #         USAGE:  numeric_strip <num>
    #       RETURNS:
    #===============================================================================

    echo "${1}" | tr -d "[:alpha:][:punct:][:blank:]"
}

function numeric_is_numeric
{
    #===============================================================================
    #          NAME:  numeric_is_numeric
    #   DESCRIPTION:  Returns whether the text passed is a numeric
    #         USAGE:  numeric_is_numeric <num>
    #       RETURNS:
    #===============================================================================

    typeset NUM_VALUE="${1}"
    typeset NUM_VALUE2=$(numeric_strip "${NUM_VALUE}")

    if [ "${NUM_VALUE}" == "${NUM_VALUE2}" ] ; then

        return 0

    fi

    return 1
}
