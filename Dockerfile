FROM buildpack-deps:trusty

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

RUN deps='jq xz-utils' \
    && set -x \
    && apt-get update && apt-get install -y $deps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/local/bin/start /start

COPY bin/* /usr/local/bin/

ENTRYPOINT ["/start"]
CMD ["/bin/bash"]

WORKDIR /app

ONBUILD ARG RANCH_BUILD_ENV

ONBUILD COPY package.json .npm-shrinkwrap.json .npmrc /app/

ONBUILD RUN eval `ranch_build_env` \
  && export PACKAGE_JSON_ENGINE=`jq -r '.engines | keys | map(select(. != "node")) | .[0]' package.json` \
  && export PACKAGE_MANAGER=${PACKAGE_JSON_ENGINE:-npm} \
  && export PACKAGE_MANAGER_VERSION=$(jq -r ".engines.$PACKAGE_MANAGER" package.json)  \
  && install_nodejs `cat package.json | jq -r '.engines.node'` \
  && install_$PACKAGE_MANAGER  $PACKAGE_MANAGER_VERSION \
  && $PACKAGE_MANAGER-production install --unsafe-perm --userconfig /app/.npmrc

ONBUILD COPY . /app/

ONBUILD ENV HOME=/app

