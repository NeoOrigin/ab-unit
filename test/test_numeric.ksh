#!/bin/ksh
#===============================================================================
#
#          FILE:  test_numeric.ksh
#
#         USAGE:  . ${AB_UNIT_HOME}/test/test_numeric.ksh
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

if [[ ! -f "${AB_UNIT_HOME}/lib/system/numeric.ksh" && ! -L "${AB_UNIT_HOME}/lib/system/numeric.ksh" ]] ; then

    echo "ERROR: ${AB_UNIT_HOME}/lib/system/numeric.ksh library could not be located/sourced" >&2
    exit 3

fi

. "${AB_UNIT_HOME}/lib/system/numeric.ksh"


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function test_numeric_pad_with_large_pad
{
    #===============================================================================
    #          NAME:  test_numeric_pad_with_large_pad
    #   DESCRIPTION:  Tests the numeric_pad function
    #===============================================================================

    typeset NUM_RESULT=$(numeric_pad 45 7)

    if [ "${NUM_RESULT}" != "0000045" ] ; then

        echo "ERROR: test_numeric_pad_with_large_pad: numeric_pad produced output of '${NUM_RESULT}' expected '0000045'" >&2
        return 1

    fi

    return 0
}

function test_numeric_pad_with_small_pad
{
    #===============================================================================
    #          NAME:  test_numeric_pad_with_small_pad
    #   DESCRIPTION:  Tests the numeric_pad function with a smaller pad value
    #===============================================================================

    typeset NUM_RESULT=$(numeric_pad 45000 3)

    if [ "${NUM_RESULT}" != "45000" ] ; then

        echo "ERROR: test_numeric_pad_with_small_pad: numeric_pad produced output of '${NUM_RESULT}' expected '45000'" >&2
        return 1

    fi

    return 0
}

function test_numeric_round_down_by_2
{
    #===============================================================================
    #          NAME:  test_numeric_round_down_by_2
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_round "4507.101" "2")

    if [ "${NUM_RESULT}" != "4507.10" ] ; then

        echo "ERROR: test_numeric_round_down_by_2: numeric_round produced output of '${NUM_RESULT}' expected '4507.10'" >&2
        return 1

    fi

    return 0
}

function test_numeric_round_up_by_1
{
    #===============================================================================
    #          NAME:  test_numeric_round_up_by_1
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_round "4507.55" "1")

    if [ "${NUM_RESULT}" != "4507.6" ] ; then

        echo "ERROR: test_numeric_round_up_by_1: numeric_round produced output of '${NUM_RESULT}' expected '4507.6'" >&2
        return 1

    fi

    return 0
}

function test_numeric_round_up_by_0
{
    #===============================================================================
    #          NAME:  test_numeric_round_up_by_0
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_round "4507.55" "0")

    if [ "${NUM_RESULT}" != "4508" ] ; then

        echo "ERROR: test_numeric_round_up_by_0: numeric_round produced output of '${NUM_RESULT}' expected '4508'" >&2
        return 1

    fi

    return 0
}

function test_numeric_round_up_by_minus_1
{
    #===============================================================================
    #          NAME:  test_numeric_round_up_by_minus_1
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_round "4507.55" "-1")

    if [ "${NUM_RESULT}" != "4500" ] ; then

        echo "ERROR: test_numeric_round_up_by_minus_1: numeric_round produced output of '${NUM_RESULT}' expected '4500'" >&2
        return 1

    fi

    return 0
}

function test_numeric_round_0
{
    #===============================================================================
    #          NAME:  test_numeric_round_0
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_round "0" "0")

    if [ "${NUM_RESULT}" != "0" ] ; then

        echo "ERROR: test_numeric_round_0: numeric_round produced output of '${NUM_RESULT}' expected '0'" >&2
         return 1

    fi

    return 0
}

