#!/bin/bash
OLDDIR=$(pwd)

dirMountMaster="/root/mount-master"
source $dirMountMaster/common.sh



cd $dirMountMaster/java

$HADOOP_HOME/bin/hadoop jar kmeans.jar KMeans



cd $OLDDIR

