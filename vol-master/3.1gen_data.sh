#!/bin/bash


OLDDIR=$(pwd)


dirMountMaster="/root/mount-master"
source $dirMountMaster/common.sh

#mkdir -p timings/

# HDFS won't let you overwrite files/directories
#if $($HADOOP_HOME/bin/hdfs dfs -test -d /data); then
#  $HADOOP_HOME/bin/hdfs dfs -rm -r /data
#fi
#if $($HADOOP_HOME/bin/hdfs dfs -test -d /output); then
#  $HADOOP_HOME/bin/hdfs dfs -rm -r /output
#fi
#$HADOOP_HOME/bin/hdfs dfs -mkdir /data
#$HADOOP_HOME/bin/hdfs dfs -mkdir /output


cd $dirMountMaster/scalaDataGenerator

if $($HADOOP_HOME/bin/hdfs dfs -test -d /data); then
  $HADOOP_HOME/bin/hdfs dfs -rm -r /data
fi
if $($HADOOP_HOME/bin/hdfs dfs -test -d /output); then
  $HADOOP_HOME/bin/hdfs dfs -rm -r /output
fi


$HADOOP_HOME/bin/hdfs dfs -mkdir /data
$HADOOP_HOME/bin/hdfs dfs -mkdir /output



# kmeans.txt 10 60000 aprox 10mb
# kmeans.txt 10 600000 aprox 100mb
#scalac KMeansDataGenerator.scala 
#scala  KMeansDataGenerator kmeans.txt 10 60000


# lr.txt 10 60000 aprox 10mb
# lr.txt 10 600000 aprox 100mb
#scalac LRDataGenerator.scala 
#scala  LRDataGenerator lr.txt 10 60000

#SPARK_MASTER=spark://`hostname`:7077  #variable global source /root/vol-master/common.sh
#HDFS=hdfs://`hostname`:54310		  #variable global source /root/vol-master/common.sh


# Generando data
$SPARK_HOME/bin/spark-submit --class "KMeansDataGenerator" \
    --master $SPARK_MASTER \
    /root/mount-master/scalaDataGenerator/target/scala-2.10/data-generator_2.10-1.0.jar kmeans.txt 10 60000

$SPARK_HOME/bin/spark-submit --class "LRDataGenerator" \
    --master $SPARK_MASTER \
    /root/mount-master/scalaDataGenerator/target/scala-2.10/data-generator_2.10-1.0.jar lr.txt 10 60000



$HADOOP_HOME/bin/hdfs dfs -copyFromLocal -f kmeans.txt $HDFS/data/kmeans_data
$HADOOP_HOME/bin/hdfs dfs -copyFromLocal -f lr.txt $HDFS/data/lr_data





cd $OLDDIR
