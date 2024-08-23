# Author Phong
# Version 1.1
#
# Logs:
# 1.1 - Fixed AppStream issue and defined centos version
#
# License server for RLM License server

ARG FASTX3_SHA256=082a92fb0b335cd3a792837266f4f886d3fc4639eecbf4780dcca45a4025dc0a


# Pull base image
FROM centos:centos8.4.2105

# Configuration
ARG FASTX3_SHA256
## Fix AppStream URL error
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

## Installing dependencies
RUN yum update -y && \
    yum install  -y wget bash && \
    yum clean all

## Adding RLM user with lockdown cmd
RUN useradd -u 9001 -c "RLM Service Account" -U -d /opt/rlm -m -s /bin/bash rlm


# Install & Configure RLM license server as user rlm
USER rlm
WORKDIR /opt/rlm
RUN wget --no-check-certificate -P /tmp https://www.starnet.com/files/private/RLM/rlm.x64_l.tar.gz && \
    echo "$FASTX3_SHA256 /tmp/rlm.x64_l.tar.gz" | sha256sum -c - | grep OK && \
    tar -xvf /tmp/rlm.x64_l.tar.gz --directory /opt/ && \
    rm -f /tmp/rlm.x64_l.tar.gz && \
    echo "changeme_with_hash_password" > /opt/rlm/rlm.pw

# Add start script
USER root
COPY --chown=rlm:rlm ./start.sh /opt/rlm/start.sh
RUN chmod +x /opt/rlm/start.sh

# Add license file
COPY --chown=rlm:rlm /license /opt/rlm/license

# License server
EXPOSE 5053
# WebGUI server
EXPOSE 5054
# StarNet server
EXPOSE 57889


USER rlm
CMD ["/opt/rlm/start.sh"]
