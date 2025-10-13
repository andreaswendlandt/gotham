FROM ubuntu:18.04
USER root
ARG DEBIAN_FRONTEND=noninteractive
RUN ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    apt-get update && \
    apt-get install -y shellcheck && \
    apt-get install -y openjdk-17-jdk && \
    apt-get install -y curl && \
    apt-get install -y vim && \
    apt-get install -y iputils-ping && \
    apt-get install -y dnsutils && \
    apt-get install -y git && \
    apt-get install -y tzdata && \
    apt-get install -y mysql-server && \
    apt-get install -y mysql-client && \
    apt-get install -y apache2 && \
    apt-get install -y php && \
    apt-get install -y net-tools && \
    apt-get install -y php-mysql && \
    apt-get install -y mailutils && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/archive/* /var/lib/apt/lists/* && \
    rm -rf /bin/sh && \
    ln -s /bin/bash /bin/sh
CMD /opt/start.sh
