#!/bin/bash

echo -e "\n"

#hdfs namenode -format
hdfs namenode -format -force

echo -e "\n"

$HADOOP_HOME/sbin/start-dfs.sh

echo -e "\n"

$HADOOP_HOME/sbin/start-yarn.sh

echo -e "\n"

