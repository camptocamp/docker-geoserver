FROM tomcat:9-jre8
MAINTAINER Camptocamp "info@camptocamp.com"

ENV GEOSERVER_VERSION 2.14.1

RUN mkdir /tmp/geoserver /mnt/geoserver_datadir /mnt/geoserver_geodata /mnt/geoserver_tiles

# Install geoserver
RUN curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip/download > /tmp/geoserver.zip && \
    unzip -o /tmp/geoserver.zip -d /tmp/geoserver && \
    unzip -o /tmp/geoserver/geoserver.war -d $CATALINA_HOME/webapps/ROOT && \
    rm -rf $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/marlin-*.jar && \
    rm -r /tmp/*

VOLUME [ "/mnt/geoserver_datadir", "/mnt/geoserver_geodata", "/mnt/geoserver_tiles", "/tmp" ]

# Install plugins if necessary

# Install Marlin
RUN cd /usr/local/tomcat/lib && \
    wget https://github.com/bourgesl/marlin-renderer/releases/download/v0.9.0/marlin-0.9.0-Unsafe.jar -O $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/marlin.jar && \
    wget https://github.com/bourgesl/marlin-renderer/releases/download/v0.9.0/marlin-0.9.0-Unsafe-sun-java2d.jar -O $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/marlin-sun-java2d.jar

ENV CATALINA_OPTS "-Xms1024M -Xmx4096M \
 -Xbootclasspath/a:$CATALINA_HOME/webapps/ROOT/WEB-INF/lib/marlin.jar \
 -Xbootclasspath/p:$CATALINA_HOME/webapps/ROOT/WEB-INF/lib/marlin-sun-java2d.jar \
 -Dsun.java2d.renderer=org.marlin.pisces.MarlinRenderingEngine \
 -DGEOSERVER_DATA_DIR=/mnt/geoserver_datadir \
 -DGEOWEBCACHE_CACHE_DIR=/mnt/geoserver_tiles \
 -DENABLE_JSONP=true \
 -Dorg.geotools.coverage.jaiext.enabled=true \
 -Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2 \
 -XX:SoftRefLRUPolicyMSPerMB=36000 \
 -XX:+UnlockExperimentalVMOptions \
 -XX:+UseCGroupMemoryLimitForHeap"

# Use min data dir template
COPY min_data_dir/* /mnt/geoserver_datadir/
