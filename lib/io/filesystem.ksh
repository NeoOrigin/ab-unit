#!/bin/ksh
#===============================================================================
#
#          FILE:  filesystem.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/io/filesystem.ksh 
# 
#   DESCRIPTION:  Used to handle all calls to filesystem level manipulation
#                 such as creating directories, files, getting file system size
#                 etc
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Philip Bowditch
#       COMPANY:  
#       VERSION:  1.0
#       CREATED:  13/09/2008 15:10:47 GMT Daylight Time
#      REVISION:  ---
#===============================================================================


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function filesystem_make_directory
{
    #===============================================================================
    #          NAME:  filesystem_make_directory
    #   DESCRIPTION:  Creates a directory and optionally needed parents (default N)
    #         USAGE:  filesystem_make_directory <filepath> [<checkall:Y>]
    #       RETURNS:  NONE
    #===============================================================================

    typeset -u FILE_AND_PARENTS="${2:-N}"

    typeset FILE_OPTIONS=""

    case "${FILE_AND_PARENTS}" in

        Y | YES ) FILE_OPTIONS="-p"
                  ;;
        *       ) ;;

    esac

    mkdir ${FILE_OPTIONS} "${1}"
}

function filesystem_remove_directory
{
    #===============================================================================
    #          NAME:  filesystem_remove_directory
    #   DESCRIPTION:  Removes an empty directory and optionally its children (default Y)
    #         USAGE:  filesystem_remove_directory <filepath> [<checksubdirs:N>]
    #       RETURNS:  NONE
    #===============================================================================

    typeset -u FILE_AND_SUBS="${2}"

    typeset FILE_OPTIONS="-f"

    case "${FILE_AND_SUBS}" in

        Y | YES ) FILE_OPTIONS="-Rf"
                  ;;
        *       ) ;;

    esac

    rm ${FILE_OPTIONS} "${1}"
}

function filesystem_create_file
{
    #===============================================================================
    #          NAME:  filesystem_create_file
    #   DESCRIPTION:  Creates a blank empty file
    #         USAGE:  filesystem_create_file <filepath>
    #       RETURNS:  NONE
    #===============================================================================

    >| "${1}"
}


function filesystem_remove_file
{
    #===============================================================================
    #          NAME:  filesystem_remove_file
    #   DESCRIPTION:  Removes an existing file/directory
    #         USAGE:  filesystem_remove_file <filepath>
    #       RETURNS:  NONE
    #===============================================================================

    if [ -e "${1}" ] ; then

        rm -Rf "${1}"

    fi
}

function filesystem_truncate_file
{
    #===============================================================================
    #          NAME:  filesystem_truncate_file
    #   DESCRIPTION:  Empties/creates a blank file
    #         USAGE:  filesystem_truncate_file <filepath>
    #       RETURNS:  NONE
    #===============================================================================

    >| "${1}"
}

function filesystem_touch_file
{
    #===============================================================================
    #          NAME:  filesystem_touch_file
    #   DESCRIPTION:  Updates the last modified time for a given file/s
    #         USAGE:  filesystem_touch_file <filename> [...]
    #       RETURNS:  NONE
    #===============================================================================

    touch ${@}
}

function filesystem_append_file
{
    #===============================================================================
    #          NAME:  filesystem_append_file
    #   DESCRIPTION:  Appends data to a file
    #         USAGE:  filesystem_append_file <filename> <data>
    #       RETURNS:  NONE
    #===============================================================================

    printf "%s" "${2}" >> "${1}"
}


function filesystem_basename
{
    #===============================================================================
    #          NAME:  filesystem_basename
    #   DESCRIPTION:  Strips the path from filepath leaving the last file name
    #         USAGE:  filesystem_basename <filepath>
    #       RETURNS:  NONE
    #===============================================================================

    printf "%s\n" "${1##*/}"
}


function filesystem_dirname
{
    #===============================================================================
    #          NAME:  filesystem_dirname
    #   DESCRIPTION:  Strips the filename from filepath leaving the parent path
    #         USAGE:  filesystem_dirname <filepath>
    #       RETURNS:  NONE
    #===============================================================================

    printf "%s\n" "${1%/*}"
}
