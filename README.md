# Docker container for CTBRec server
---

CTBRec is a streaming media recorder.

---
**NOTE**: 4.1.1 is the last version, please see [Jafea7/CTBRec-Debian](https://hub.docker.com/r/jafea7/ctbrec-debian) for subsequent versions.
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

If it's your initial use of this image then a default config is copied that already has the web interface enabled.

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

  **@ayyo** on Discord has provided a JSON file that can be imported to create the container, see **Synology-ctbrec.json**
---
  Create a new shared folder called `ctbrec` and two subfolders `media` and `config`, (all lowercase letters).
  Next open Docker, go to Container, then Settings, and Import this template.
  The WebUI is on: `https://yournasip:9943/`
---

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

**NOTE**: A fresh start of the image will include a current default server.json, (if it doesn't exist already), with the following options set:
  - `"downloadFilename": "${siteSanitizedName}_${modelSanitizedName}-${localDateTime(yyyyMMdd-HHmmss)}"`
  - `"fastPlaylistGenerator": true`
  - `"recordingsDirStructure": "ONE_PER_MODEL"`
  - `"totalModelCountInTitle": true`
  - `"transportLayerSecurity": true`
  - `"webinterface": true`

Three post-processing steps will be set:
  - Remux/Transcode using default parameters.
  - Rename to the following: `"${siteSanitizedName}_${modelSanitizedName}_${localDateTime(yyyyMMdd-HHmmss)}.${fileSuffix}"`
  - Create contact sheet: 8x7 images, 2560px wide (No timecode, ffmpeg used in Alpine do not support the filter.)

