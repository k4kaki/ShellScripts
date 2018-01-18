#!/bin/sh
recursive()
{
COUNT=0
DATE=`date "+%-m/%-d/%g %H"`
if grep -q "$DATE.*thread*" /websphere/logs/gcmp_webtop_2/SystemOut.log; then
STRING=`grep "$DATE.*thread*" /websphere/logs/gcmp_webtop_2/SystemOut.log | tail -1 | awk -F'thread' '{print $1}'`
COUNT=`echo $STRING | awk '{print $NF}'`
echo $COUNT
return $COUNT
else
echo $COUNT
return $COUNT
fi
}
recursive2()
{
newCNT=$( recursive )
if [ $newCNT -gt 2 ];then
        echo "Restart"
        ssh -t gcmpus@was90258 sudo -u wasadmin /websphere/admin/bin/mgmServer -stop gcmp_webtop_2
        sleep 10
        ssh -t gcmpus@was90258 sudo -u wasadmin /websphere/admin/bin/mgmServer -status gcmp_webtop_2
        sleep 1m
        ssh -t gcmpus@was90258 sudo -u wasadmin /websphere/admin/bin/mgmServer -start gcmp_webtop_2
        sleep 10
        ssh -t gcmpus@was90258 sudo -u wasadmin /websphere/admin/bin/mgmServer -status gcmp_webtop_2
else
        echo "exit 0"
fi
}
CNT=$( recursive )
if [ $CNT -gt 7 ];then
        sleep 1m
        recursive2
else
        echo "It's OK"
fi