function test_numeric_round_up_cascade
{
    #===============================================================================
    #          NAME:  test_numeric_round_up_cascade
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_round "4507.5445555" "3")

    if [ "${NUM_RESULT}" != "4507.545" ] ; then

        echo "ERROR: test_numeric_round_up_cascade: numeric_round produced output of '${NUM_RESULT}' expected '4507.545'" >&2
        return 1

    fi

    return 0
}

function test_numeric_divide_exact
{
    #===============================================================================
    #          NAME:  test_numeric_divide_exact
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_divide "5.5" "2")

    if [ "${NUM_RESULT}" != "2.75" ] ; then

        echo "ERROR: test_numeric_divide_exact: numeric_divide produced output of '${NUM_RESULT}' expected '2.75'" >&2
        return 1

    fi

    return 0
}

function test_numeric_divide_inexact
{
    #===============================================================================
    #          NAME:  test_numeric_divide_inexact
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_divide "21" "6")

    if [ "${NUM_RESULT}" != "3.5" ] ; then

        echo "ERROR: test_numeric_divide_inexact: numeric_divide produced output of '${NUM_RESULT}' expected '3.5'" >&2
        return 1

    fi

    return 0
}

function test_numeric_divide_by_0
{
    #===============================================================================
    #          NAME:  test_numeric_divide_by_0
    #   DESCRIPTION:
    #===============================================================================

    numeric_divide "21" "0" >/dev/null 2>&1

    if [ ${?} -eq 0 ] ; then

        echo "ERROR: test_numeric_divide_by_0: numeric_divide return code of '0' expected '1'" >&2
        return 1

    fi

    return 0
}

function test_numeric_divide_by_1
{
    #===============================================================================
    #          NAME:  test_numeric_divide_by_1
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_divide "21" "1")

    if [ "${NUM_RESULT}" != "21" ] ; then

        echo "ERROR: test_numeric_divide_by_1: numeric_divide produced output of '${NUM_RESULT}' expected '21'" >&2
        return 1

    fi

    return 0
}

function test_numeric_divide_by_float
{
    #===============================================================================
    #          NAME:  test_numeric_divide_by_float
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_divide "21" "3.5")

    if [ "${NUM_RESULT}" != "6" ] ; then

        echo "ERROR: test_numeric_divide_by_float: numeric_divide produced output of '${NUM_RESULT}' expected '6'" >&2
        return 1

    fi

    return 0
}

function test_numeric_multiply_by_0
{
    #===============================================================================
    #          NAME:  test_numeric_multiply_by_0
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_multiply "21" "0")

    if [ "${NUM_RESULT}" != "0" ] ; then

        echo "ERROR: test_numeric_multiply_by_0: numeric_multiply produced output of '${NUM_RESULT}' expected '0'" >&2
        return 1

    fi

    return 0
}

function test_numeric_multiply_by_1
{
    #===============================================================================
    #          NAME:  test_numeric_multiply_by_1
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_multiply "21.01" "1")

    if [ "${NUM_RESULT}" != "21.01" ] ; then

        echo "ERROR: test_numeric_multiply_by_1: numeric_multiply produced output of '${NUM_RESULT}' expected '21.01'" >&2
        return 1

    fi

    return 0
}

function test_numeric_multiply_by_integer
{
    #===============================================================================
    #          NAME:  test_numeric_multiply_by_integer
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_multiply "21" "3")

    if [ "${NUM_RESULT}" != "63" ] ; then

        echo "ERROR: test_numeric_multiply_by_integer: numeric_multiply produced output of '${NUM_RESULT}' expected '63'" >&2
        return 1

    fi

    return 0
}

function test_numeric_multiply_by_float
{
    #===============================================================================
    #          NAME:  test_numeric_multiply_by_float
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_multiply "7.7" "3.5")

    if [ "${NUM_RESULT}" != "26.95" ] ; then

        echo "ERROR: test_numeric_multiply_by_float: numeric_multiply produced output of '${NUM_RESULT}' expected '26.95'" >&2
        return 1

    fi

    return 0
}

