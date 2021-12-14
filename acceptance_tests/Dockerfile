FROM python:3.5

RUN pip install pytest==3.0.2 requests==2.11.1 netifaces==0.10.5

ARG DOCKER_COMPOSE_VERSION=1.24.1

RUN apt-get update && apt-get install -y lsb-release software-properties-common
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7EA0A9C3F273FCD8 && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*
RUN curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose && \
    chmod a+x /usr/bin/docker-compose

COPY . /acceptance_tests/

ENV DOCKER_RUN 1
WORKDIR /acceptance_tests
CMD py.test --junitxml /tmp/junitxml/results.xml
