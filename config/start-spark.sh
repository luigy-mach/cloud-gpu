#!/bin/bash

echo -e "\n"

$SPARK_HOME/sbin/start-all.sh 

echo -e "\n"


OLDDIR=$(pwd)

#cd /root/config/scalaDataGenerator 
#sbt package

cd $OLDDIR
