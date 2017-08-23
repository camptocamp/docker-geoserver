FROM jetty:9.4-jre8

MAINTAINER Camptocamp "info@camptocamp.com"

ENV GEOSERVER_VERSION 2.11.2

ENV XMS=1536M XMX=8G
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN echo "deb http://httpredir.debian.org/debian jessie main contrib non-free" > /etc/apt/sources.list \
 && echo "deb http://security.debian.org/ jessie/updates main contrib" >> /etc/apt/sources.list \
 && echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
 && apt-get update \
 && apt-get install -y ttf-mscorefonts-installer libjai-core-java libjai-imageio-core-java \
 && apt-get clean \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*
# note: libgdal-java removed because of conflits with libgdal1h...

RUN mkdir /mnt/geoserver_datadir /mnt/geoserver_geodata /mnt/geoserver_tiles && \
 chown jetty:jetty /mnt/geoserver_datadir /mnt/geoserver_geodata /mnt/geoserver_tiles
VOLUME [ "/mnt/geoserver_datadir", "/mnt/geoserver_geodata", "/mnt/geoserver_tiles", "/tmp", "/run/jetty" ]

RUN sed -i 's/threads.max=200/threads.max=50/g' $JETTY_BASE/start.d/server.ini

RUN wget -O geoserver-${GEOSERVER_VERSION}-war.zip https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip; \
 unzip geoserver-${GEOSERVER_VERSION}-war.zip geoserver.war; \
 mv geoserver.war $JETTY_BASE/webapps/; \
 mkdir $JETTY_BASE/webapps/geoserver; \
 unzip -e $JETTY_BASE/webapps/geoserver.war -d $JETTY_BASE/webapps/geoserver; \
 chown -R jetty:jetty $JETTY_BASE/webapps/geoserver; \
 rm -f geoserver-${GEOSERVER_VERSION}-war.zip

# Marlin renderer
RUN wget https://github.com/bourgesl/marlin-renderer/releases/download/v0.7.5_2/marlin-0.7.5-Unsafe.jar -O $JETTY_BASE/webapps/geoserver/WEB-INF/lib/marlin.jar
RUN wget https://github.com/bourgesl/marlin-renderer/releases/download/v0.7.5_2/marlin-0.7.5-Unsafe-sun-java2d.jar -O $JETTY_BASE/webapps/geoserver/WEB-INF/lib/marlin-sun-java2d.jar

# libjpeg-turbo
RUN wget http://downloads.sourceforge.net/project/libjpeg-turbo/1.5.1/libjpeg-turbo-official_1.5.1_amd64.deb -O /tmp/libjpegturbo.deb && \
      dpkg -i /tmp/libjpegturbo.deb && \
      rm -f /tmp/libjpegturbo.deb

# add turbojpeg in java.library.path
RUN echo '/opt/libjpeg-turbo/lib64/' >> /etc/ld.so.conf.d/libjpegturbo.conf

# Symlinking jai libs
RUN ln -s /usr/share/java/mlibwrapper_jai.jar $JETTY_BASE/lib/ext && \
    ln -s /usr/share/java/jai_codec.jar $JETTY_BASE/lib/ext && \
    ln -s /usr/share/java/jai_core.jar $JETTY_BASE/lib/ext && \
    ln -s /usr/share/java/clibwrapper_jiio.jar $JETTY_BASE/lib/ext && \
    ln -s /usr/share/java/jai_imageio.jar $JETTY_BASE/lib/ext

# Grmbl GeoSolutions-it ....
#RUN ln -s /usr/share/java/gdal.jar $JETTY_BASE/webapps/geoserver/WEB-INF/lib/

# Removes extra conflicting jars
#RUN rm -f $JETTY_BASE/webapps/geoserver/WEB-INF/lib/imageio-ext-gdal-bindings-1.9.2.jar

# Keep system version of JAI
RUN rm -f $JETTY_BASE/webapps/geoserver/WEB-INF/lib/jai_codec-1.1.3.jar $JETTY_BASE/webapps/geoserver/WEB-INF/lib/jai_core-1.1.3.jar $JETTY_BASE/webapps/geoserver/WEB-INF/lib/jai_imageio-1.1.jar

CMD ["sh", "-c", "exec java -Djava.io.tmpdir=$TMPDIR \
-DGEOSERVER_DATA_DIR=/mnt/geoserver_datadir \
-DGEOWEBCACHE_CACHE_DIR=/mnt/geoserver_tiles \
-DENABLE_JSONP=true \
-Dfile.encoding=UTF8 \
-Djavax.servlet.request.encoding=UTF-8 \
-Djavax.servlet.response.encoding=UTF-8 \
-Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2 \
-Xms$XMS -Xmx$XMX \
-Xbootclasspath/a:$JETTY_BASE/webapps/geoserver/WEB-INF/lib/marlin.jar \
-Xbootclasspath/p:$JETTY_BASE/webapps/geoserver/WEB-INF/lib/marlin-sun-java2d.jar \
-Dsun.java2d.renderer=org.marlin.pisces.MarlinRenderingEngine \
-XX:SoftRefLRUPolicyMSPerMB=36000 \
-XX:+UseParallelGC \
-XX:-UsePerfData \
${JAVA_OPTIONS} \
-jar $JETTY_HOME/start.jar" ]
