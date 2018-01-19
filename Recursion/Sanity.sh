#!/bin/sh
#This variable used for the order output of the server status at end of the whole Sanity checks
z=0

######################################################################################################################################################################
#Below looping through all the command line arguments
#######################################################################################################################################################################
if [ -n "$1" ];then

for var in "$@"
do
#Extracting all the server Details from DARE.txt, extracting details such as username, URL, lognames, alias_name_of_each server as well
   if  grep -q $var /home/dacpus/Automation/LINUXPatching/files/DARE.txt ; then
        usrname=`grep $var /home/dacpus/Automation/LINUXPatching/files/DARE.txt|awk '{print $2}'`
        logpath=`grep $var /home/dacpus/Automation/LINUXPatching/files/DARE.txt|awk '{print $4}'`
        log1name=`grep $var /home/dacpus/Automation/LINUXPatching/files/DARE.txt|awk '{print $5}'`
        log2name=`grep $var /home/dacpus/Automation/LINUXPatching/files/DARE.txt|awk '{print $6}'`
        alias_name=`grep $var /home/dacpus/Automation/LINUXPatching/files/DARE.txt|awk '{print $7}'`
        link=`grep $var /home/dacpus/Automation/LINUXPatching/files/DARE.txt|awk '{print $8}'`
#Checking the Running status of the each server in the el1629 host(From backend)
        ssh -t id849196@el1629  sudo -u jbossadmin /jon/admin/bin/appOperations.sh -s $alias_name -o status|grep -iq "is running and started successfully"
#Appending status of the above comand to a variable
        bach_stat=$?
        echo "SANITY FOR THE HOST:"
        echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\033[41m $var \e[0m"
        echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
#Using the status code from above variable appending Running/Down status to a variable
        if [ $bach_stat -eq 0 ]; then
        echo -e "From backend \033[44m $var \e[0m is \033[1;92m  running and started successfully \e[0m"
        echo "------------------------------------------------------"
        curr_satus="\033[1;92m  RUNNING \e[0m"
        else
        echo -e "From backend \033[44m  $var \e[0m is \033[1;91m   NOT UP \e[0m and \033[1;91m  NOT RUNNING \e[0m"
        curr_satus="\033[1;91m NOT RUNNING \e[0m"
        echo "------------------------------------------------------"
        fi
#Calling the script with command line arguments
        ssh $usrname@$var 'bash -s' < /home/dacpus/Automation/LINUXPatching/scripts/sanitycheck.sh $logpath $log1name $log2name $link $bach_stat
        if [[ $z == 0 ]]; then
        echo "-----------------------------------------------------------------------------------------------------------------------------------------------" > files/up.txt
        echo -e " \033[1;91m $var \e[0m : \033[4;37m  $link  \e[0m $curr_satus" >> files/up.txt
        else
        echo "-----------------------------------------------------------------------------------------------------------------------------------------------" >> files/up.txt
        echo -e  "\033[1;91m  $var \e[0m : \033[4;37m  $link  \e[0m $curr_satus" >> files/up.txt
        fi
        z=`expr $z + 1`
        w=`cat /home/dacpus/Automation/LINUXPatching/files/most_critical.txt | wc -l`
        if [[ $w -lt 2 ]];then
                echo -e "\033[1;92m NO CRITICAL ERRORS FOUND  \e[0m"
        else
                echo -e "\033[1;91m FIND THE BELOW CRITICAL ERRORS \e[0m"
                cat /home/dacpus/Automation/LINUXPatching/files/most_critical.txt
                echo "" > /home/dacpus/Automation/LINUXPatching/files/most_critical.txt
        fi
#       s=`cat /home/dacpus/Automation/LINUXPatching/normalErrors.txt | wc -l`
#       if [[ $s -gt 2 ]];then
#               echo -e "\033[1;92m OTHERS ERRORS FOUND  \e[0m"
#               cat /home/dacpus/Automation/LINUXPatching/normalErrors.txt
#               echo " " > /home/dacpus/Automation/LINUXPatching/normalErrors.txt
#       fi
 else
        echo  -e "\033[1;91m THE SERVER NAME IS INVALID :\" $var \" \e[0m"
fi

done
#Printing all the servers with their respective URLs and Running status.
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "These are all the servers which under gone Sanity checks"
/bin/cat files/up.txt
else
        echo "No Server Names passed as Arguments::"
        exit 2
fi

