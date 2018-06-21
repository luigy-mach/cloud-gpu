#!/bin/bash

file_masters="masters"
file_slaves="slaves"
######################################
echo "						 "
echo "	> generate masters_file"
echo "master" > $file_masters
######################################
echo "	> generate slaves_file"
echo "						 "
var=${1:-2}
cat /dev/null >$file_slaves
for (( i = 1; i < $var+1; i++ )); do
	echo "slave$i" >> $file_slaves
done

cat /dev/null > slaves-hadoop
cat /dev/null > slaves-spark

cat $file_masters $file_slaves >> "./slaves-hadoop"
cat $file_slaves >> "./slaves-spark"

mv slaves-hadoop /opt/hadoop-2.7.3/etc/hadoop/slaves
mv slaves-spark $SPARK_HOME/conf/slaves

echo "** Ahora tienes:  $var slaves hadoop"
cat /opt/hadoop-2.7.3/etc/hadoop/slaves
echo "** Ahora tienes:  $var slaves spark"
cat $SPARK_HOME/conf/slaves
echo "						 "

