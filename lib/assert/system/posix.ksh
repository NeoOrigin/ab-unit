#!/bin/ksh
#===============================================================================
#
#          FILE:  posix.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/assert/system/posix.ksh
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

. "${AB_UNIT_HOME}/lib/assert/assertion.ksh"


#---  GLOBALS   ----------------------------------------------------------------
# Global variables used by this script
#-------------------------------------------------------------------------------


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function assert_files_same
{
    #===============================================================================
    #          NAME:  assert_files_same
    #   DESCRIPTION:  Asserts that two given files have the same contents
    #         USAGE:  assert_files_same <filepath1> <filepath2>
    #       RETURNS:  1 if not identical else 0
    #===============================================================================

    cmp "${1}" "${2}" >/dev/null 2>&1 && return 0

    assert "assert_files_same" "${3}" "Files ${1} and ${2} are not identical"
}

function assert_files_not_same
{
    #===============================================================================
    #          NAME:  assert_files_not_same
    #   DESCRIPTION:  Asserts that two given files do not have the same contents
    #         USAGE:  assert_files_not_same <filepath1> <filepath2>
    #       RETURNS:  1 if identical else 0
    #===============================================================================

    assert_files_same "${1}" "${2}" >/dev/null 2>&1 || return 0

    assert "assert_files_not_same" "${3}" "Files ${1} and ${2} are identical"
}

function assert_variable_defined
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    typeset TEST_VAR=$(env | grep "^${1}=")

    if [ -z "${TEST_VAR}" ] ; then

        assert "assert_variable_defined" "${2}" "${1} is not defined"

    else

        return 0

    fi
}

function assert_variable_not_defined
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_variable_defined "${1}" >/dev/null 2>&1 || return 0

    assert "assert_variable_not_defined" "${2}" "${1} is defined"
}

function assert_object_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -e "${1}" ] ; then

        return 0

    fi

    assert "assert_object_exists" "${2}" "Object ${1} not found"
}

function assert_object_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_object_exists "${1}" >/dev/null 2>&1 || return 0

    assert "assert_object_not_exists" "${2}" "Object ${1} exists"
}

function assert_file_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -f "${1}" ] ; then

        return 0

    fi

    assert "assert_file_exists" "${2}" "File ${1} not found"
}

function assert_file_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_file_exists "${1}" >/dev/null 2>&1 || return 0

    assert "assert_file_not_exists" "${2}" "File ${1} exists"
}

function assert_block_device_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -b "${1}" ] ; then

        return 0

    fi

    assert "assert_block_device_exists" "${2}" "Block device ${1} not found"
}

function assert_block_device_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_block_device_exists "${1}" >/dev/null 2>&1 || return 0

    assert "assert_block_device_not_exists" "${2}" "Block device ${1} exists"
}

function assert_char_device_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -c "${1}" ] ; then

        return 0

    fi

    assert "assert_char_device_exists" "${2}" "Character device ${1} not found"
}

function assert_char_device_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_char_device_exists "${1}" >/dev/null 2>&1 || return 0

    assert "assert_char_device_not_exists" "${2}" "Character device ${1} exists"
}

function assert_directory_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -d "${1}" ] ; then

        return 0

    fi

    assert "assert_directory_exists" "${2}" "Directory ${1} not found"
}

function assert_directory_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_directory_exists "${1}" >/dev/null 2>&1 || return 0

    assert "assert_directory_not_exists" "${2}" "Directory ${1} exists"
}

function assert_pipe_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -p "${1}" ] ; then

        return 0

    fi

    assert "assert_pipe_exists" "${2}" "Pipe ${1} not found"
}

function assert_pipe_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_pipe_exists "${1}" >/dev/null 2>&1 || return 0

    assert "assert_pipe_not_exists" "${2}" "Pipe ${1} exists"
}

function assert_symbolic_link_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    [ -L "${1}" ] && return 0

    assert "assert_symbolic_exists" "${2}" "Symbolic link ${1} not found"
}

function assert_symbolic_link_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_symbolic_link_exists "${1}" >/dev/null 2>&1 || return 0

    assert "assert_symbolic_link_not_exists" "${2}" "Symbolic link ${1} exists"
}

function assert_socket_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    [ -S "${1}" ] && return 0

    assert "assert_socket_exists" "${2}" "Socket ${1} not found"
}

function assert_socket_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_socket_exists "${1}" >/dev/null 2>&1 || return 0

    assert "assert_socket_not_exists" "${2}" "Socket ${1} exists"
}

function assert_setgid_set
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -g "${1}" ] ; then

        return 0

    fi

    assert "assert_setgid_set" "${2}" "Setgid bit not set for ${1}"
}

function assert_setgid_not_set
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_setgid_set "${1}" >/dev/null 2>&1 || return 0

    assert "assert_setgid_not_set" "${2}" "Setgid bit set for ${1}"
}

