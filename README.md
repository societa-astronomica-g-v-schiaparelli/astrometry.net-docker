# astrometry.net-docker

Docker scripts for local astrometry.net server.

Version: 0.86 (tested also with 0.85, 0.84)

References:

- Website: <https://astrometry.net/>
- NOVA: <https://nova.astrometry.net/>
- Documentation: <https://astrometry.net/doc>
- Data files: <http://data.astrometry.net/>
- GitHub repository: <https://github.com/dstndstn/astrometry.net>

## Description

The container need to run with the option `--net=host`, with all its implications.

The `Dockerfile` is obtained by merging the two Dockerfiles in the astrometry.net official repository (see [here](https://github.com/dstndstn/astrometry.net/tree/0.85/docker)), with some modifications to use a fixed version. You may need to change the exposed port (default: 8000) and the version (not recommended).

The script `setup-and-start-nova.sh` is copied into the image ad it is executed as the default command when starting a container: it setups and patches the environment to make the server work, since the [instructions in the official repository](https://github.com/dstndstn/astrometry.net/blob/0.85/docker/README.md), at the moment writing this file, creates a non-working server.

You may need to change:
- the openssh-server port (default: 2222), remmember to change also the client configuration;
- the index files (default: 4200 (2MASS));
- the default scale (astrometry.net default: 0.1-180, default in this repository: 0.05-5).

Finally, since the server run in `localhost`, you need to use a reverse proxy to make the server reachable from other computers; an example in the `nova-reverse-proxy` file (it is a nginx configuration file).

## Index files

You need to download the index files from [here](http://data.astrometry.net/).

The folder structure need to be:

```tree
index-folder
├── 4100
│   ├── index-...
│   ├── ...
├── 4200
│   ├── index-...
│   ├── ...
├── 5000
│   ├── index-...
│   ├── ...
├── hd.fits
├── hip.fits
├── tycho2-cut.fits
├── tycho2.kd
└── tycho2-mag4.fits
```

## Installation

Build and execute with:

```bash
docker build --tag astrometrynet/astrometrynet:0.85 .
ASTROMETRY_INDEX_PATH='/your/path/to/index-folder'
ASTROMETRY_SUBMISSIONS_PATH='/your/path/to/submissions'
docker run --detach --net=host --volume=$ASTROMETRY_INDEX_PATH:/data1/INDEXES --volume=$ASTROMETRY_SUBMISSIONS_PATH:/src/astrometry/net/data --name=astrometrynet --restart=always astrometrynet/astrometrynet:0.85
```

As you can see, there are two volumes:
- `ASTROMETRY_INDEX_PATH='/path/to/index-folder'`. This volume contain the index files: this folder _must_ have the structure illustrated in the previous section.
- `ASTROMETRY_SUBMISSIONS_PATH='/path/to/submissions'`. This volume contain the persistent submissions database, i.e. images, jobs informations and results. At the first launch, this folder should be an empty folder, the container will populate it. If you don't want a persistent submissions database, simply do not specify this volume.

You can also use `docker-compose`. Be sure to change the volume paths with:

```yaml
volumes:
    - /your/path/to/index-folder:/data1/INDEXES
    - /your/path/to/submissions:/src/astrometry/net/data
```
