#!/bin/ksh
#===============================================================================
#
#          FILE:  signal.ksh
# 
#         USAGE:  . ${AB_UNIT_HOME}/lib/process/signal.ksh 
# 
#   DESCRIPTION:  Global constants for inter process signal communication
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Philip Bowditch
#       COMPANY:  Neo Origin Limited
#       VERSION:  1.0
#       CREATED:  13/09/2008 11:50:00 GMT Daylight Time
#      REVISION:  ---
#===============================================================================

#   Signal     Value     Action   Comment
#   -------------------------------------------------------------------------
#   SIGHUP        1       Term    Hangup detected on controlling terminal
#                                     or death of controlling process
#   SIGINT        2       Term    Interrupt from keyboard
#   SIGQUIT       3       Core    Quit from keyboard
#   SIGILL        4       Core    Illegal Instruction
#   SIGABRT       6       Core    Abort signal from abort(3)
#   SIGFPE        8       Core    Floating point exception
#   SIGKILL       9       Term    Kill signal
#   SIGSEGV      11       Core    Invalid memory reference
#   SIGPIPE      13       Term    Broken pipe: write to pipe with no readers
#   SIGALRM      14       Term    Timer signal from alarm(2)
#   SIGTERM      15       Term    Termination signal
#   SIGUSR1   30,10,16    Term    User-defined signal 1
#   SIGUSR2   31,12,17    Term    User-defined signal 2
#   SIGCHLD   20,17,18    Ign     Child stopped or terminated
#   SIGCONT   19,18,25            Continue if stopped
#   SIGSTOP   17,19,23    Stop    Stop process
#   SIGTSTP   18,20,24    Stop    Stop typed at tty
#   SIGTTIN   21,21,26    Stop    tty input for background process
#   SIGTTOU   22,22,27    Stop    tty output for background process

export SIGNAL_EXIT=0                        # EXIT  - Executed before script termination
export SIGNAL_HANGUP=1                      # HUP   - Hangup on death of controlling agent e.g. terminal
export SIGNAL_INTERRUPT=2                   # INT   - Generated by DEL or ^C key
export SIGNAL_QUIT=3                        # QUIT  - Generated by ^\ key, like INT but requests a core dump
export SIGNAL_ILLEGAL_INSTRUCTION=4         # ILL   -
export SIGNAL_ABORT=6                       # ABRT  -
export SIGNAL_FLOATING_POINT_EXCEPTION=8    # FPE   -
export SIGNAL_KILL=9                        # KILL  - Cannot be caught or ignored
export SIGNAL_BUS_ERROR=10                  # BUS   - Bus error
export SIGNAL_SEGMENTATION_VIOLATION=11     # SEGV  - Segmentation violation, invalid memory reference
export SIGNAL_PIPE_NO_READER=13             # PIPE  - Pipeline without a reader
export SIGNAL_TIMER_ALARM=14                # ALRM  -
export SIGNAL_TERMINATE=15                  # TERM  - Terminate the process
export SIGNAL_USER1="30,10,16"              # USR1  - User defined
export SIGNAL_USER2="31,12,17"              # USR2  - User defined
export SIGNAL_CHILD="20,17,18"              # CHLD  - Child process stopped or terminated
export SIGNAL_CONTINUE="19,18,25"           # CONT  - Continue if stopped
export SIGNAL_DEBUG="-"                     # DEBUG - KSH - Executed before each statement in a script
export SIGNAL_ERROR=""                      # ERR   - Executed whenever a command produces a non 0 return code
export SIGNAL_KEYBOARD=""                   # KEYBD - 
