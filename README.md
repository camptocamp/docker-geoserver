# Docker image for GeoServer

A docker image that runs GeoServer version 2.25.2

## To run

```bash
cd docker-geoserver
docker build . -t geoserver:latest
docker run -p 8600:8080 geoserver:latest
```

Visit http://localhost:8600/geoserver/web/

## If you want modifications to be persistent

you should add a mount point that overwrites `/mnt/geoserver_datadir`, in the example below
we will use `$HOME/data/geoserver_datadir`.

We must first create a copy of the original geoserver_datadir if we don't have one already,
otherwise de default directory in jetty home will be used.

```bash

mkdir -p $HOME/data/
cp -r ./min_data_dir $HOME/data/geoserver_datadir

# change permissions on to jetty user. Adapt this to your needs if you are not using the default 999:999 user
sudo chown -R 999:999 $HOME/data/geoserver_datadir

# launch the container, the volume should be writable by jetty.
docker run -v $HOME/data/geoserver_datadir:/mnt/geoserver_datadir --rm -d -p 8600:8080 --name geoserver geoserver:latest

```
