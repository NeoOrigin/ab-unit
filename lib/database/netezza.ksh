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


#---  GLOBALS   ----------------------------------------------------------------
#   DESCRIPTION:  Global variables used by this script
#-------------------------------------------------------------------------------

export NETEZZA_FIELD_DELIMITER="|"
export NETEZZA_LOG_DIR=""


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function nz_run_query
{
    typeset NZ_SQL_COMMAND="${1}"

    shift

    echo -e "\\pset format unaligned\n${NZ_SQL_COMMAND}" | nzsql -t -q -n -F '${NETEZZA_FIELD_DELIMITER}' "${@}"
}

function nz_fast_load
{
    typeset NZ_DATA_FILE="${1}"
    typeset TARGET_TABLE="${2}"

    shift 2

    nzload -t "${TARGET_TABLE}" "${@}" -df "${NZ_DATA_FILE}"
}

function nz_insert_values
{
    typeset NZ_TABLE_NAME="${1}"

    shift

    nz_run_query "INSERT INTO ${NZ_TABLE_NAME} DEFAULT VALUES" "${@}"
}

function nz_insert_select
{
        typeset NZ_TABLE_NAME="${1}"
    typeset NZ_SELECT_STM="${2}"

        shift 2

        nz_run_query "INSERT INTO ${NZ_TABLE_NAME} ${NZ_SELECT_STM}" "${@}"
}

function nz_insert_defaults
{
    typeset NZ_TABLE_NAME="${1}"
        typeset NZ_COL_NAMES="${2}"
        typeset NZ_VOL_VALUES="${3}"

        shift 3

        nz_run_query "INSERT INTO ${NZ_TABLE_NAME} (${NZ_COL_NAMES}) VALUES (${NZ_VOL_VALUES})" "${@}"
}

