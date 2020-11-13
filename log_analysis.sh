#!/bin/bash


PID_THIS_PROCCES="$$"
PID_FILE_THIS_PROCCES="pidfile.lock"
FILE_FIRST_LINE="last_line"
FILE_INFO="info.txt"
TIME_START=""
TIME_END=""
ACCESS_LOG=""
EMAIL=""
LAST_LINE=""
FIRST_LINE=""

echo "checking if a proccess exists..."
sleep 1
if [[ -f "$PID_FILE_THIS_PROCCES"  ]]; then
 echo "Proccess is running ..."
 exit 1
fi

echo "checking command args..."
sleep 1
if [[ $1 == "" ]]; then
 echo "Input email..."
 exit 1
fi 

if [[ $2 == "" ]]; then
 echo "Input access.log ..."
 exit 1
fi

if [[ !  -f $2 ]]; then
 echo "File access log not exist ..."
 exit 1
fi

EMAIL=$1
ACCESS_LOG=$2

echo "$$" > $PID_FILE_THIS_PROCCES

sig_trap () {
 trap "rm -f $PID_FILE_THIS_PROCCES info.txt; exit 1" SIGINT
 trap "rm -f $PID_FILE_THIS_PROCCES" EXIT
}


echo "Start proccess..."
sleep 2

LAST_LINE=$(wc -l  $ACCESS_LOG | awk '{print $1}')

if [[ -f  $FILE_FIRST_LINE && -n $(cat $FILE_FIRST_LINE) ]]; then 
FIRST_LINE=$(cat $FILE_FIRST_LINE)  
else 
FIRST_LINE="1" 
fi

echo "Parse TIME_START and TIME_END..."
sleep 1
TIME_START=$(cat $ACCESS_LOG | sed -n "$FIRST_LINE","$LAST_LINE"p | awk '{print $4 $5}' | sed 's/\[//; s/\]//' | head -n 1)
TIME_END=$(cat $ACCESS_LOG |   sed -n "$FIRST_LINE","$LAST_LINE"p | awk '{print $4 $5}' | sed 's/\[//; s/\]//' | tail -n 1)
 
echo -e "Period: $TIME_START - $TIME_END \n" > $FILE_INFO

echo "Parse logs..."
sleep 1
echo 'Number of requests:  IP:' >> $FILE_INFO
cat $ACCESS_LOG | awk '{print $1}' | sort | uniq -c | sed -e "s/^ *//g" | sed -e "s/ /       /g" | sort -rn | head  >> $FILE_INFO
echo -e '\nNumber of requests:  Requested page:' >> $FILE_INFO
cat $ACCESS_LOG | awk '{print $7}' | sort | uniq -c | sed -e "s/^ *//g" | sed -e "s/ /       /g" | sort -rn | head  >> $FILE_INFO
echo -e '\nNumber of requests:  Response code:' >> $FILE_INFO
cat $ACCESS_LOG | awk '{print $9}' | sort | uniq -c | sed -e "s/^ *//g" | sed -e "s/ /       /g" | sort -rn | head  >> $FILE_INFO


echo "Send info to email: $EMAIL ..."
sleep 1
sendmail $EMAIL < $FILE_INFO

sig_trap

echo "Write last line to file..."
sleep 1
echo $LAST_LINE > $FILE_FIRST_LINE

rm -f $PID_FILE_THIS_PROCCES $FILE_INFO
exit 0

