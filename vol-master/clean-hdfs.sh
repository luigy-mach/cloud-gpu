
#!/bin/bash

var=$(pwd)
wait
cd /app/hadoop/tmp/
wait
rm -rf *
wait
echo "ok 1"
wait
cd /opt/hadoop-2.7.3/hadoop_store/hdfs/namenode
wait
rm -rf *
wait
echo "ok 2"
wait
cd /opt/hadoop-2.7.3/hadoop_store/hdfs/datanode
wait
rm -rf *
wait
echo "ok 3"
cd $var

