#!/bin/bash



echo "generate master slaves"
/root/config/generate-master-slaves.sh $1
echo " "
echo " "
echo "update masters-slaves"
#mv /root/config/slaves-hadoop /opt/hadoop-2.7.3/etc/hadoop/slaves
#mv /root/config/masters /opt/hadoop-2.7.3/etc/hadoop/masters 
#mv /root/config/slaves-spark $SPARK_HOME/conf/slaves
echo " "