function test_numeric_multiply_by_negative_float
{
    #===============================================================================
    #          NAME:  test_numeric_multiply_by_negative_float
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_multiply "7.7" "-3.5")

    if [ "${NUM_RESULT}" != "-26.95" ] ; then

        echo "ERROR: test_numeric_multiply_by_negative_float: numeric_multiply produced output of '${NUM_RESULT}' expected '-26.95'" >&2
        return 1

    fi

    return 0
}

function test_numeric_add_integers
{
    #===============================================================================
    #          NAME:  test_numeric_add_integers
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_add "7" "55")

    if [ "${NUM_RESULT}" != "62" ] ; then

        echo "ERROR: test_numeric_add_integers: numeric_add produced output of '${NUM_RESULT}' expected '62'" >&2
        return 1

    fi

    return 0
}

function test_numeric_add_floats
{
    #===============================================================================
    #          NAME:  test_numeric_add_floats
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_add "7.66" "22.1175")

    if [ "${NUM_RESULT}" != "29.7775" ] ; then

        echo "ERROR: test_numeric_add_floats: numeric_add produced output of '${NUM_RESULT}' expected '29.7775'" >&2
        return 1

    fi

    return 0
}

function test_numeric_add_0
{
    #===============================================================================
    #          NAME:  test_numeric_add_0
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_add "0" "0")

    if [ "${NUM_RESULT}" != "0" ] ; then

        echo "ERROR: test_numeric_add_0: numeric_add produced output of '${NUM_RESULT}' expected '0'" >&2
        return 1

    fi

    return 0
}

function test_numeric_add_negative_integer
{
    #===============================================================================
    #          NAME:  test_numeric_add_negative_integer
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_add "1" "-22.1175")

    if [ "${NUM_RESULT}" != "-21.1175" ] ; then

        echo "ERROR: test_numeric_add_negative_integer: numeric_add produced output of '${NUM_RESULT}' expected '-21.1175'" >&2
        return 1

    fi

    return 0
}

function test_numeric_subtract_smaller_integer
{
    #===============================================================================
    #          NAME:  test_numeric_subtract_smaller_integer
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_subtract "7" "2")

    if [ "${NUM_RESULT}" != "5" ] ; then

        echo "ERROR: test_numeric_subtract_smaller_integer: numeric_subtract produced output of '${NUM_RESULT}' expected '5'" >&2
        return 1

    fi

    return 0
}

function test_numeric_subtract_larger_integer
{
    #===============================================================================
    #          NAME:  test_numeric_subtract_larger_integer
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_subtract "7" "9")

    if [ "${NUM_RESULT}" != "-2" ] ; then

        echo "ERROR: test_numeric_subtract_larger_integer: numeric_subtract produced output of '${NUM_RESULT}' expected '-2'" >&2
        return 1

    fi

    return 0
}

function test_numeric_subtract_smaller_float
{
    #===============================================================================
    #          NAME:  test_numeric_subtract_smaller_float
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_subtract "7" "2.00002")

    if [ "${NUM_RESULT}" != "4.99998" ] ; then

        echo "ERROR: test_numeric_subtract_smaller_float: numeric_subtract produced output of '${NUM_RESULT}' expected '4.99998'" >&2
        return 1

    fi

    return 0
}

function test_numeric_subtract_larger_integer
{
    #===============================================================================
    #          NAME:  test_numeric_subtract_larger_integer
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_subtract "7" "9")

    if [ "${NUM_RESULT}" != "-2" ] ; then

        echo "ERROR: test_numeric_subtract_larger_integer: numeric_subtract produced output of '${NUM_RESULT}' expected '-2'" >&2
        return 1

    fi

    return 0
}

function test_numeric_subtract_0
{
    #===============================================================================
    #          NAME:  test_numeric_subtract_0
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_subtract "17" "0")

    if [ "${NUM_RESULT}" != "17" ] ; then

        echo "ERROR: test_numeric_subtract_0: numeric_subtract produced output of '${NUM_RESULT}' expected '17'" >&2
        return 1

    fi

    return 0
}

