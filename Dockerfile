FROM tomcat:9-jre11
MAINTAINER Camptocamp "info@camptocamp.com"

ENV GEOSERVER_VERSION 2.20
ENV GEOSERVER_MINOR_VERSION 1

RUN mkdir /tmp/geoserver /mnt/geoserver_datadir /mnt/geoserver_geodata /mnt/geoserver_tiles

# Install geoserver
RUN curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}/geoserver-${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}-war.zip/download > /tmp/geoserver.zip && \
    unzip -o /tmp/geoserver.zip -d /tmp/geoserver && \
    unzip -o /tmp/geoserver/geoserver.war -d $CATALINA_HOME/webapps/ROOT && \
    rm -rf $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/marlin-*.jar && \
    rm -r /tmp/*

VOLUME [ "/mnt/geoserver_datadir", "/mnt/geoserver_geodata", "/mnt/geoserver_tiles", "/tmp" ]

# Install plugins if necessary
# from sourceforge
RUN curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}-control-flow-plugin.zip/download > /tmp/control-flow-plugin.zip && \
    unzip -o /tmp/control-flow-plugin.zip -d $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/ && \
    curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}-css-plugin.zip/download > /tmp/css-plugin.zip && \
    unzip -o /tmp/css-plugin.zip -d $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/ && \
curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}-vectortiles-plugin.zip/download > /tmp/vectortiles-plugin.zip && \
    unzip -o /tmp/vectortiles-plugin.zip -d $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/
# from geoserver repo
#RUN curl -L https://build.geoserver.org/geoserver/${GEOSERVER_VERSION}.x/community-latest/geoserver-${GEOSERVER_VERSION}-SNAPSHOT-mbstyle-plugin.zip > /tmp/mbstyle-plugin.zip && \
#    unzip -o /tmp/mbstyle-plugin.zip -d $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/ && \
#    curl -L https://build.geoserver.org/geoserver/${GEOSERVER_VERSION}.x/community-latest/geoserver-${GEOSERVER_VERSION}-SNAPSHOT-mbtiles-plugin.zip > /tmp/mbtiles-plugin.zip && \
#    unzip -o /tmp/mbtiles-plugin.zip -d $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/ && \
#    rm /tmp/*

# Install Marlin
#RUN cd /usr/local/tomcat/lib && \
#    wget https://github.com/bourgesl/marlin-renderer/releases/download/v0.9.0/marlin-0.9.0-Unsafe.jar -O $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/marlin.jar && \
#    wget https://github.com/bourgesl/marlin-renderer/releases/download/v0.9.0/marlin-0.9.0-Unsafe-sun-java2d.jar -O $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/marlin-sun-java2d.jar

# Install native JAI  https://geoserver.geo-solutions.it/multidim/install_run/jai_io_install.html
RUN wget http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz && \
    tar xzf jai-1_1_3-lib-linux-amd64.tar.gz -C /tmp && \
    mv -v /tmp/jai-1_1_3/lib/*.jar $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/ && \
    mv -v /tmp/jai-1_1_3/lib/*.so $CATALINA_HOME/native-jni-lib/ && \
    rm -r /tmp/jai-1_1_3 jai-1_1_3-lib-linux-amd64.tar.gz
RUN wget http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz && \
    tar xzf jai_imageio-1_1-lib-linux-amd64.tar.gz -C /tmp && \
    mv -v /tmp/jai_imageio-1_1/lib/*.jar $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/ && \
    mv -v /tmp/jai_imageio-1_1/lib/*.so $CATALINA_HOME/native-jni-lib/ && \
    rm -r /tmp/jai_imageio-1_1 jai_imageio-1_1-lib-linux-amd64.tar.gz
# Clean old JAI implementation
#RUN rm -v $CATALINA_HOME/webapps/ROOT/WEB-INF/lib/jai_*.jar


# -Xbootclasspath/a:$CATALINA_HOME/webapps/ROOT/WEB-INF/lib/marlin.jar \
# -Xbootclasspath/p:$CATALINA_HOME/webapps/ROOT/WEB-INF/lib/marlin-sun-java2d.jar \
# -Dsun.java2d.renderer=org.marlin.pisces.MarlinRenderingEngine \
# -XX:+UseCGroupMemoryLimitForHeap"
# -XX:+UnlockExperimentalVMOptions

# since we are on JDK11, see also option -XX:MaxRAMPercentage instead of Xms/Xmx
ENV CATALINA_OPTS "-Xms1024M -Xmx2048m \
 -DGEOSERVER_DATA_DIR=/mnt/geoserver_datadir \
 -DGEOWEBCACHE_CACHE_DIR=/mnt/geoserver_tiles \
 -DENABLE_JSONP=true \
 -Dorg.geotools.coverage.jaiext.enabled=true \
 -Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2 \
 -XX:SoftRefLRUPolicyMSPerMB=36000 "

# Use min data dir template
COPY min_data_dir/ /mnt/geoserver_datadir/
