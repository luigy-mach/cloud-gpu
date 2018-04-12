#!/bin/bash

# N is the node number of hadoop cluster
num_slaves=$1

if [ $# = 0 ]
then
	echo "error: number of hadoop cluster"
	exit 1
fi


mydir=$PWD

echo ""
cd config
./generate-master-slaves.sh $num_slaves
echo ""
cd $mydir
#sudo docker build -t "cluster-$num_slaves-nodes:$num_slaves" .
echo ""