function nz_gen_stats
{
    typeset NZ_TABLE_NAME="${1}"

    shift

    #
    # If the user has entered a second argument it is for expressing
    # fast statistics, if Y do this else ignore
    #

    if [ ${#} -gt 1 ] ; then

        if [ "${2}" ==  "Y" ] ; then

            shift

            nz_run_query "GENERATE EXPRESS STATISTICS ON ${NZ_TABLE_NAME}" "${@}"
            return ${?}

        fi

    fi

    nz_run_query "GENERATE STATISTICS ON ${NZ_TABLE_NAME}" "${@}"
}

function nz_truncate_table
{
    typeset NZ_TABLE_NAME="${1}"

    shift

    nz_run_query "TRUNCATE TABLE ${NZ_TABLE_NAME}" "${@}"
}

function nz_rename_table
{
    typeset NZ_TABLE_NAME="${1}"
    typeset NZ_TABLE_NAME2="${2}"

    shift 2

    nz_run_query "ALTER TABLE ${NZ_TABLE_NAME} RENAME TO ${NZ_TABLE_NAME2}" "${@}"
}

function nz_rename_column
{
    typeset NZ_TABLE_NAME="${1}"
        typeset NZ_COL_NAME="${2}"
        typeset NZ_COL_NAME2="${3}"

        shift 3

    nz_run_query "ALTER TABLE ${NZ_TABLE_NAME} RENAME COLUMN ${NZ_COL_NAME} TO ${NZ_COL_NAME2}" "${@}"
}

function nz_rename_database
{
    typeset NZ_DATABASE_NAME="${1}"
    typeset NZ_DATABASE_NAME2="${2}"

    shift 2

    nz_run_query "ALTER DATABASE ${NZ_DATABASE_NAME} RENAME TO ${NZ_DATABASE_NAME2}" "${@}"
}

function nz_rename_synonym
{
        typeset NZ_SYNONYM_NAME="${1}"
        typeset NZ_SYNONYM_NAME2="${2}"

        shift 2

        nz_run_query "ALTER SYNONYM ${NZ_SYNONYM_NAME} RENAME TO ${NZ_SYNONYM_NAME2}" "${@}"
}

function nz_rename_view
{
    typeset NZ_VIEW_NAME="${1}"
    typeset NZ_VIEW_NAME2="${2}"

    shift 2

    nz_run_query "ALTER VIEW ${NZ_VIEW_NAME} RENAME TO ${NZ_VIEW_NAME2}" "${@}"
}

function nz_drop_column_default
{
    typeset NZ_TABLE_NAME="${1}"
    typeset NZ_COL_NAME="${2}"

    shift 2

    nz_run_query "ALTER TABLE ${NZ_TABLE_NAME} ALTER ${NZ_COL_NAME} DROP DEFAULT" "${@}"
}

function nz_drop_database
{
    typeset NZ_DATABASE_NAME="${1}"

    shift

    nz_run_query "DROP DATABASE ${NZ_DATABASE_NAME}" "${@}"
}

function nz_drop_sequence
{
        typeset NZ_SEQUENCE_NAME="${1}"

        shift

        nz_run_query "DROP SEQUENCE ${NZ_SEQUENCE_NAME}" "${@}"
}

function nz_drop_synonym
{
    typeset NZ_SYNONYM_NAME="${1}"

    shift

    nz_run_query "DROP SYNONYM ${NZ_SYNONYM_NAME}" "${@}"
}

function nz_drop_table
{
    typeset NZ_TABLE_NAME="${1}"

    shift

    nz_run_query "DROP TABLE ${NZ_TABLE_NAME}" "${@}"
}

function nz_drop_view
{
    typeset NZ_VIEW_NAME="${1}"

    shift

    nz_run_query "DROP VIEW ${NZ_VIEW_NAME}" "${@}"
}

function nz_alter_column_default
{
    typeset NZ_TABLE_NAME="${1}"
    typeset NZ_COL_NAME="${2}"
    typeset NZ_NEW_DEFAULT="${3}"

    shift 3

    nz_run_query "ALTER TABLE ${NZ_TABLE_NAME} ALTER ${NZ_COL_NAME} SET DEFAULT ${NZ_NEW_DEFAULT}" "${@}"
}

function nz_list_objects
{
    nz_run_query "\\d"
}

function nz_list_tables
{
    nz_run_query "\\dt"
}

function nz_list_views
{
    nz_run_query "\\dv"
}

function nz_list_indexes
{
    nz_run_query "\\di"
}

function nz_list_sequences
{
    nz_run_query "\\ds"
}

function nz_list_temp_tables
{
    nz_run_query "\\de"
}

function nz_list_external_tables
{
    nz_run_query "\\dx"
}

function nz_list_synonyms
{
    nz_run_query "\\dy"
}

function nz_list_system_tables
{
    nz_run_query "\\dSt"
}

function nz_list_system_views
{
    nz_run_query "\\dSv"
}

function nz_list_system_indexes
{
    nz_run_query "\\dSi"
}

function nz_list_system_sequences
{
    nz_run_query "\\dSs"
}

function nz_list_system_management_tables
{
    nz_run_query "\\dMt"
}

function nz_list_system_management_views
{
    nz_run_query "\\dMv"
}

function nz_list_system_management_indexes
{
    nz_run_query "\\dMi"
}

function nz_list_system_management_sequences
{
    nz_run_query "\\dMs"
}

function nz_object_exists
{
    typeset -u OBJ_NAME="${1}"

    typeset OBJ_FOUND=$(nz_list_objects | grep "^${OBJ_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${OBJ_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_table_exists
{
    typeset -u TABLE_NAME="${1}"

    typeset TABLE_FOUND=$(nz_list_tables | grep "^${TABLE_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${TABLE_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_view_exists
{
    typeset -u VIEW_NAME="${1}"

    typeset VIEW_FOUND=$(nz_list_views | grep "^${VIEW_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${VIEW_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_index_exists
{
    typeset -u IDX_NAME="${1}"

    typeset IDX_FOUND=$(nz_list_indexes | grep "^${IDX_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${IDX_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_sequence_exists
{
    typeset -u SEQ_NAME="${1}"

    typeset SEQ_FOUND=$(nz_list_sequences | grep "^${SEQ_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${SEQ_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_temp_table_exists
{
    typeset -u TABLE_NAME="${1}"

    typeset TABLE_FOUND=$(nz_list_temp_tables | grep "^${TABLE_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${TABLE_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_external_table_exists
{
    typeset -u TABLE_NAME="${1}"

    typeset TABLE_FOUND=$(nz_list_external_tables | grep "^${TABLE_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${TABLE_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_synonym_exists
{
    typeset -u OBJ_NAME="${1}"

    typeset OBJ_FOUND=$(nz_list_synonyms | grep "^${OBJ_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${OBJ_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_system_table_exists
{
    typeset -u OBJ_NAME="${1}"

    typeset OBJ_FOUND=$(nz_list_system_tables | grep "^${OBJ_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${OBJ_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_system_view_exists
{
    typeset -u OBJ_NAME="${1}"

    typeset OBJ_FOUND=$(nz_list_system_views | grep "^${OBJ_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${OBJ_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_system_index_exists
{
    typeset -u OBJ_NAME="${1}"

    typeset OBJ_FOUND=$(nz_list_system_indexes |  grep "^${OBJ_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${OBJ_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_system_sequence_exists
{
    typeset -u OBJ_NAME="${1}"

    typeset OBJ_FOUND=$(nz_list_system_sequences | grep "^${OBJ_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${OBJ_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_system_management_table_exists
{
    typeset -u OBJ_NAME="${1}"

    typeset OBJ_FOUND=$(nz_list_system_management_tables | grep "^${OBJ_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${OBJ_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_system_management_view_exists
{
    typeset -u OBJ_NAME="${1}"

    typeset OBJ_FOUND=$(nz_list_system_management_views | grep "^${OBJ_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${OBJ_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_system_management_index_exists
{
    typeset -u OBJ_NAME="${1}"

    typeset OBJ_FOUND=$(nz_list_system_management_indexes | grep "^${OBJ_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${OBJ_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_system_management_sequence_exists
{
    typeset -u OBJ_NAME="${1}"

    typeset OBJ_FOUND=$(nz_list_system_management_sequences | grep "^${OBJ_NAME}|" | awk -F'|' '{print $1}')

    if [ -z "${OBJ_FOUND}" ] ; then

        return 1

    fi

    return 0
}

function nz_user_in_group
{
    typeset -u OBJ_NAME="${1}"
    typeset -u GRP_NAME="${2}"

    typeset OBJ_FOUND=$(nz_list_users | awk -F"|" '{print $1 $2}' | grep "^${OBJ_NAME} ${GRP_NAME}$")

    if [ ! -z "${OBJ_FOUND}" ] ; then

        return 0

    fi

    assert "assert_user_member_group" "${3}" "User ${OBJ_NAME} is not a member of the ${GRP_NAME} group"
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
