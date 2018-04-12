#!/bin/bash

OLDDIR=$(pwd)

dirMountMaster="/root/mount-master"
source $dirMountMaster/common.sh

#SPARK_MASTER=spark://`hostname`:7077  #variable global
#HDFS=hdfs://`hostname`:54310		  #variable global

#cd $dirMountMaster/java

#echo "funciona - ok"
$SPARK_HOME/bin/spark-submit --class SparkHdfsLR \
  --master $SPARK_MASTER /root/mount-master/scalaDataGenerator/target/scala-2.10/data-generator_2.10-1.0.jar \
  $SPARK_MASTER $HDFS/data/lr_data 10
#  $SPARK_MASTER $HDFS/data/lr_data 2

#$SPARK_HOME/bin/spark-submit --class SparkHdfsLR \
#  --master $SPARK_MASTER \
#  $SPARK_MASTER $HDFS/data/lr_data 10

#$SPARK_HOME/bin/spark-submit --class SparkHdfsLR \
#  --master $SPARK_MASTER target/scala-2.10/data-generator_2.10-1.0.jar \
#  $SPARK_MASTER $HDFS/data/lr_data 10

#scalac KMeansDataGenerator.scala 
#scala  KMeansDataGenerator kmeans.txt 10 60000

  
cd $OLDDIR