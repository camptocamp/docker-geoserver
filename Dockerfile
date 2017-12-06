FROM tomcat:8-jre8
MAINTAINER Camptocamp "info@camptocamp.com"

# Install Java JAI libraries
RUN cd /tmp && \
    curl -L http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz | tar xfz - && \
    curl -L http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz  | tar xfz - && \
    mv /tmp/jai*/lib/*.jar $JAVA_HOME/lib/ext/ && \
    mv /tmp/jai*/lib/*.so $JAVA_HOME/lib/amd64/ && \
    rm -r /tmp/*

ENV GEOSERVER_VERSION 2.13
ENV GEOSERVER_VERSION_NAME master


# Install geoserver
RUN curl -L http://ares.boundlessgeo.com/geoserver/${GEOSERVER_VERSION_NAME}/geoserver-${GEOSERVER_VERSION_NAME}-latest-war.zip > /tmp/geoserver.zip && \
    unzip /tmp/geoserver.zip -d /tmp/geoserver && \
    rm -rf ${CATALINA_HOME}/webapps/* && \
    unzip /tmp/geoserver/geoserver.war -d $CATALINA_HOME/webapps/ROOT && \
    (cd $CATALINA_HOME/webapps/ROOT/WEB-INF/lib; rm jai_core-*jar jai_imageio-*.jar jai_codec-*.jar) && \
    rm -r /tmp/*

# Install plugins (WPS)
RUN curl -L http://ares.boundlessgeo.com/geoserver/${GEOSERVER_VERSION_NAME}/ext-latest/geoserver-${GEOSERVER_VERSION}-SNAPSHOT-wps-plugin.zip > /tmp/geoserver-wps-plugin.zip && \
    unzip /tmp/geoserver-wps-plugin.zip -d $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/ && \
    rm /tmp/*

# Install Marlin
RUN cd /usr/local/tomcat/lib && wget https://github.com/bourgesl/marlin-renderer/releases/download/v0.8.2/marlin-0.8.2-Unsafe.jar && \
    wget https://github.com/bourgesl/marlin-renderer/releases/download/v0.8.2/marlin-0.8.2-Unsafe-sun-java2d.jar

ENV CATALINA_OPTS "-Xbootclasspath/a:/usr/local/tomcat/lib/marlin-0.7.4-Unsafe.jar -Xbootclasspath/p:/usr/local/tomcat/lib/marlin-0.7.4-Unsafe-sun-java2d.jar -Dsun.java2d.renderer=org.marlin.pisces.PiscesRenderingEngine" 
