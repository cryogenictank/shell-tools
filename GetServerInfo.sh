#!/bin/bash
#
# GetServerInfo
#
# Created by Jean Silva - cryogenictank@gmail.com
# June, the 7th, 2019
#
#
# Requires: yajl-tools (json_reformat)
#           gnuplot
#
#
# Set Environment variables

# Time stamp for the log file

    TIMESTAMP=`date '+%Y%m%d_%H%M%S'`

# Log file

    LOG_FILE=GetServerInfo_${TIMESTAMP}

#Set the polling interval

    POL_INTERVAL=1

# Set the time span live in seconds

    TIME_SPAN=60

# Endtime of the loop is the current UTC time in seconds + TIME_SPAN

    ENDTIME=$(( $(date +%s) + TIME_SPAN ))

# Run while current time is lower than ENDTIME

    while [ $(date +%s) -lt $ENDTIME ]; do

          echo "Fetching rippled server_info: $(( ENDTIME - $(date +%s) )) seconds to finish "

      curl -s -X POST -d '{ "method": "server_info", "params": [ {} ] }' http://s1.ripple.com:51234 | \
      json_reformat | egrep '\"time\"\:\ \"|\"seq\"\:|\"status\"\:' | egrep 'time|seq' | \
      sed 's/^.*\:\ //g;s/\,//g' | sed ':a;N;$!ba;s/\n/,/g' | sed 's/ /,/g;s/"//g' >> ${LOG_FILE}.log

          sleep ${POL_INTERVAL}

    done

# Generate a 2 columns csv file from the log file
#
    echo "Generating a two columns csv file from the log file, filtering only the first seq number occurrence "

cat ${LOG_FILE}.log | awk -F, '{print $2","$3}' | sed 's/,/\ /g' | uniq -f1 > ${LOG_FILE}.csv
