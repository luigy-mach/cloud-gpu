#!/bin/bash

dockerImage="luigymach/hadoop-spark-gpu-cluster"
dockerNet="hadoop-overlay-gpu"

nameContainer="master"

mydir=$(pwd)

sudo docker rm -f $nameContainer &> /dev/null
echo "start MASTER container..."
#mkdir -p "vol-master"
   
mkdir -p "mount-all-slaves"
sudo docker run -itd \
                --net=$dockerNet \
                -p 50070:50070 \
                -p 8088:8088 \
                -p 54310:54310 \
                -p 54311:54311 \
                -p 8025:8025 \
                -p 8030:8030 \
                -p 8050:8050 \
                -p 8080:8080 \
                -p 4040:4040 \
                -p 7077:7077 \
                -p 6066:6066 \
                --name $nameContainer \
                --hostname master \
                -v "$mydir/vol-master:/root/mount-master" \
                -v "$mydir/mount-all-slaves:/root/mount-all-slaves" \
                $dockerImage &> /dev/null
                
sudo docker exec -it $nameContainer bash
