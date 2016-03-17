#!/bin/ksh

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

. "${AB_UNIT_HOME}/examples/automation/calc.ksh"
. "${AB_UNIT_HOME}/lib/assert/system/math.ksh"


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function test_multiply_number
{
    typeset TEST_RESULT=$(multiply_number 5 2)

    assert_number_eq 10 "$TEST_RESULT"
}

function test_divide_number
{
    typeset TEST_RESULT=$(divide_number 5 2)

    assert_number_eq 2.5 "$TEST_RESULT"
}
