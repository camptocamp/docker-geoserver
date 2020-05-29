# Docker image for GeoServer

A docker image that runs GeoServer version 2.16 with Jetty

## To run

```bash
docker run -d -p 8080:8080 camptocamp/geoserver:jetty-2.16
```

If you want modifications to be persistent, add `-v $HOME/geoserver/data:/usr/local/tomcat/webapps/ROOT/data`.
