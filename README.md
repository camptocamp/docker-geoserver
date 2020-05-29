# Docker image for GeoServer

A docker image that runs GeoServer version 2.17

## To run

```bash
cd docker-geoserver
docker build . -t geoserver2.17
docker run -p 8600:8080 geoserver:2.17
```

If you want modifications to be persistent, add `-v
$HOME/geoserver/data:/mnt/geoserver_datadir`.

Visit http://localhost:8600/web/
