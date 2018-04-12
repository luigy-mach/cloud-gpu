#!/bin/bash
source ~/scripts/common.sh

#if $($HADOOP_HOME/bin/hdfs dfs -test -d /data); then
#  $HADOOP_HOME/bin/hdfs dfs -rm -r /data
#fi
#if $($HADOOP_HOME/bin/hdfs dfs -test -d /output); then
#  $HADOOP_HOME/bin/hdfs dfs -rm -r /output
#fi

$SPARK_HOME/sbin/stop-all.sh
$HADOOP_HOME/sbin/stop-dfs.sh
$HADOOP_HOME/sbin/stop-yarn.sh
