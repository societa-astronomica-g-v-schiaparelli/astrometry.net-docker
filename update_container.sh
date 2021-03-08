#!/bin/bash
docker stop astrometrynet
docker rm astrometrynet
docker build --tag astrometrynet/astrometrynet:latest .
#ASTROMETRY_INDEX_PATH='/media/nascdf/Platesolver/data'
ASTROMETRY_INDEX_PATH='/home/osservatorio/astrometry.net/data-local'
docker run --detach --net=host --volume=$ASTROMETRY_INDEX_PATH:/data1/INDEXES:Z --name=astrometrynet --restart=always astrometrynet/astrometrynet
#docker logs -f astrometrynet
