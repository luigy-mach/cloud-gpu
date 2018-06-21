

`Setup`
=======


[![DockerPulls](https://img.shields.io/docker/pulls/luigymach/hadoop-spark-gpu-cluster.svg)](https://registry.hub.docker.com/u/luigymach/hadoop-spark-gpu-cluster/) [![DockerStars](https://img.shields.io/docker/stars/luigymach/hadoop-spark-gpu-cluster.svg)](https://registry.hub.docker.com/u/luigymach/hadoop-spark-gpu-cluster/)


### Iniciar Swarm Nodes/Cluster

- Master
```console
foo@bar:~$ sudo docker swarm init
```
- Slaves
	- `join-tokens` se muestra al ejecutar `swarm init` en el `Master`
```console
foo@bar:~$ sudo docker swarm join <Master-Node-IP>:2377 + join-tokens
```
> NOTA: para extraer `join-token` ejecutar `sudo docker swarm join-token`


### Crear una red
--------------

```console
foo@bar:~$ sudo docker network create --driver overlay --attachable --subnet=20.0.9.0/24 hadoop-overlay-gpu
```


### Ejecucion
---------
- Master
```console
foo@bar:~$ ./start-server-only.sh
```
- Nodes
```console
foo1@bar1:~$ ./start-client-only.sh slave1
foo2@bar2:~$ ./start-client-only.sh slave2
foo3@bar3:~$ ./start-client-only.sh slave3
foo4@bar4:~$ ...
foo5@bar5:~$ ..
foo6@bar6:~$ .
```


### Test Nodes
----------
- Master

```console
master@master:~$ ssh slave1
master@master:~$ exit
master@master:~$ ssh slave2
master@master:~$ exit
master@master:~$ ssh slave3
master@master:~$ exit
master@master:~$ ...
master@master:~$ ..
master@master:~$ .
```




### Dentro de la maquina virtual ejecutar
-------------------------------------

```console

root@master:~# ifconfig
		eth0      Link encap:Ethernet  HWaddr 02:42:ac:12:00:02  
		          inet addr:172.18.0.2  Bcast:0.0.0.0  Mask:255.255.0.0
		          inet6 addr: fe80::42:acff:fe12:2/64 Scope:Link
		          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
		          RX packets:289 errors:0 dropped:0 overruns:0 frame:0
		          TX packets:220 errors:0 dropped:0 overruns:0 carrier:0
		          collisions:0 txqueuelen:0 
		          RX bytes:51132 (51.1 KB)  TX bytes:39306 (39.3 KB)

		lo        Link encap:Local Loopback  
		          inet addr:127.0.0.1  Mask:255.0.0.0
		          inet6 addr: ::1/128 Scope:Host
		          UP LOOPBACK RUNNING  MTU:65536  Metric:1
		          RX packets:119 errors:0 dropped:0 overruns:0 frame:0
		          TX packets:119 errors:0 dropped:0 overruns:0 carrier:0
		          collisions:0 txqueuelen:1 
		          RX bytes:23414 (23.4 KB)  TX bytes:23414 (23.4 KB)


root@master:~# ssh 172.18.0.2 
	The authenticity of host '172.18.0.4 (172.18.0.4)' can't be established.
	ECDSA key fingerprint is SHA256:4Q7jI+NiTB3dlAXAF9B3zyQHiqK61XwVbqCpXtKpeMA.

	Are you sure you want to continue connecting (yes/no)? yes
root@master:~# exit


root@master:~# ssh 172.18.0.3
	The authenticity of host '172.18.0.4 (172.18.0.4)' can't be established.
	ECDSA key fingerprint is SHA256:4Q7jI+NiTB3dlAXAF9B3zyQHiqK61XwVbqCpXtKpeMA.
	
	Are you sure you want to continue connecting (yes/no)? yes
root@slave1:~# exit

root@master:~# ssh 172.18.0.4
	The authenticity of host '172.18.0.4 (172.18.0.4)' can't be established.
	ECDSA key fingerprint is SHA256:4Q7jI+NiTB3dlAXAF9B3zyQHiqK61XwVbqCpXtKpeMA.
	
	Are you sure you want to continue connecting (yes/no)? yes
root@slave2:~# exit


root@slave2:~# clean-hdfs.sh

root@slave2:~# start-hadoop.sh

root@slave2:~# start-spark.sh

```
