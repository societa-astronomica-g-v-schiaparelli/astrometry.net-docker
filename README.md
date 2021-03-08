# astrometry.net-docker

Docker scripts for local astrometry.net server.

Version: 0.84 (_not tested on other versions_)

References:

- Website: <https://astrometry.net/>
- NOVA: <https://nova.astrometry.net/>
- Documentation: <https://astrometry.net/doc>
- Data files: <http://data.astrometry.net/>
- GitHub repository: <https://github.com/dstndstn/astrometry.net>

## Description

The container need to run with the option `--net=host`, with all its implications.

The `Dockerfile` is obtained by merging the two Dockerfiles in the astrometry.net official repository (see [here](https://github.com/dstndstn/astrometry.net/tree/0.84/docker)), with some modifications to use a fixed version. You may need to change the exposed port (default: 8000) and the version (not recommended).

The script `setup-and-start-nova.sh` is copied into the image ad it is executed as the default command when starting a container: it setups and patches the environment to make the server work, since the [instructions in the official repository](https://github.com/dstndstn/astrometry.net/blob/0.84/docker/README.md), at the moment writing this file, creates a non-working server. You may need to change the openssh-server port (default: 2222) (remmember to change also the client configuration), the index files (default: 4200 (2MASS)), and the default scale (astrometry.net default: 0.1-180, default in this repository: 0.05-5).

Finally, since the server run in `localhost`, you need to use a reverse proxy to make the server reachable from other computers; an example in the `nova-reverse-proxy` file (it is a nginx configuration file).

## Index files

You need to download the index files from [here](http://data.astrometry.net/).

The folder structure need to be:

```tree
index-folder/
    |- 4100/
        |- index-...
        |- ...
    |- 4200/
        |- index-...
        |- ...
    |- 5000/
        |- index-...
        |- ...
    |- hd.fits
    |- hip.fits
    |- tycho2-cut.fits
    |- tycho2-mag4.fits
    |- tycho2.kd
```

## Installation

Go to the root ot this repository. Build and execute with:

```bash
docker build --tag astrometrynet/astrometrynet:latest .
ASTROMETRY_INDEX_PATH='/path/to/index/folder'
docker run --detach --net=host --volume=$ASTROMETRY_INDEX_PATH:/data1/INDEXES --name=astrometrynet --restart=always astrometrynet/astrometrynet
```

or use the scirpt `update_container.sh`
