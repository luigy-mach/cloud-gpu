#!/bin/bash

########### arg $1 name-of-slave
########### ./star-client-only.sh slave1
########### ./star-client-only.sh slave2
########### ./star-client-only.sh slave3
########### .
########### .
########### .

            
valDefault=""
input=${1:-$valDefault}

dockerImage="luigymach/hadoop-spark-gpu-cluster"
dockerNet="hadoop-overlay-gpu"

mkdir -p "mount-all-slaves"

nameContainerMaster="master"

mydir=$(pwd)

if [ "$input" != "$valDefault" ]; then
     echo "start $input container..."
     sudo docker rm -f $input &> /dev/null
     mkdir -p "mount-$input"
     sudo docker run -itd \
                    --net=$dockerNet \
                    --name $input \
                    --link=$nameContainerMaster \
                    --hostname $input \
                    -v "$mydir/mount-all-slaves:/root/mount-all-slaves" \
                     $dockerImage &> /dev/null
     echo "      $input is running"
else
     echo "fail name container"
fi
            

