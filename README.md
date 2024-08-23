# rlm-container-license-server
Containerised RLM License server to host multiple of licenses


# Template for containerised licenser server RLM

Author: Phong Chau

Summary:
Containerization of the license server which is expected to be deployed into kubernetes architecture.

For the time being, the docker engine is pre installed on a production VM 
### Prequisite
- Docker engine installed https://docs.docker.com/engine/install/
  Docker version 20.10.10, build b485636 is used for this documentation.
- A test machine with **Ethernet connectivity** and:
  - VM installed along with Docker engine within the VM.

### Environment used
In this setup the following environment is used:

Hardware: 
- Device: iMac
- OS: Ubuntu 20.04 SOE
- connectivity: ethernet
- VM:
  - Virtual Machine Manager (virt-manager)
  - Virtual Network Interface:
    - Network source: Host device eth0:macvtap
    - Source mode: Bridge
  - OS: Ubuntu 20.04 SOE


## Building the license server

1. Clone this repo

2. Place the generated license file `.lic` into the directory `/license`

    **NOTE:** Only put ONE `.lic`.

3. Within the directory of this repo where `Dockerfile` is visible, execute:

    **Syntax**: `docker build . -t <NAME>-license-server`

    Example cmd:
    `docker build . -t fastx3-license-server`

4. Verify the docker build has created the docker image with our custom `<NAME>-license-server`

    cmd:
    `docker images`

    Sample output:

    ```
    REPOSITORY               TAG       IMAGE ID       CREATED          SIZE
    fastx3-license-server      latest    414bbf3d2fd2   11 minutes ago   374MB

    ```

## Deploying docker container image with Port mapping


 we want to map the port `5054` from the Container itself.
In this illustration you can see the objective of port mapping (also oftenly referred as port forwarding) from:

> Container --> Docker Engine --> Virtual Machine 

In this deployment we are only going to map the port from 
> Docker Engine --> Virtual Machine

Since we have already predefined the port `5054` in the container specified in the `Dockerfile` (note the defined `EXPOSE 5054` in the `Dockerfile`).


4. Deploy the newly built docker image as a container in detach mode (detatch mode = to run docker container in the background):

    **Syntax**: `docker run -d -p <hostPort>:<containerPort> <dockerImage>`

    Example cmd:
    `docker run -d -p 5054:5054 -p 5053:5053 -p 57889:57889 fastx3-license-server`

    Now to confirm that the docker is running in the background:

    **cmd**: `docker ps`
    
    Sample output (take note of the **CONTAINER ID**):
    ```
    CONTAINER ID   IMAGE                   COMMAND               CREATED         STATUS             PORTS                                                                                                          NAMES
    fec77d6a4710   fastx3-license-server   "/opt/rlm/start.sh"   2 seconds ago   Up 2 seconds   0.0.0.0:5053-5054->5053-5054/tcp,     :::5053-5054->5053-5054/tcp, 0.0.0.0:57889->57889/tcp, :::57889->57889/tcp   busy_hodgkin
    ```
    
    Base on the **Example cmd** above the following ports as mentioned here:
    - 5053 -> Licenser Server
    - 5054 -> WebGUI
    - 57889 -> StarNet ISV port [[2]](https://www.starnet.com/xwin32kb/license_server/)

5. Now to find the `IPAddress` of the Docker Enginer has assigned to this container that we deployed with the command:

    **syntax:** `docker inspect <containerID> | grep IPAddress`

    **cmd:** `docker inspect fec77d6a4710 | grep IPAddress`

    Sample output:
    ```
    "SecondaryIPAddresses": null,
    "IPAddress": "172.17.0.3",
    "IPAddress": "172.17.0.3",
    ```
6. Inside your VM that launched this docker container, you can visit the WebGUI followed by the `"IPAddress": "172.17.0.3"` assigned by the Docker Engine along with details of the ports that this container expses as shown below:

    Also, note that the following ports are specified to be open:
    - 5053 -> Licenser Server
    - 5054 -> WebGUI, whilst docker is running visit the `output IP Address` with the port number. E.g. `172.17.0.3:5054`
    - 57889 -> StarNet ISV port [[2]](https://www.starnet.com/xwin32kb/license_server/)

 

7. Now to visit the **VM IP Address or Hostname**.  where you can visit the WebGUI through the VM.

 `localhost:5054` 


8. Now to visit the **VM IP Address or Hostname**, externally on your **workstation**.

 `localhost:5054` 



## Using the WebGUI

9. For login credentials, please refer to the shared password vault.

## Deploying this license container

**THIS INFO IS COMING SOON**

10. Once you are satisfied with your license server set up, please push it as a new project in this subgroups also use the preferred naming convention:
`<SERVICE> License Server`

11. Deploy into your desired VM by uploading your git repo and repeating steps in:
- Building the license server
- Deploying docker container image with Port mapping
Then verify that the ports are exposed by visiting the WebGUI (or using `netstat -tulpn` command) base  on your software vendor recommendation.

## Verifying the license server


Using `netstat -tulpn | grep docker` command, where you should see your desired published/expose ports.

Sample output to verify the following ports are opened 5054, 5053, 57889:

```
tcp        0      0 0.0.0.0:5053            0.0.0.0:*               LISTEN      4738/docker-proxy   
tcp        0      0 0.0.0.0:5054            0.0.0.0:*               LISTEN      4718/docker-proxy   
tcp        0      0 0.0.0.0:57889           0.0.0.0:*               LISTEN      4700/docker-proxy   
tcp6       0      0 :::5053                 :::*                    LISTEN      4743/docker-proxy   
tcp6       0      0 :::5054                 :::*                    LISTEN      4723/docker-proxy   
tcp6       0      0 :::57889                :::*                    LISTEN      4705/docker-proxy 
```

Additionally, verify that you are able to visit the WebGUI of the license server with:

> `VM_HOSTNAME:5054`  or  `VM_IP:5054`

## FAQ


### How do I obtain the hostid to generate .lic license file?
You can still visit the WebGUI without the need of the `.lic` to obtain the `hostid`.
Redo the steps in this guide and **SKIP Step 2.** until you reach Step 9.
From here:

1. Login (credential stored in shared vault)
2. Left-hand side, click System Info, and you'll find `hostid` [[2]](https://www.starnet.com/xwin32kb/license_server/)
3. With the `hostid` you can now generate a `.lic` license file from your vendor, and start again from Step 2 of this guide.


## Reference

[[1] https://www.starnet.com/xwin32kb/floating-license-registration/](https://www.starnet.com/xwin32kb/floating-license-registration/)

[[2] https://www.starnet.com/xwin32kb/license_server/](https://www.starnet.com/xwin32kb/license_server/)

