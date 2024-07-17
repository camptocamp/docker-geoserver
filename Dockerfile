FROM jetty:10-jre11 as builder
MAINTAINER Camptocamp "info@camptocamp.com"

# Latest stable as of 7th of march 2023
ENV GEOSERVER_VERSION 2.25
ENV GEOSERVER_MINOR_VERSION 2
ENV XMS=1536M XMX=8G

USER root

# the fonts are located in non-free
RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN apt-get update \
    && apt-get upgrade --assume-yes \
    # accept the fonts EULA without the ncurses GUI
    && echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
    && apt-get install -y ttf-mscorefonts-installer unzip \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# libjpeg-turbo is different from turboJpeg
RUN wget https://sourceforge.net/projects/libjpeg-turbo/files/2.1.2/libjpeg-turbo-official_2.1.2_amd64.deb && \
    dpkg -i libjpeg-turbo-official_2.1.2_amd64.deb && \
    rm libjpeg-turbo-official_2.1.2_amd64.deb

# create dirs
RUN mkdir -p /mnt/geoserver_datadir /mnt/geoserver_geodata /mnt/geoserver_tiles /tmp/geoserver
RUN chown jetty:jetty /mnt/geoserver_datadir /mnt/geoserver_geodata /mnt/geoserver_tiles /tmp/geoserver

USER jetty

RUN sed -i 's/threads.max=200/threads.max=50/g' $JETTY_BASE/start.d/server.ini

# Install geoserver
RUN curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}/geoserver-${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}-war.zip/download > /tmp/geoserver.zip && \
    unzip -o /tmp/geoserver.zip -d /tmp/geoserver && \
    unzip -o /tmp/geoserver/geoserver.war -d $JETTY_BASE/webapps/geoserver && \
    rm -r /tmp/geoserver*

# Install plugins if necessary
# from sourceforge
RUN curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}-control-flow-plugin.zip/download > /tmp/control-flow-plugin.zip && \
    unzip -o /tmp/control-flow-plugin.zip -d $JETTY_BASE/webapps/geoserver/WEB-INF/lib/ && \
    curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}-css-plugin.zip/download > /tmp/css-plugin.zip && \
    unzip -o /tmp/css-plugin.zip -d $JETTY_BASE/webapps/geoserver/WEB-INF/lib/ && \
    curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}-vectortiles-plugin.zip/download > /tmp/vectortiles-plugin.zip && \
    unzip -o /tmp/vectortiles-plugin.zip -d $JETTY_BASE/webapps/geoserver/WEB-INF/lib/ && \
    curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}-pyramid-plugin.zip/download > /tmp/pyramid-plugin.zip && \
    unzip -o /tmp/pyramid-plugin.zip -d $JETTY_BASE/webapps/geoserver/WEB-INF/lib/ && \
    curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}-inspire-plugin.zip/download > /tmp/inspire-plugin.zip && \
    unzip -o /tmp/inspire-plugin.zip -d $JETTY_BASE/webapps/geoserver/WEB-INF/lib/ && \
    curl -L https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}.${GEOSERVER_MINOR_VERSION}-libjpeg-turbo-plugin.zip/download > /tmp/libjpeg-turbo-plugin.zip && \
    unzip -o /tmp/libjpeg-turbo-plugin.zip -d $JETTY_BASE/webapps/geoserver/WEB-INF/lib/ && \
    # Install MapBox Styling plugin
    # from GS site
    curl -L https://build.geoserver.org/geoserver/${GEOSERVER_VERSION}.x/ext-latest/geoserver-${GEOSERVER_VERSION}-SNAPSHOT-mbstyle-plugin.zip > /tmp/mbstyle-plugin.zip && \
    unzip -o /tmp/mbstyle-plugin.zip -d $JETTY_BASE/webapps/geoserver/WEB-INF/lib/ &&\
    rm /tmp/*.zip

# Install native JAI  https://geoserver.geo-solutions.it/multidim/install_run/jai_io_install.html
RUN wget http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz && \
    tar xzf jai-1_1_3-lib-linux-amd64.tar.gz -C /tmp && \
    mv -v /tmp/jai-1_1_3/lib/* $JETTY_BASE/lib/ext/ && \
    rm -r /tmp/jai-1_1_3 jai-1_1_3-lib-linux-amd64.tar.gz
RUN wget http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz && \
    tar xzf jai_imageio-1_1-lib-linux-amd64.tar.gz -C /tmp && \
    mv -v /tmp/jai_imageio-1_1/lib/* $JETTY_BASE/lib/ext/ && \
    rm -r /tmp/jai_imageio-1_1 jai_imageio-1_1-lib-linux-amd64.tar.gz

# JVM var java.library.path will be based on this env var. so GS will search native libs there.
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/libjpeg-turbo/lib64/:$JETTY_BASE/lib/ext/"

# the servlets jetty module contains CORS filters
RUN java -jar "$JETTY_HOME/start.jar" --add-module=servlets

# since we are on JDK11 and inside a container, see also option -XX:MaxRAMPercentage instead of Xms/Xmx
ENV JAVA_OPTIONS "-Xms$XMS -Xmx$XMX \
 -DGEOSERVER_DATA_DIR=/mnt/geoserver_datadir \
 -DGEOWEBCACHE_CACHE_DIR=/mnt/geoserver_tiles \
 -DENABLE_JSONP=true \
 -DALLOW_ENV_PARAMETRIZATION=true \
 -Dorg.geotools.coverage.jaiext.enabled=true \
 -XX:SoftRefLRUPolicyMSPerMB=36000 \
 -XX:-UsePerfData "

# Use min data dir template
USER jetty
COPY min_data_dir/ /mnt/geoserver_datadir/
USER root
RUN chown -R jetty:jetty /mnt/geoserver_datadir/*

VOLUME [ "/mnt/geoserver_datadir", "/mnt/geoserver_geodata", "/mnt/geoserver_tiles", "/tmp" ]
