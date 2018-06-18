
#!/bin/bash





########### arg $1 name-of-slave
########### ./star-client-only.sh slave1
########### ./star-client-only.sh slave2



# the default node number is 3
var=${1:-2}
dockerImage="luigymach/cluster-hadoop-spark-gpu:3.0.0"
dockerNet="hadoop-overlay-gpu"

mkdir -p "mount-all-slaves"
#nameContainerMaster="masterGpu"
nameContainerMaster="master"


mydir=$(pwd)

# start hadoop master container
#sudo docker rm -f hadoop-master &> /dev/null

### sudo docker rm -f master &> /dev/null
### echo "start MASTER container..."

#mkdir -p "vol-master"

   
### sudo docker run -itd \
###                 --net=$dockerNet \
###                 -p 50070:50070 \
###                 -p 8088:8088 \
###                 -p 54310:54310 \
###                 -p 54311:54311 \
###                 -p 8025:8025 \
###                 -p 8030:8030 \
###                 -p 8050:8050 \
###                 -p 8080:8080 \
###                 -p 4040:4040 \
###                 -p 7077:7077 \
###                 -p 6066:6066 \
###                 --name master \
###                 --hostname master \
###                 -v "$mydir/vol-master:/root/mount-master" \
###                 -v "$mydir/mount-all-slaves:/root/mount-all-slaves" \
###                 $dockerImage &> /dev/null
###                 #hadoop-spark-luigy3:16.04 &> /dev/null
###                 #--name hadoop-master \
### 
###                 #spark://master:7077
###                                 #spark://master:6066 (cluster mode)



#sudo docker run -itd --net=homenet --ip 192.168.1.201 --add-host slave1:192.168.1.202 --name master --hostname master  cluster-luigy-2.2:16.04  &> /dev/null
#sudo docker exec -it master bash

 #&> /dev/null



### echo "start SLAVES container..."

### for (( i = 1; i < $var+1; i++ )); do
###         #sudo docker rm -f hadoop-slave$i &> /dev/null
###         sudo docker rm -f slave$i &> /dev/null
###         echo "start SLAVE$i container..."
###         mkdir -p "mount-slave$i"
###         sudo docker run -itd \
###                        --net=$dockerNet \
###                        --name slave$i \
###                        --link=master \
###                        --hostname slave$i \
###                        -v "$mydir/mount-all-slaves:/root/mount-all-slaves" \
###                         $dockerImage &> /dev/null
###                        #-v "$mydir/mount-slave$i:/root/mount-slave$i" \
###                        #hadoop-spark-luigy2:13.04 &> /dev/null
###                        #--name hadoop-slave$i \
###                        #--link=hadoop-master \
### done



echo "start SLAVES $1 container..."

#sudo docker rm -f hadoop-slave$i &> /dev/null
sudo docker rm -f $1 &> /dev/null
echo "start $1 container..."
mkdir -p "mount-$1"
sudo docker run -itd \
               --net=$dockerNet \
               --name $1 \
               --link=$nameContainerMaster \
               --hostname $1 \
               -v "$mydir/mount-all-slaves:/root/mount-all-slaves" \
                $dockerImage &> /dev/null
               #-v "$mydir/mount-slave$i:/root/mount-slave$i" \
               #hadoop-spark-luigy2:13.04 &> /dev/null
               #--name hadoop-slave$i \
               #--link=hadoop-master \



### sudo docker exec -it master bash