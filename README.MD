# Parallel Cucumber in Docker
How to run Cucumber tests in Parallel using Docker for Windows, Selenium Hub, and Jenkins


### Getting started with Docker
Before trying to get this Docker solution running, I ***highly*** reccomend you run through the Docker getting started guide located [here](https://docs.docker.com/get-started/)

*Note*: You might **have** to run through the getting started guide to get Hyper-V configured correctly

*Note*: In the getting started guide, when it comes to the docker-machine part, you *might* have to follow the instructions
                                      	[here](https://github.com/docker/machine/issues/4424#issuecomment-377727985)
                                      	for getting Docker Machine to work on Windows

### Part 1: Getting Docker Set Up:

1. clone this repo, `git clone https://github.com/ah0y/parallel_cucumber.git`
2. open up an **administrator** version of hyper-v and powershell (then `cd` into the directory you've downloaded this repo to with powershell)
3. create 2 docker-machine vms (like in step 4 of the geting started guide)
    * `docker-machine create -d hyperv --hyperv-virtual-switch "myswitch" --hyperv-memory "4096" myvm1`
    * `docker-machine create -d hyperv --hyperv-virtual-switch "myswitch" --hyperv-memory "2048" myvm2`
    * *Note*: You might have to clean up the vms you've created from the getting started guide with `docker-machine rm <vm-name> -f`
4. run `docker-machine ls`  and note your **myvm1** ip address
5. run ` docker-machine ssh myvm1 "docker swarm init --advertise-addr <myvm1 ip>"` to initialize your swam and get your docker swarm join command
6. run `docker-machine ssh myvm2 "<docker swarm join command>"` filling in the docker-swarm command with the output you've received in step 5. Make sure to ***change*** the port number on the very end of the join swarm command from **2376** to **2377** when joining a worker to a swarm
    * *Note*: The docker swarm join command needs to be in quotes
7.  run `docker-machine ssh myvm1 "docker node ls"` to verify you've succesfully built the swarm
8. run `& "C:\Program Files\Docker\Docker\Resources\bin\docker-machine.exe" env myvm1 | Invoke-Expression` to configure powershell to execute commands on myvm1
9. run `docker stack deploy -c docker-compose.yml parallel_cucumber` to build the stack
10. Voila! Docker Swarm is now setup
    * visit `<myvm1 ip>:8080` to access Jenkins (might take a minute to load)
    * visit `<myvm1 ip>:4444/grid/console` to access the Selenium Grid
11. after you've set up your Docker Swarm, scale chrome with `docker service scale parallel_cucumber_chrome=10` (You should see the number of Chrome instances on the Selenium Grid increase)

### Part 2: Getting Jenkins Set Up:
1. visit `<myvm1 ip>:8080` to access Jenkins
2. run `docker container ls` 
3. note the **container id** (column on the far left) of the jenkins-docker image
4. run `docker exec -it <container id of jenkins-docker image> bash` to access the Jenkins container
5. run `cd /var/jenkins_home/secrets/`
6. run `cat initialAdminPassword` to recieve the password to unlock Jenkins
7. copy the password you've recieved in step 6 into Jenkins and hit continue
8. install the suggested plugins
9. after the plugins are installed, continue as admin or setup an account. doesn't really matter 
10. Voila! Jenkins is now setup

### Part 3: Getting Jenkins to Build Dockerfiles and Run Cucumber Tests in Parallel:
1. on the Jenkins main menu, hit 'New Item' on the left hand side 
2. enter in 'parallel_cucumber' for the item name
3. select 'Freestyle project' and hit 'Ok'
4. on the General tab (should be the default tab Jenkins takes you to), hit 'git' under 'Source Code Management'
5. copy the url for this repo into the 'Repository Url' field (https://github.com/ah0y/parallel_cucumber.git)
6. under build hit 'Add build step' and select 'Execute shell'
7. in the 'Command' text field, paste in `docker build --build-arg GRID_IP=http://<myvm1 ip>:4444/wd/hub --build-arg NODES=10 -t parallel_cucumber .` replacing myvm1 ip with your myvm1 ip
    * *Note*: 'http://' is required when specifying the IP for the docker build command
    * *Note*: Don't forget the '.' at the very end!
8. hit 'Save' 
9. on the left hand side, hit 'Build Now' to build the test suite
10. Voila! You have now successfully run a test suite in parallel using Docker, Selenium Hub, and Jenkins


###### Notes:
* To add different physical machines to the docker swarm, just install docker on the additional machines and run step 3 and 6 from part 1 on each additional machine
