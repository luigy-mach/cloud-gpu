
#!/bin/bash

sudo docker kill $(docker ps -aq)
sudo docker rm $(docker ps -aq)

