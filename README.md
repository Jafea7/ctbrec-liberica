# Docker container for CTBRec server
[![Docker Image Size](https://img.shields.io/microbadger/image-size/jafea7/ctbrec-liberica)](http://microbadger.com/#/images/jafea7/ctbrec-liberica) [![Build Status](https://drone.le-sage.com/api/badges/jafea7/ctbrec-liberica/status.svg)](https://drone.le-sage.com/jafea7/ctbrec-liberica) [![GitHub Release](https://img.shields.io/github/release/jafea7/ctbrec-liberica.svg)](https://github.com/jafea7/ctbrec-liberica/releases/latest)

---

CTBRec is a streaming media recorder.

---
**NOTE**: Volumes have changed since initial version, (due to implementing PUID/PGID), see the example `docker run` and `docker-compose.yml` below.
---

`/root/.config` is now `/app/config`, `/root/captures` is now `/app/captures`
You will also need to edit your server.json file to change the recordings directory as follows:
`"recordingsDir": "/app/captures",`.

Your recordings will disappear from the `Recordings` tab if you do not update the volumes, (the recordings themselves will not be deleted, just the record), **and update the corresponding JSON file** with the new paths, eg. `/app/captures/.....` and `/app/config/.....` instead of `/root/captures/.....` and `/root/.config/.....`

---

## Table of Content

   * [Docker container for CTBRec server](#docker-container-for-ctbrec-server)
      * [Table of Content](#table-of-content)
      * [Quick Start](#quick-start)
      * [Usage](#usage)
         * [Environment Variables](#environment-variables)
         * [Data Volumes](#data-volumes)
         * [Ports](#ports)
         * [Changing Parameters of a Running Container](#changing-parameters-of-a-running-container)
      * [Docker Compose File](#docker-compose-file)
      * [Docker Image Update](#docker-image-update)
         * [Synology](#synology)
         * [unRAID](#unraid)
      * [Accessing the GUI](#accessing-the-gui)
      * [Shell Access](#shell-access)
      * [Default Web Interface Access](#default-web-interface-access)
      * [Extras](#extras)

## Quick Start

**NOTE**: The Docker command provided in this quick start is given as an example
and parameters should be adjusted to your need.

Launch the CTBRec server docker container with the following command:
```
docker run -d \
    --name=ctbrec-liberica \
    -p 8080:8080 \
    -p 8443:8443 \
    -v /home/ctbrec/media:/app/captures:rw \
    -v /home/ctbrec/.config/ctbrec:/app/config:rw \
    -e TZ=Australia/Sydney \
    -e PGID=1000 \
    -e PUID=1000 \
    jafea7/ctbrec-liberica
```

Where:
  - `/home/ctbrec/.config/ctbrec`: This is where the application stores its configuration and any files needing persistency.
  - `/home/ctbrec/media`:          This is where the application stores recordings.
  - `TZ`:                          The timezone you want the application to use, files created will be referenced to this.
  - `PGID`:                        The Group ID that CTBRec will run under.
  - `PUID`:                        The User ID that CTBRec will run under.

Browse to `http://your-host-ip:8080` to access the CTBRec web interface, (or `https://your-host-ip:8443` if TLS is enabled).

**NOTE**: The web interface needs to be enabled in the `server.json` config file before it can be used.  After starting the container, wait a minute then stop it, then edit the `server.json` file to enable it: `"webinterface": true,`

## Usage

```
docker run [-d] \
    --name=ctbrec-liberica \
    [-e <VARIABLE_NAME>=<VALUE>]... \
    [-v <HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]]... \
    [-p <HOST_PORT>:<CONTAINER_PORT>]... \
    jafea7/ctbrec-liberica
```
| Parameter | Description |
|-----------|-------------|
| -d        | Run the container in the background.  If not set, the container runs in the foreground. |
| -e        | Pass an environment variable to the container.  See the [Environment Variables](#environment-variables) section for more details. |
| -v        | Set a volume mapping (allows to share a folder/file between the host and the container).  See the [Data Volumes](#data-volumes) section for more details. |
| -p        | Set a network port mapping (exposes an internal container port to the host).  See the [Ports](#ports) section for more details. |

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`TZ`| [TimeZone] of the container.  Timezone can also be set by mapping `/etc/localtime` between the host and the container. | `Etc/UTC` |
|`PGID`| Group ID that will be used to run CTBRec within the container. | `1000` |
|`PUID`| User ID that will be used to run CTBRec within the container. | `1000` |

### Data Volumes

The following table describes data volumes used by the container.  The mappings
are set via the `-v` parameter.  Each mapping is specified with the following
format: `<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
|`/app/config`| rw | This is where the application stores its configuration, log and any files needing persistency. |
|`/app/captures`| rw | This is where the application stores recordings. |

### Ports

Here is the list of ports used by the container.  They can be mapped to the host
via the `-p` parameter (one per port mapping).  Each mapping is defined in the
following format: `<HOST_PORT>:<CONTAINER_PORT>`.  The port number inside the
container cannot be changed, but you are free to use any port on the host side.

| Port | Mapping to host | Description |
|------|-----------------|-------------|
| 8080 | Mandatory | Port used to serve HTTP requests. |
| 8443 | Mandatory | Port used to serve HTTPs requests. |

### Changing Parameters of a Running Container

As seen, environment variables, volume mappings and port mappings are specified
while creating the container.

The following steps describe the method used to add, remove or update
parameter(s) of an existing container.  The generic idea is to destroy and
re-create the container:

  1. Stop the container (if it is running):
```
docker stop ctbrec-liberica
```
  2. Remove the container:
```
docker rm ctbrec-liberica
```
  3. Create/start the container using the `docker run` command, by adjusting
     parameters as needed.

**NOTE**: Since all application's data is saved under the `/config` and
`/app/captures` container folder, destroying and re-creating a container is not
a problem: nothing is lost and the application comes back with the same state
(as long as the mapping of the `/config` and `/app/captures` folders
remain the same).

## Docker Compose File

Here is an example of a `docker-compose.yml` file that can be used with
[Docker Compose](https://docs.docker.com/compose/overview/).

Make sure to adjust according to your needs.  Note that only mandatory network
ports are part of the example.

```yaml
version: '2.1'
services:
  ctbrec-liberica:
    image: jafea7/ctbrec-liberica
    build: .
    environment:
      - TZ=Australia/Sydney
      - PGID=1000
      - PUID=1000
    ports:
      - "8080:8080"
      - "8443:8443"
    volumes:
      - "/home/ctbrec/.config/ctbrec:/app/config:rw"
      - "/home/ctbrec/media:/app/captures:rw"
```

## Docker Image Update

If the system on which the container runs doesn't provide a way to easily update
the Docker image, the following steps can be followed:

  1. Fetch the latest image:
```
docker pull jafea7/ctbrec-liberica
```
  2. Stop the container:
```
docker stop jafea7/ctbrec-liberica
```
  3. Remove the container:
```
docker rm jafea7/ctbrec-liberica
```
  4. Start the container using the `docker run` command.


**Updating using docker-compose:**
```
docker-compose pull && docker-compose up -d
```

### Synology

For owners of a Synology NAS, the following steps can be used to update a
container image.

  1.  Open the *Docker* application.
  2.  Click on *Registry* in the left pane.
  3.  In the search bar, type the name of the container (`jafea7/ctbrec-liberica`).
  4.  Select the image, click *Download* and then choose the `latest` tag.
  5.  Wait for the download to complete.  A  notification will appear once done.
  6.  Click on *Container* in the left pane.
  7.  Select your CTBRec server container.
  8.  Stop it by clicking *Action*->*Stop*.
  9.  Clear the container by clicking *Action*->*Clear*.  This removes the
      container while keeping its configuration.
  10. Start the container again by clicking *Action*->*Start*.
  
  **NOTE**:  The container may temporarily disappear from the list while it is re-created.

### unRAID

For unRAID, a container image can be updated by following these steps:

  1. Select the *Docker* tab.
  2. Click the *Check for Updates* button at the bottom of the page.
  3. Click the *update ready* link of the container to be updated.

## Accessing the GUI

Assuming that container's ports are mapped to the same host's ports, the
interface of the application can be accessed with a web browser at:

```
http://<HOST IP ADDR>:8080
```
Or if TLS is enabled:

```
https://<HOST IP ADDR>:8443
```

## Shell Access

To get shell access to the running container, execute the following command:

```
docker exec -ti CONTAINER sh
```

Where `CONTAINER` is the ID or the name of the container used during its
creation (e.g. `crashplan-pro`).

## Default Web Interface Access

After a fresh install and the web interface is enabled, the default login is:
  - Username: `ctbrec`
  - Password: `sucks`

Modify the username/password in the server.json file when the container is stopped.

**NOTE**: A fresh start of the image will include a default server.json, (if it doesn't exist already), with the following options set:
  - Web Interface set to true.
  - `caps.sh`, (see below), following a remux is set as post-processing, edit it to add or remove any steps.
  - The internal playlist generation is set as fast.

## Extras

---
`/caps.sh` - A shell script that creates the contact sheet faster than CTBRec by using ffprobe to obtain the duration of the video, calculating the time offsets of the images, and using that to skip to each location in the file to capture the image, ffmpeg then combines them into the contact sheet.
By default only applies when a file is over 250MB, for files under 250MB it uses the equivalent of the internal method, (which also uses ffmpeg).

**NOTES:**
  1. Only suitable for Linux systems, (uses Bash), if you want to use it independently of the Docker image.
  2. The created contact sheet will not be associated with the recording, (CTBRec JSON records), so deleting the recording via the interface, (Web/client), will leave the contact sheet behind.

```
  "postProcessors": [
    {
      "type": "ctbrec.recorder.postprocessing.Script",
      "config": {
        "script.params": "${absolutePath}",
        "script.executable": "/caps.sh"
      }
    },
```

It's called as follows:

```
/caps.sh <file> [true]

Arguments are: file = full path to the recording
               true = [optional] uses scripted contact sheet generation always
```
Regarding the 250MB file size point, below this the script is 2-4 seconds slower than the CTBRec internal command. As the file size increases the script becomes the faster method, as an example:

`Test file #1: 1920x1080, 30fps, 214MB, H264`

Internal method:
```
bash-5.0# time ./caps.sh /app/captures/model1/model1.mp4 
real    0m8.076s
user    0m8.053s
sys     0m0.767s
```
Scripted method:
```
bash-5.0# time ./caps.sh /app/captures/model1/model1.mp4 true
real    0m10.084s
user    0m9.358s
sys     0m1.044s
```
`Test file #2: 1920x1080, 60fps, 594MB, H264`

Internal method:
```
bash-5.0# time ./caps.sh /app/captures/model2/model2.mp4 
real    0m14.905s
user    0m13.754s
sys     0m2.022s
```
Scripted method:
```
bash-5.0# time ./caps.sh /app/captures/model2/model2.mp4 true
real    0m11.344s
user    0m10.194s
sys     0m1.489s
```
`Test file #3: 1280x720, 25fps, 7.85GB, H264`

Internal method:
```
bash-5.0# time ./caps.sh /app/captures/model3/model3.mp4
real    2m54.529s
user    4m29.855s
sys     0m32.233s
```
Scripted method:
```
bash-5.0# time ./caps.sh /app/captures/model3/model3.mp4 true
real    0m14.533s
user    0m10.289s
sys     0m1.904s
```
`Test file #4: 3840x2160, 30fps, 7.36GB, HEVC`

Internal method:
```
bash-5.0# time ./caps.sh /app/captures/model4/model4.mp4
real    1m52.629s
user    1m17.226s
sys     0m17.132s
```
Scripted method:
```
bash-5.0# time ./caps.sh /app/captures/model4/model4.mp4 true
real    0m38.142s
user    0m33.658s
sys     0m3.454s
```

---
