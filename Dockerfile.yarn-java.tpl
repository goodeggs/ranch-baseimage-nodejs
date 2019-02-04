ENV DEBIAN_FRONTEND noninteractive
ENV JDK_CACHE_DIR /var/cache/oracle-jdk8-installer

# Oracle's download links are broken...
RUN true \
  && mkdir -p "$JDK_CACHE_DIR" \
  && cd "$JDK_CACHE_DIR" \
  && curl -LfO https://travis-utils.s3.amazonaws.com/jdk-8u171-linux-x64.tar.gz

# I hate doing PPAs but this one sucks less than others....
# It's a bit of a hack to install a xenial package into jessie, but it works reliably as it's
# limited to a wrapper for the jvm
RUN true && \
    apt-get update && \
    apt-get -y install --no-install-recommends --no-install-suggests python-software-properties software-properties-common && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get -y install ca-certificates-java && \
    bash -c 'debconf-set-selections <<< "oracle-java8-installer	oracle-java8-installer/not_exist	error"' && \
    bash -c 'debconf-set-selections <<< "oracle-java8-installer	shared/error-oracle-license-v1-1	error"' && \
    bash -c 'debconf-set-selections <<< "oracle-java8-installer	shared/present-oracle-license-v1-1	note"' && \
    bash -c 'debconf-set-selections <<< "oracle-java8-installer	shared/accepted-oracle-license-v1-1	boolean	true"' && \
    bash -c 'debconf-set-selections <<< "oracle-java8-installer	oracle-java8-installer/local	string	$JDK_CACHE_DIR"' && \
    apt-get -y install --no-install-recommends --no-install-suggests \
    oracle-java8-installer ant  \
    curl locales oracle-java8-set-default && \
    apt-get remove -y --purge python-software-properties software-properties-common && \
    update-ca-certificates -f && \
    apt-get remove -y --purge openjdk* && \
		rm -rf /var/lib/apt/lists/*;

RUN bash -c 'echo en_US UTF-8 >> /etc/locale.gen' && locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LC_ALL='en_US.UTF-8' LANGUAGE='en_US.UTF-8'

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
