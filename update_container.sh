#!/bin/bash
docker stop astrometrynet
docker rm astrometrynet
docker build --tag astrometrynet/astrometrynet:latest .
#VOLUME='/media/nascdf/Platesolver/data'
VOLUME='/home/osservatorio/astrometry.net/data-local'
docker run --detach --net=host --volume=$VOLUME:/data1/INDEXES:Z --name=astrometrynet --restart=always astrometrynet/astrometrynet
#docker logs -f astrometrynet
