FROM debian:7

ENV AEROSPIKE_VERSION 3.5.9
ENV AEROSPIKE_SHA256 2dacf055d49e62d8be0a2508c11334a52a95982dc8389a7a93d36019d600c32c 

ENV AMC_VERSION 3.6.0
ENV AMC_SHA256 e88092353a55f0d02f3d5712f100e2aefe6cb808dec032da5cee94991a5a2b37

RUN apt-get update -y \
    && apt-get install -y python python-dev gcc wget net-tools procps logrotate ca-certificates

# Install Aerospike Server
RUN \
    wget "https://www.aerospike.com/artifacts/aerospike-server-community/${AEROSPIKE_VERSION}/aerospike-server-community-${AEROSPIKE_VERSION}-debian7.tgz" -O aerospike-server.tgz \
    && echo "$AEROSPIKE_SHA256 *aerospike-server.tgz" | sha256sum -c - \
    && mkdir aerospike \
    && tar xzf aerospike-server.tgz --strip-components=1 -C aerospike \
    && cd aerospike \
    && ./asinstall \
    && cd ..

# Install Aerospike Management Console
RUN \
    wget "http://www.aerospike.com/download/amc/${AMC_VERSION}/artifact/debian6" -O aerospike-amc-community.deb \
    && echo "$AMC_SHA256 *aerospike-amc-community.deb" | sha256sum -c - \
    && dpkg -i aerospike-amc-community.deb

# Uninstall stuff
RUN \
    apt-get purge -y --auto-remove wget ca-certificates \
    && rm -rf aerospike-amc-community.deb aerospike-server.tgz aerospike /var/lib/apt/lists/*

ADD aerospike.conf /etc/aerospike/aerospike.conf

# Expose Aerospike & AMC ports
#
#   3000 – service port, for client connections
#   3001 – fabric port, for cluster communication
#   3002 – mesh port, for cluster heartbeat
#   3003 – info port
#   8081 - AMC port
#
EXPOSE 3000 3001 3002 3003 8081

# Execute the run script in foreground mode
CMD ["/bin/bash", "-c", "service amc start && /usr/bin/asd --foreground"]
