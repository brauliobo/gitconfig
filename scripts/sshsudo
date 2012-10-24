#!/bin/bash 
#
# sshsudo: 1.0
# Author: jiwu.liu@gmail.com
#
#   The script executes sudo command on one or more remote computers. 
# Its arguments are the names to remote sudoers and remote computers.
# The script read the password from the standard input, which should 
# be the same for all sudoer accounts. No password is explicitly shown 
# in the terminal or logged to files.
#   If the command is a local shell script, use '-r' to copy it to 
# the remote computers to execute. A temporary script file will be 
# automatically created for this purpose.
# 
#
# TO DO: It can not execute a command that use the shell special charaters 
#        on the remote computer, such as & ; ! *, because all arguments
#        are wrapped with ''. That means, all special characters have only 
#        literal meanings. In the case when they are needed, use a script 
#        instead of a command. 
# 
# Example:sshsudo foo@bar.net apt-get check 
#         sshsudo -r foo@bar.net myscript.sh

 
usage()
{
    local ProgName=$1;
    echo "Usage: $ProgName -r -v [-u user] AccountList  Command [Arguments]"
    echo "       -u Set the default user unless it is given within remote account list"
    echo "       -r Copy the command(usually the path to local script) to remote computers before execution"
    echo "       -v Verbose output"
    echo "       AccountList: [user1@]computer1,[user2@]computer2,[user3@]computer3,..." 
    echo "                    or the name to file which contains accounts(user@computer) in separate lines"
    echo "       Command: The Command/Script to be executed"
    echo "       Arguments: All arguments to be passed to command."
}

pipewrap()
{
    # This function reads in the input from a terminal and output the same. 
    # The only purpose is to insert PASSWORD for "sudo -S" command.
    # After initially insert the password, it simply copy input from terminal 
    # and send it to ssh command directly
    echo $1  # which is password
    local lockFile=$2;
    while true; do
        # The function will exit when output pipe is closed, 
        if [ ! -e $lockFile ]; then
            return 0
        fi
        # i.e., the ssh
        read -t 1 line
        if [ $? -eq 0 ]; then 
            # successfully read
            echo $line
        fi
    done
}

runsudo ()
{
    # receive its arguments
    local ACCOUNT=$1;
    local PASSWORD=$2;
    local COMMAND=$3;
    local ARGUMENTS=$4;
    local DEFAULTUSER=$5;
    local COPY=$6;
    local VERBOSE=$7;

    # Parse account which has the form user@computer.domain
    local REMOTEUSER=${ACCOUNT%%@*}
    local REMOTECOMPUTER=${ACCOUNT#*@}
    local REMOTESCRIPT=
    local REMOTECOMMAND=$COMMAND
    if [ $REMOTEUSER = $REMOTECOMPUTER ]; then
        # There is no @, i.e., only computer name is given
        REMOTEUSER=$DEFAULTUSER
    fi
    echo =========================${REMOTEUSER}@$REMOTECOMPUTER: sudo $COMMAND $ARGUMENTS
    if [ $COPY -ne 0 ]; then
        # Make a script + seconds since 1970-01-01
        REMOTESCRIPT=/tmp/$COMMAND`date +%s`
        if [ $VERBOSE -ne 0 ]; then 
            echo $REMOTECOMPUTER: Secure copy \"$COMMAND\" to \"$REMOTESCRIPT\"
        fi
        # Copy to remote computer. Quote target name on the remote computer for script name 
        # that contains " "
        sshpass -p "$PASSWORD" scp "$COMMAND" "$REMOTEUSER@$REMOTECOMPUTER:'$REMOTESCRIPT'"
        REMOTECOMMAND=$REMOTESCRIPT
    fi

    # Assume we are lucky, result is fine. 
    local RES=DONE
    # Invalidate the sudo timestamp. Simplify the situation. Henceforth sudo always ask for a password 
    sshpass -p "$PASSWORD" ssh "$REMOTEUSER@$REMOTECOMPUTER" "sudo -K"

    # Use lock file to inform pipewrap function to exit. 
    local lockFile=`mktemp`
    eval pipewrap '$PASSWORD' '$lockFile' | (sshpass -p "$PASSWORD" ssh  "$REMOTEUSER@$REMOTECOMPUTER" "sudo -S '$REMOTECOMMAND' $ARGUMENTS"; rm "$lockFile")

    if [ $? -ne 0 ]; then
       RES=FAILED 
    fi
    if [ $COPY -ne 0 ]; then
        sshpass -p $PASSWORD ssh "$REMOTEUSER@$REMOTECOMPUTER" rm \'$REMOTESCRIPT\'
        if [ $VERBOSE -ne 0 ]; then 
            echo Remove temporary script  \"$REMOTESCRIPT\" at [$REMOTECOMPUTER]
        fi
    fi
    echo ----------------------------------${RES}!!----------------------------------------
}


#=====================================Main Script========================================
#
# Set default values for variables 
COMMAND=
ARGUMENTS=
COPY=0
VERBOSE=0
ACCOUNTLIST=
DEFAULTUSER=$USER

# Parse the command line arguments with '-'
while getopts u:hrv o ; do
    case "$o" in
        [?])  usage $0 
              exit 1;;
        h)    usage $0 
              exit 0;;
        u)  DEFAULTUSER=$OPTARG;;
        v)  VERBOSE=1;;
        r)  COPY=1;;
    esac
done

# Read the rest command line arguments
if [ $(($#-$OPTIND+1)) -lt 2 ]; then
    echo Error: Account list and command have to be in the arguments
    usage $0
    exit 4
fi

shift $(($OPTIND-1))
ACCOUNTLIST=$1
shift
COMMAND=$1
shift
for PARAM; do
    ARGUMENTS=$ARGUMENTS\'$PARAM\'" "
done

# Check the validity of the script command if remote copy is needed
if [ $COPY -ne 0 ]; then
    if [ ! -e "$COMMAND" ]; then
        echo  \"$COMMAND\" does not exist.
        exit 3
    fi
    if [ ! -x "$COMMAND" ]; then
        echo \"$COMMAND\" can not be executed. 
        exit 3
    fi
fi
    
# Read in the password from the STDIN
read -s -p "Please enter your password:" PASSWORD
echo 

# Start running
if [ -e $ACCOUNTLIST ]; then # read accounts from a file
    for ACCOUNT in `cat $ACCOUNTLIST`; do
        runsudo "$ACCOUNT" "$PASSWORD" "$COMMAND" "$ARGUMENTS" "$DEFAULTUSER" "$COPY" "$VERBOSE";
    done

else # ACCOUNTLIST is a comma separated list of user@computer strings.
    # Change the internal separation field. 
    IFS=,
    for ACCOUNT in $ACCOUNTLIST; do
        runsudo "$ACCOUNT" "$PASSWORD" "$COMMAND" "$ARGUMENTS" "$DEFAULTUSER" "$COPY" "$VERBOSE";
    done
fi
#EOF
