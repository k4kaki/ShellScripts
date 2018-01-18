#!/bin/sh
#Dynamically getting value of DATE and appending it to a variable
DATE=`date +"%Y-%m-%d"`
#DATE=2017-11-27

#Appending Running status of server to a variable from command line argument
backend_status=$5

#Checking whether the DATE followed by started string exists or not
/bin/grep -iq "$DATE.*started" $1$3

#Appending Running status to a variable  by checking in the serverlog
log_status=$?

#Making decision by checking the both Running statuses from Backend and ServeLog
if [[ $backend_status -eq 0  &&  $log_status -eq 0 ]];then
#Printing first time stamps of the server when it got started
        echo "SERVER STARTED AT BELOW TIMESTAMP:"
        StartTime=`grep -i "$DATE.*started in" $1$3|awk '{print $1}{print $2}' | xargs`
        echo $StartTime
        #START=`echo $StartTime |cut -d, -f1`
        #END=`date --date "$START CET +1 hours"  '+%Y-%m-%d %H'`
        #sleep 5
        echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
        echo -e "\033[44m  LAST 20 LINES OF SERVER.LOG\e[0m"
        echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
        #sleep 5
        tail -20 $1$3
        echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
        echo -e "\033[44m LAST 20 LINES OF DAC.LOG\e[0m"
        echo "---------------------------------------------------------------------------------------------------------------------------------------------------------"
        #sleep 5
        tail -20 $1$2
        echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
        echo -e "\033[44m ERRORS:\e[0m"
        echo "---------------------------------------------------------------------------------------------------------------------------------------------------------"
        #sleep 5
        IFS=$'\n'
#######################################################################################################################################################################
#Printing the whole log right from started time of today's date and end of the serverlog. And here we have trivial errors mentioned int he error.txt, we are printing
#All the Error messages right from start of the server and ommiting the trivial Error lines which mentioned in the errors.txt.
#######################################################################################################################################################################
#       (for i in $(awk "/$START/,/$END/" $1$3|head -100); do
        (for i in $(tail -30 $1$3); do
        a=0
                for k in `ssh dacpus@jboss90005 cat /home/dacpus/Automation/LINUXPatching/files/errors.txt`;do
                        if echo $i|grep -iq "$k"; then
                                 a=`expr $a + 1`
                                break
                        fi
                done
        if [[ $a == 0 ]]; then
                (for l in `ssh dacpus@jboss90005 cat /home/dacpus/Automation/LINUXPatching/files/critical.txt`;do
                        cric_count=0
                        if echo $i|grep -iq "$l"; then
                                echo $i | `ssh dacpus@jboss90005 "cat >> /home/dacpus/Automation/LINUXPatching/files/most_critical.txt"`
                                cric_count=`expr $cric_count + 1`
                        fi
                done
        if [ $cric_count == 0 ];then
                echo $i #| `ssh dacpus@jboss90005 "cat >> /home/dacpus/Automation/LINUXPatching/normalErrors.txt"`
        fi)
        fi
        done)
else
#This block will be executed if and only if any one of the server status is fail, that means whether server didn;t restart for the day or server status is down from backend.
        echo "From the analysis of the SERVER.LOG `hostname` doesn't restart today"
fi