function assert_sticky_bit_set
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -k "${1}" ] ; then

        return 0

    fi

    assert "assert_sticky_bit_set" "${2}" "Sticky bit not set for ${1}"
}

function assert_sticky_bit_not_set
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_sticky_bit_set "${1}" >/dev/null 2>&1 || return 0

    assert "assert_sticky_bit_not_set" "${2}" "Sticky bit set for ${1}"
}

function assert_setuid_set
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -u "${1}" ] ; then

        return 0

    fi

    assert "assert_setuid_set" "${2}" "Setuid bit not set for ${1}"
}

function assert_setuid_not_set
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_setuid_set "${1}" >/dev/null 2>&1 || return 0

    assert "assert_setuid_not_set" "${2}" "Setuid bit set for ${1}"
}

function assert_string_defined
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -n "${1}" ] ; then

        return 0

    fi

    assert "assert_string_defined" "${2}" "String is not defined"
}

function assert_string_not_defined
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_string_defined "${1}" >/dev/null 2>&1 || return 0

    assert "assert_string_not_defined" "${2}" "String ${1} is defined"
}

function assert_string_null
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -z "${1}" ] ; then

        return 0

    fi

    assert "assert_string_null" "${2}" "String is not null"
}

function assert_string_not_null
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_string_null "${1}" >/dev/null 2>&1 || return 0

    assert "assert_string_not_null" "${2}" "String ${1} is null"
}

function assert_file_is_readable
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -r "${1}" ] ; then

        return 0

    fi

    assert "assert_file_is_readable" "${2}" "File ${1} is not readable"
}

function assert_file_is_not_readable
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_file_is_readable "${1}" >/dev/null 2>&1 || return 0

    assert "assert_file_is_not_readable" "${2}" "File ${1} is readable"
}

function assert_file_is_writable
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -w "${1}" ] ; then

        return 0

    fi

    assert "assert_file_is_writable" "${2}" "File ${1} is not writeable"
}

function assert_file_is_not_writeable
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_file_is_writeable "${1}" >/dev/null 2>&1 || return 0

    assert "assert_file_is_not_writeable" "${2}" "File ${1} is writeable"
}

function assert_file_is_executable
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -x "${1}" ] ; then

        return 0

    fi

    assert "assert_file_is_executable" "${2}" "File ${1} is not executable"
}

function assert_file_is_not_executable
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_file_is_executable "${1}" >/dev/null 2>&1 || return 0

    assert "assert_file_is_not_executable" "${2}" "File ${1} is executable"
}

function assert_directory_is_searchable
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ -x "${1}" ] ; then

        return 0

    fi

    assert "assert_directory_is_searchable" "${2}" "Directory ${1} is not searchable"
}

function assert_directory_is_not_searchable
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_directory_is_searchable "${1}" >/dev/null 2>&1 || return 0

    assert "assert_directory_is_not_searchable" "${2}" "Directory ${1} is searchable"
}

function assert_file_newer_than
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ "${1}" -nt "${2}" ] ; then

        return 0

    fi

    assert "assert_file_newer_than" "${3}" "File ${1} is not newer than ${2}"
}

function assert_file_not_newer_than
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_file_newer_than "${1}" "${2}" >/dev/null 2>&1 || return 0

    assert "assert_file_not_newer_than" "${3}" "File ${1} is newer than ${2}"
}

function assert_file_older_than
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ "${1}" -ot "${2}" ] ; then

        return 0

    fi

    assert "assert_file_older_than" "${2}" "File ${1} is not older than ${2}"
}

function assert_file_not_older_than
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_file_older_than "${1}" "${2}" >/dev/null 2>&1 || return 0

    assert "assert_file_not_older_than" "${3}" "File ${1} is older than ${2}"
}

function assert_file_same_age_as
{
    #===  FUNCTION  ================================================================
    #          NAME:  assert_file_same_age_as
    #   DESCRIPTION:  Compares a file to a second to determine whether it is the same age
    #    PARAMETERS:  1 [Required] The path of the file
    #                 2 [Required] The path of the file to compare to
    #       RETURNS:  
    #===============================================================================

    #
    # Check if file is older than or newer than the second else must be the same
    #

    if [ "${1}" -ot "${2}" ] ; then

        assert "assert_file_same_age_as" "${3}" "File ${1} is older than ${2}"
        return 1

    elif [ "${1}" -nt "${2}" ] ; then

        assert "assert_file_same_age_as" "${3}" "File ${1} is newer than ${2}"
        return 1

    fi

    return 0
}

function assert_file_not_same_age_as
{
    #===  FUNCTION  ================================================================
    #          NAME:  assert_file_not_same_age_as
    #   DESCRIPTION:  
    #    PARAMETERS:  1 [Required] The file to compare
    #                 2 [Required] The file to compare to
    #       RETURNS:  
    #===============================================================================

    assert_file_not_same_age_as "${1}" "${2}" >/dev/null 2>&1 || return 0

    assert "assert_file_not_same_age_as" "${3}" "File ${1} is not the same age as ${2}"
}

