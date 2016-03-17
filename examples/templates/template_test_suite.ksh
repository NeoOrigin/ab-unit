#!/bin/ksh
#===============================================================================
#
#          FILE:  template_test_suite.ksh
#
#         USAGE:  test_runner.ksh ./template_test_suite.ksh
#
#   DESCRIPTION:  A brief description of the test to be run
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  John Smith, john.smith@my_company.com
#       COMPANY:  My Company PLC
#       VERSION:  1.0
#       CREATED:  21/10/2008 21:14:58 GMT Daylight Time
#      REVISION:  ---
#
#===============================================================================

#---  INCLUDES  ----------------------------------------------------------------
#   DESCRIPTION: Defines the external scripts used by this script
#-------------------------------------------------------------------------------


#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function setup_test
{
	#===============================================================================
	#          NAME:  setup_test
	#   DESCRIPTION:  Core setup function called once before any tests are ran
	#    PARAMETERS:  NONE
	#       RETURNS:  NONE
	#===============================================================================

    :
}


function teardown_test
{
	#===============================================================================
	#          NAME:  teardown_test
	#   DESCRIPTION:  Core teardown function called after each test is ran
	#    PARAMETERS:  NONE
	#       RETURNS:  NONE
	#===============================================================================

    :
}


function test_my_test
{
	#===============================================================================
	#          NAME:  test_my_test
	#   DESCRIPTION:  A brief description of the test function
	#    PARAMETERS:  1 [Required] description, 2 [Optional] description
	#       RETURNS:  NONE
	#===============================================================================
	test_something

	assert_something
}


#-- MAIN -----------------------------------------------------------------------
#  If not running from within the test_runner this allows this test to be run
#  individually from the command line
#-------------------------------------------------------------------------------

if [ -z "${TEST_RUNNER_RUNNING}" ] ; then

	"${AB_UNIT_HOME}/bin/test_runner.ksh" "${@}"

fi
