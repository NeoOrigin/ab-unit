#!/bin/ksh

#-- FUNCTIONS ------------------------------------------------------------------
# Function definitions for external use
#-------------------------------------------------------------------------------

function multiply_number
{
    echo | awk "{print ${1} * ${2}}"
}

function divide_number
{
    echo | awk "{print ${1} / ${2}}"
}
