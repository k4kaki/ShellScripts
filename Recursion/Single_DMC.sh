#!/bin/sh
ARRAY=("jboss90005" "jboss90006" "jboss90007" "jboss90008" "jboss90009" "jboss90010" "jboss90016" "jboss90017" "jboss90068" "jboss90069")
for k in "${ARRAY[@]}" ;do
        /usr/bin/ssh dacpus@$k 'bash -s' < DMC.sh
done

