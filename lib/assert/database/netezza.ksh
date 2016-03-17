#!/bin/ksh
#===============================================================================
#
#          FILE:  netezza.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/assert/database/netezza.ksh
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
#   DESCRIPTION:  
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
. "${AB_UNIT_HOME}/lib/database/netezza.ksh"


#---  GLOBALS   ----------------------------------------------------------------
#   DESCRIPTION:  Global variables used by this script
#-------------------------------------------------------------------------------

#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function assert_nz_object_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_object_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_object_exists" "${2}" "Object ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_object_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_object_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_object_not_exists" "${2}" "Object ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_table_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_table_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_table_exists" "${2}" "Table ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_table_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_table_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_table_not_exists" "${2}" "Table ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_view_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_view_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_view_exists" "${2}" "View ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_view_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_view_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_view_not_exists" "${2}" "View ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_index_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_index_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_index_exists" "${2}" "Index ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_index_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_index_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_index_not_exists" "${2}" "Index ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_sequence_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_sequence_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_sequence_exists" "${2}" "Sequence ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_sequence_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_sequence_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_sequence_not_exists" "${2}" "Sequence ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_temp_table_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_temp_table_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_temp_table_exists" "${2}" "Temporary table ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_temp_table_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_temp_table_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_temp_table_not_exists" "${2}" "Temporary table ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_external_table_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_external_table_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_external_table_exists" "${2}" "External table ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_external_table_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_external_table_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_external_table_not_exists" "${2}" "External table ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_synonym_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_synonym_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_synonym_exists" "${2}" "Synonym ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_synonym_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_synonym_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_synonym_not_exists" "${2}" "Synonym ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_table_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_system_table_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_system_table_exists" "${2}" "System table ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_table_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_system_table_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_system_table_not_exists" "${2}" "System table ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_view_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_system_view_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_system_view_exists" "${2}" "System view ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_view_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_system_view_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_system_view_not_exists" "${2}" "System view ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_index_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_system_index_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_system_index_exists" "${2}" "System index ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_index_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_system_index_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_system_index_not_exists" "${2}" "System index ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_sequence_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_system_sequence_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_system_sequence_exists" "${2}" "System sequence ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_sequence_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_system_sequence_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_system_sequence_not_exists" "${2}" "System sequence ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_management_table_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_system_management_table_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_system_management_table_exists" "${2}" "System management table ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_management_table_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_system_management_table_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_system_management_table_not_exists" "${2}" "System management table ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_management_view_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_system_management_view_exists "${1}"
    
    if [ ${?} -ne 0 ] ; then
    
        assert "assert_nz_system_management_view_exists" "${2}" "System management view ${1} does not exist"
        return 1
    
    else
    
        return 0
    
    fi
}

function assert_nz_system_management_view_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_system_management_view_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_system_management_view_not_exists" "${2}" "System management view ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_management_index_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_system_management_index_exists "${1}"
    
    if [ ${?} -ne 0 ] ; then
    
        assert "assert_nz_system_management_index_exists" "${2}" "System management index ${1} does not exist"
        return 1
    
    else
    
        return 0
    
    fi
}

function assert_nz_system_management_index_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_system_management_index_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_system_management_index_not_exists" "${2}" "System management index ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_management_sequence_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    nz_system_management_sequence_exists "${1}"

    if [ ${?} -ne 0 ] ; then

        assert "assert_nz_system_management_sequence_exists" "${2}" "System management sequence ${1} does not exist"
        return 1

    else

        return 0

    fi
}

function assert_nz_system_management_sequence_not_exists
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_system_management_sequence_exists "${1}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_system_management_sequence_not_exists" "${2}" "System management sequence ${1} exists"
        return 1

    else

        return 0

    fi
}

function assert_nz_user_member_group
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    typeset -u OBJ_NAME="${1}"
    typeset -u GRP_NAME="${2}"

    typeset OBJ_FOUND=$(nzsql -q -n -c "\\dU" | awk -F"|" '{print $1 $2}' | grep "^${OBJ_NAME} ${GRP_NAME}$")

    if [ -z "${OBJ_FOUND}" ] ; then

        assert "assert_nz_user_member_group" "${3}" "User ${OBJ_NAME} is not a member of the ${GRP_NAME} group"
        return 1

    else

        return 0

    fi
}

function assert_nz_user_not_member_group
{
    #===============================================================================
    #          NAME:  
    #   DESCRIPTION:  
    #         USAGE:  
    #       RETURNS:  
    #===============================================================================

    assert_nz_user_member_group "${1}" "${2}" 2>&1 >/dev/null

    if [ $? -eq 0 ] ; then

        assert "assert_nz_user_not_member_group" "${3}" "User ${OBJ_NAME} is a member of the ${GRP_NAME} group"
        return 1

    else

        return 0

    fi
}

 #\dp <name>      list user permissions
 #\dpu <name>     list permissions granted to a user
 #\dpg <name>     list permissions granted to a group
 #\dgp <name>     list grant permissions for a user
 #\dgpu <name>    list grant permissions granted to a user
 #\dgpg <name>    list grant permissions granted to a group
 #\d{u}           list users
 #\d{g|G|Gr}      list groups/Group Users/Resource Group Users
 #\da             list aggregates
 #\dd [object]    list comment for object
 #\df             list functions
 #\do             list operators
 #\dT             list data types
