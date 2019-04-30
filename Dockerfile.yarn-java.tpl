ENV DEBIAN_FRONTEND noninteractive

ENV CORRETTO_URL 'https://d3pxv6yz143wms.cloudfront.net/8.212.04.2/java-1.8.0-amazon-corretto-jdk_8.212.04-2_amd64.deb'
ENV CORRETTO_SHA256SUM 'c56c10948507445e43d7b700d23f1cd25a8a1bb10d9192929321819cc8ec8659'

RUN true \
  && cd /tmp \
  && curl -L -o /tmp/corretto-jdk.deb "${CORRETTO_URL}" \
  && echo "${CORRETTO_SHA256SUM}" /tmp/corretto-jdk.deb | sha256sum -c - \
  && apt-get update && sudo apt-get -y install --no-install-recommends --no-install-suggests java-common \
  && dpkg -i /tmp/corretto-jdk.deb \
  && rm -f /tmp/corretto-jdk.deb \
  && rm -rf /var/lib/apt/lists/*;

RUN bash -c 'echo en_US UTF-8 >> /etc/locale.gen' && locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LC_ALL='en_US.UTF-8' LANGUAGE='en_US.UTF-8'
ENV JAVA_HOME '/usr/lib/jvm/java-1.8.0-amazon-corretto/'
