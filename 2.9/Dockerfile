FROM tomcat:8-jre8
MAINTAINER Camptocamp "info@camptocamp.com"

ENV GEOSERVER_VERSION 2.9

# Install Java JAI libraries
RUN cd /tmp && \
    curl -L http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz | tar xfz - && \
    curl -L http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz  | tar xfz - && \
    mv /tmp/jai*/lib/*.jar $JAVA_HOME/lib/ext/ && \
    mv /tmp/jai*/lib/*.so $JAVA_HOME/lib/amd64/ && \
    rm -r /tmp/*

# Install geoserver
RUN curl -L http://ares.boundlessgeo.com/geoserver/${GEOSERVER_VERSION}.x/geoserver-${GEOSERVER_VERSION}.x-latest-war.zip > /tmp/geoserver.zip && \
    unzip /tmp/geoserver.zip -d /tmp/geoserver && \
    rm -rf ${CATALINA_HOME}/webapps/* && \
    unzip /tmp/geoserver/geoserver.war -d $CATALINA_HOME/webapps/ROOT && \
    rm -r /tmp/*

# Install plugins (WPS)
RUN curl -L http://ares.boundlessgeo.com/geoserver/${GEOSERVER_VERSION}.x/ext-latest/geoserver-${GEOSERVER_VERSION}-SNAPSHOT-wps-plugin.zip > /tmp/geoserver-wps-plugin.zip && \
    unzip /tmp/geoserver-wps-plugin.zip -d $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/ && \
    rm /tmp/*
