usage () { 
  echo "usage: assume -r role -t token -P profile -R region"
}

liststsroles () {
 egrep -v ^# $HOME/.aws/roles
}

unassume () { 
  issilent=$1
  unset token role profile region AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN;
  if [ "$issilent" != "silent" ] && [ "$issilent" != "-s" ]; then
	  echo "Role unassumed"
  fi
  return 0
}

assume () 
{ 
    #Before doing anything else we need to "unassume" any existing roles
    unassume silent
    ROLEREF=${ROLEREF:-"$HOME/.aws/roles"};
    local OPTIND P R r t opt;
    while getopts ":r:t:R:P" opt; do
        case $opt in 
            P) profile=$OPTARG ;;
            r) role=$OPTARG ;;
            t) token=$OPTARG ;;
            R) region=$OPTARG ;;
            \?) echo "Invaid option: $OPTARG" 1>&2 && usage && return 1 ;;
            :) echo "Option $OPTARG requires an arguement" 1>&2 && usage && return 1 ;;
        esac;
    done;
    shift `expr $OPTIND - 1`;
    [ "$role" = "" ] && echo "You must supply a valid role" && usage && return 1;
    if [ ! `echo $role | grep ^arn` ]; then
        if [ ! -s $ROLEREF ]; then
            echo "Invalid role selected: $role";
            return 1;
        fi;
        role=`egrep "^$role[ 	]" $ROLEREF | awk '{print $2}'`;
        [ "$role" = "" ] && echo "You must supply a valid role" && usage && return 1;
    fi;
    [ "$profile" = "" ] && profile=default;
    [ "$region" = "" ] && region=eu-west-1;
    if [ "$token" = "" ]; then
        while true; do
            echo -n "Please enter your MFA code> ";
            read token junk;
            if [ "$token" != "" ]; then
                break;
            fi;
        done;
    fi;
    #echo "DEBUG: roleref: $ROLEREF role: $role token: $token profile: $profile region: $region";
    duration=900;
    if echo "$4" | grep "^[0-9]\{3,4\}$" > /dev/null; then
        duration=$4;
    fi;
    mfa_device="$(aws --profile $profile --region $region iam list-mfa-devices --query MFADevices[0].SerialNumber --output text  )";
    result="$(aws --profile $profile --region $region     sts assume-role --role-arn "$role"     --serial-number "$mfa_device" --role-session-name "`whoami`" --duration-seconds "$duration"     --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text --token-code "$token"   )";
    if [ $? -ne 0 ]; then
        echo "Failed to assume role" 1>&2;
        return 1;
    else
        export AWS_ACCESS_KEY_ID="`echo $result | awk '{ print $1 }'`";
        export AWS_SECRET_ACCESS_KEY="`echo $result | awk '{ print $2 }'`";
        export AWS_SESSION_TOKEN="`echo $result | awk '{ print $3 }'`";
        echo "Role $role assumed";
        return 0;
    fi
}
