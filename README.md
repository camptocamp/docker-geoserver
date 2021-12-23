# Docker image for GeoServer

A docker image that runs GeoServer version 2.20.1

## To run

```bash
cd docker-geoserver
docker build . -t geoserver:latest
docker run -p 8600:8080 geoserver:latest
```

If you want modifications to be persistent, add `-v $HOME/geoserver/data:/mnt/geoserver_datadir`.

Visit http://localhost:8600/web/
