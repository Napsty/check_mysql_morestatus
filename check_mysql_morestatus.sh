#!/bin/bash
#########################################################################
# Script:	check_mysql_morestatus.sh				#
# Author:	Claudio Kuenzler www.claudiokuenzler.com		#
# Purpose:	Monitor multiple MySQL status variables			#
# History:	20121128 Programmed script				#
#               20130514 Minor changes (PATH and exit)			#
#########################################################################
# Usage: ./check_mysql_morestatus.sh -H dbhost -u dbuser -p dbpass
#########################################################################
help="\ncheck_mysql_morestatus.sh (c) 2012-2013 GNU GPLv2 licence
Usage: check_mysql_morestatus.sh -H host -u username -p password [-w warn_delay] [-c crit_delay]\n
Options:\n-H Hostname or IP of slave server\n-u Username of DB-user\n-p Password of DB-user})\n"

STATE_OK=0		# define the exit code if status is OK
STATE_WARNING=1		# define the exit code if status is Warning (not really used)
STATE_CRITICAL=2	# define the exit code if status is Critical
STATE_UNKNOWN=3		# define the exit code if status is Unknown
PATH=/usr/local/bin:/usr/bin:/bin # Set path
export PATH

for cmd in mysql awk grep [ 
do
 if ! `which ${cmd} &>/dev/null`
 then
  echo "UNKNOWN: This script requires the command '${cmd}' but it does not exist; please check if command exists and PATH is correct"
  exit ${STATE_UNKNOWN}
 fi
done

# Check for people who need help - aren't we all nice ;-)
#########################################################################
if [ "${1}" = "--help" -o "${#}" = "0" ]; 
	then 
	echo -e "${help}";
	exit 1;
fi

# Important given variables for the DB-Connect
#########################################################################
while getopts "H:u:p:h" Input;
do
	case ${Input} in
	H)	host=${OPTARG};;
	u)	user=${OPTARG};;
	p)	password=${OPTARG};;
	h)      echo -e "${help}"; exit 1;;
	\?)	echo "Wrong option given. Please use options -H for host, -P for port, -u for user and -p for password"
		exit 1
		;;
	esac
done

# Connect to the DB server and check for informations
#########################################################################
# Check whether all required arguments were passed in
if [ -z "${host}" -o -z "${user}" -o -z "${password}" ];then
	echo -e "${help}"
	exit ${STATE_UNKNOWN}
fi

# Connect to the DB server and store output in vars
#declare -a Status=(`mysql -h ${host} -u ${user} --password=${password} -N -e "show global status WHERE Variable_name LIKE 'Innodb_rows%' OR Variable_name LIKE 'open%' OR Variable_name LIKE 'Connections'"`)
declare -a Status=(`mysql -h ${host} -u ${user} --password=${password} -N -e "show global status WHERE Variable_name='Com_select' OR Variable_name='Com_insert' OR Variable_name='Com_update' OR Variable_name='Com_delete' OR Variable_name='Connections' OR Variable_name LIKE 'Innodb_rows%' OR Variable_name LIKE 'Open%' OR Variable_name LIKE 'Qcache%'"`)

# Output of different exit states
#########################################################################
output=`echo ${Status[@]} | sed "s/ \([0-9]\)/=\1/g"`

echo "$output|$output"

exit 0