function assert_file_innode_match
{
    #===  FUNCTION  ================================================================
    #          NAME:  assert_file_innode_match
    #   DESCRIPTION:  Compares the underlying innodes of two files and returns
    #                 whether these two files point to the same data
    #    PARAMETERS:  1 [Required] The file to compare
    #                 2 [Required] The file to compare to
    #       RETURNS:  0 If a match else 1
    #===============================================================================

    if [ "${1}" -ef "${2}" ] ; then

        return 0

    fi

    assert "assert_file_innode_match" "${3}" "File ${1} is not the same file as ${2}"
}


function assert_file_innode_not_match
{
    #===  FUNCTION  ================================================================
    #          NAME:  assert_file_innode_not_match
    #   DESCRIPTION:  Compares the innodes of two files and returns whether
    #                 these two files point at different underlying data
    #    PARAMETERS:  1 [Required] The file to compare
    #                 2 [Required] The file to compare to
    #       RETURNS:  0 If not a match else 1
    #===============================================================================

    assert_file_innode_match "${1}" "${2}" >/dev/null 2>&1 || return 0

    assert "assert_file_innode_not_match" "${3}" "File ${1} is the same file as ${2}"
}

function assert_string_match_pattern
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ "${1}" = "${2}" ] ; then

        return 0

    fi

    assert "assert_string_match_pattern" "${3}" "String ${1} does not match the pattern '${2}'"
}

function assert_string_not_match_pattern
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_string_match_pattern "${1}" "${2}" >/dev/null 2>&1 || re3turn 0

    assert "assert_string_not_match_pattern" "${3}" "String ${1} matches the pattern '${2}'"
}

function assert_string_eq
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ "${1}"="${2}" ] ; then

        return 0

    fi

    assert "assert_string_eq" "${3}" "String '${1}' is not equal to '${2}'"
}

function assert_string_ne
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_string_eq "${1}" "${2}" >/dev/null 2>&1 || return 0

    assert "assert_string_ne" "${3}" "String '${1}' is equal to string '${2}'"
}

function assert_string_lt
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ "${1}" < "${2}" ] ; then

        return 0

    fi

    assert "assert_string_lt" "${3}" "String '${1}' is not less than '${2}' in locale"
}

function assert_string_ge
{
    #===============================================================================
    #          NAME:  assert_string_ge
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_string_lt "${1}" "${2}" >/dev/null 2>&1 || return 0

    assert "assert_string_ge" "${3}" "String '${1}' is not greater than or equal to string '${2}' in locale"
}

function assert_string_gt
{
    #===============================================================================
    #          NAME:  assert_string_gt
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ "${1}" > "${2}" ] ; then

        return 0

    fi

    assert "assert_string_gt" "${3}" "String '${1}' is not greater than '${2}' in locale"
}

function assert_string_le
{
    #===============================================================================
    #          NAME:  assert_string_le
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_string_gt "${1}" "${2}" >/dev/null 2>&1 || return 0

    assert "assert_string_le" "${3}" "String '${1}' is not less than or equal to string '${2}' in locale"
}

function assert_expression_eq
{
    #===============================================================================
    #          NAME:  assert_expression_eq
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ "${1}" -eq "${2}" ] ; then

        return 0

    fi

    assert "assert_expression_eq" "${3}" "Expression '${1}' is not equal to '${2}'"
}

function assert_expression_ne
{
    #===============================================================================
    #          NAME:  assert_expression_ne
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ "${1}" -ne "${2}" ] ; then

        return 0

    fi

    assert "assert_expression_ne" "${3}" "Expression '${1}' is equal to '${2}'"
}

function assert_expression_lt
{
    #===============================================================================
    #          NAME:  assert_expression_lt
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ "${1}" -lt "${2}" ] ; then

        return 0

    fi

    assert "assert_expression_lt" "${3}" "Expression '${1}' is not less than '${2}'"
}

function assert_expression_ge
{
    #===============================================================================
    #          NAME:  assert_expression_ge
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ "${1}" -ge "${2}" ] ; then

        return 0

    fi

    assert "assert_expression_ge" "${3}" "Expression '${1}' is not greater than or equal to '${2}'"
}

function assert_expression_gt
{
    #===============================================================================
    #          NAME:  assert_expression_gt
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ "${1}" -gt "${2}" ] ; then

        return 0

    fi

    assert "assert_expression_gt" "${3}" "Expression '${1}' is not greater than '${2}'"
}

function assert_expression_le
{
    #===============================================================================
    #          NAME:  assert_expression_le
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    if [ "${1}" -le "${2}" ] ; then

        return 0

    fi

    assert "assert_expression_le" "${3}" "Expression '${1}' is not less than or equal to '${2}'"
}
