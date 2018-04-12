#!/bin/bash

cd "$(dirname "$0")"

SPARK_MASTER=spark://`hostname`:7077  #variable global
HDFS=hdfs://`hostname`:54310		  #variable global