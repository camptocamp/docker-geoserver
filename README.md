# Docker image for GeoServer

A docker image that runs GeoServer version 2.16

## To run

```bash
cd docker-geoserver
docker build . -t geoserver
docker run -p 8600:8080 geoserver
```

Visit http://localhost:8600/web/
