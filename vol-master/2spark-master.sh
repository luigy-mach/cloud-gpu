#!/bin/bash
OLDDIR=$(pwd)

dirMountMaster="/root/mount-master"
source $dirMountMaster/common.sh

##activar en caso no tener 
## /root/mount-master/scalaDataGenerator/target/scala-2.10/data-generator_2.10-1.0.jar
##cd $dirMountMaster/scalaDataGenerator 
##sbt package


mkdir -p $dirMountMaster/timings/

cd $dirMountMaster/java
CURR=$(pwd)


##javac -classpath $HADOOP_HOME/share/hadoop/common/hadoop-common-2.7.3.jar:$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.7.3.jar LogisticRegression.java
##jar cf $CURR/lr.jar LogisticRegression*.class



#javac -classpath $HADOOP_HOME/share/hadoop/common/hadoop-common-2.7.3.jar:$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.7.3.jar KMeans.java
#revisar <<<<<<<<<<<<<<<<
# DistributedCache in org.apache.hadoop.filecache has been deprecated
#javac -Xlint -classpath $HADOOP_HOME/share/hadoop/common/hadoop-common-2.7.3.jar:$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.7.3.jar KMeans.java
javac -classpath $HADOOP_HOME/share/hadoop/common/hadoop-common-2.7.3.jar:$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.7.3.jar KMeans.java
jar cf $CURR/kmeans.jar KMeans*.class


cd $OLDDIR
