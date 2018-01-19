#!/bin/sh
permStatus()
{
if [ $1 == 10 ];then
echo "OK"
else
echo "NOK"
fi
}
sh SingleDMC.sh | grep "\bAHO\b" | grep -v bak | grep -n AHO > tempPerm.txt
(a=0
while read p;do
        i="drwxrws---"
        j="jboss"
        k="dacpgr"
        if echo $p | grep -q $i.*$j.*$k ;then
                a=`expr $a + 1 `
                fi
done < tempPerm.txt
permStatus $a)