function test_numeric_subtract_negative_integer
{
    #===============================================================================
    #          NAME:  test_numeric_subtract_negative_integer
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_subtract "17" "-22")

    if [ "${NUM_RESULT}" != "39" ] ; then

        echo "ERROR: test_numeric_subtract_negative_integer: numeric_subtract produced output of '${NUM_RESULT}' expected '39'" >&2
        return 1

    fi

    return 0
}

function test_numeric_subtract_negative_float
{
    #===============================================================================
    #          NAME:  test_numeric_subtract_negative_float
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_subtract "17" "-22.75")

    if [ "${NUM_RESULT}" != "39.75" ] ; then

        echo "ERROR: test_numeric_subtract_negative_float: numeric_subtract produced output of '${NUM_RESULT}' expected '39.75'" >&2
        return 1

    fi

    return 0
}

function test_numeric_mod_negative_float
{
    #===============================================================================
    #          NAME:  test_numeric_mod_negative_float
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_mod "15" "-15.00")

    if [ "${NUM_RESULT}" != "0" ] ; then

        echo "ERROR: test_numeric_mod_negative_float: numeric_mod produced output of '${NUM_RESULT}' expected '0'" >&2
        return 1

    fi

    return 0
}

function test_numeric_mod_0
{
    #===============================================================================
    #          NAME:  test_numeric_mod_0
    #   DESCRIPTION:
    #===============================================================================

    numeric_mod "17" "0" >/dev/null 2>&1

    if [ ${?} -eq 0 ] ; then

        echo "ERROR: test_numeric_mod_0: numeric_mod produced return code of '0' expected '1'" >&2
        return 1

    fi

    return 0
}

function test_numeric_mod_1
{
    #===============================================================================
    #          NAME:  test_numeric_mod_1
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_mod "170" "1")

    if [ "${NUM_RESULT}" != "0" ] ; then

        echo "ERROR: test_numeric_mod_1: numeric_mod produced output of '${NUM_RESULT}' expected '0'" >&2
        return 1

    fi

    return 0
}

function test_numeric_mod_negative_integer
{
    #===============================================================================
    #          NAME:  test_numeric_mod_negative_integer
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_mod "22" "-2")

    if [ "${NUM_RESULT}" != "0" ] ; then

        echo "ERROR: test_numeric_mod_negative_integer: numeric_mod produced output of '${NUM_RESULT}' expected '0'" >&2
        return 1

    fi

    return 0
}

function test_numeric_mod_float
{
    #===============================================================================
    #          NAME:  test_numeric_mod_float
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_mod "20" "2.5")

    if [ "${NUM_RESULT}" != "0" ] ; then

        echo "ERROR: test_numeric_mod_float: numeric_mod produced output of '${NUM_RESULT}' expected '0'" >&2
        return 1

    fi

    return 0
}

function test_numeric_mod_larger_integer
{
    #===============================================================================
    #          NAME:  test_numeric_mod_larger_integer
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_mod "20" "40")

    if [ "${NUM_RESULT}" != "20" ] ; then

        echo "ERROR: test_numeric_mod_larger_integer: numeric_mod produced output of '${NUM_RESULT}' expected '20'" >&2
        return 1

    fi

    return 0
}

function test_numeric_mod_exact
{
    #===============================================================================
    #          NAME:  test_numeric_mod_exact
    #   DESCRIPTION:
    #===============================================================================

    typeset NUM_RESULT=$(numeric_mod "20" "20")

    if [ "${NUM_RESULT}" != "0" ] ; then

        echo "ERROR: test_numeric_mod_exact: numeric_mod produced output of '${NUM_RESULT}' expected '0'" >&2
        return 1

    fi

    return 0
}

function test_numeric_is_equal_when_exact
{
    #===============================================================================
    #          NAME:  test_numeric_is_equal_when_exact
    #   DESCRIPTION:
    #===============================================================================

    numeric_is_equal "20" "20"
    typeset NUM_RESULT=$?

    if [ ${NUM_RESULT} -ne 0 ] ; then

        echo "ERROR: test_numeric_is_equal_when_exact: numeric_is_equal returned '${NUM_RESULT}' expected '0'" >&2
        return 1

    fi

    return 0
}

