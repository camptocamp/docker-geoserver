# Docker image for GeoServer

A docker image that runs GeoServer version 2.17

## To run

```bash
cd docker-geoserver
docker build . -t geoserver:latest
docker run -p 8600:8080 geoserver:latest
```

Visit http://localhost:8600/web/