function test_numeric_is_equal_when_different
{
    #===============================================================================
    #          NAME:  test_numeric_is_equal_when_different
    #   DESCRIPTION:
    #===============================================================================

    numeric_is_equal "20" "40"
    typeset NUM_RESULT=$?

    if [ ${NUM_RESULT} -eq 0 ] ; then

        echo "ERROR: test_numeric_is_equal_when_different: numeric_is_equal returned '0' expected '1'" >&2
        return 1

    fi

    return 0
}

function numeric_is_less_than
{
    #===============================================================================
    #          NAME:  numeric_is_less_than
    #   DESCRIPTION:
    #===============================================================================

    typeset MATH_RESULT=$(echo | awk "{if ( ${1} < ${2} ) print \"true\"; else print \"false\"}")
    if [ "${MATH_RESULT}" == "false" ] ; then

        return 1

    else

        return 0

    fi
}

function numeric_is_greater_than
{
    #===============================================================================
    #          NAME:  numeric_is_greater_than
    #   DESCRIPTION:
    #===============================================================================

    typeset MATH_RESULT=$(echo | awk "{if ( ${1} > ${2} ) print \"true\"; else print \"false\"}")
    if [ "${MATH_RESULT}" == "false" ] ; then

        return 1

    else

        return 0

    fi
}

function numeric_is_greater_than_equal
{
    #===============================================================================
    #          NAME:  numeric_is_greater_than_equal
    #   DESCRIPTION:
    #===============================================================================

    numeric_is_less_than "${1}" "${2}"
    if [ ${?} -eq 0 ] ; then

        return 1

    else

        return 0

    fi
}

function numeric_is_less_than_equal
{
    #===============================================================================
    #          NAME:  numeric_is_less_than_equal
    #   DESCRIPTION:
    #===============================================================================

    numeric_is_greater_than "${1}" "${2}"
    if [ ${?} -eq 0 ] ; then

        return 1

    else

        return 0

    fi
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

    else

        return 1

    fi
}


#-- MAIN -----------------------------------------------------------------------
#
#-------------------------------------------------------------------------------

trap "" ERR HUP INT EXIT

    test_numeric_pad_with_large_pad            &&
    test_numeric_pad_with_small_pad            &&
    test_numeric_round_down_by_2               &&
    test_numeric_round_up_by_1                 &&
    test_numeric_round_up_cascade              &&
    test_numeric_round_up_by_0                 &&
    test_numeric_divide_exact                  &&
    test_numeric_divide_inexact                &&
    test_numeric_divide_by_1                   &&
    test_numeric_divide_by_0                   &&
    test_numeric_divide_by_float               &&
    test_numeric_multiply_by_0                 &&
    test_numeric_multiply_by_1                 &&
    test_numeric_multiply_by_integer           &&
    test_numeric_multiply_by_float             &&
    test_numeric_multiply_by_negative_float    &&
    test_numeric_add_integers                  &&
    test_numeric_add_floats                    &&
    test_numeric_add_0                         &&
    test_numeric_add_negative_integer          &&
    test_numeric_subtract_smaller_integer      &&
    test_numeric_subtract_larger_integer       &&
    test_numeric_subtract_smaller_float        &&
    test_numeric_subtract_0                    &&
    test_numeric_subtract_negative_integer     &&
    test_numeric_subtract_negative_float       &&
    test_numeric_mod_negative_float            &&
    test_numeric_mod_0                         &&
    test_numeric_mod_1                         &&
    test_numeric_mod_negative_integer          &&
    test_numeric_mod_float                     &&
    test_numeric_mod_larger_integer            &&
    test_numeric_mod_exact                     &&
    test_numeric_is_equal_when_exact           &&
    test_numeric_is_equal_when_different       &&
    RC=$?

trap - INT QUIT KILL TERM USR1

return $RC
