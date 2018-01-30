FROM buildpack-deps:trusty

RUN deps='jq xz-utils' \
    && set -x \
    && apt-get update && apt-get install -y $deps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/local/bin/start /start \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys 94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys FD3A5288F042B6850C66B31F09FE44734EB7990E \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys 71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys 56730D5401028683275BD23C23EFEFE93C4CFFFE \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys 77984A986EBC2AA786BC0F66B01FBB92821C587A

COPY bin/* /usr/local/bin/

ENTRYPOINT ["/start"]
CMD ["/bin/bash"]

WORKDIR /app

ONBUILD ARG RANCH_BUILD_ENV

ONBUILD COPY package.json npm-shrinkwrap.json .npmrc /app/
ONBUILD RUN eval `ranch_build_env` \
  && install_nodejs `cat package.json | jq -r '.engines.node'` \
  && install_npm `cat package.json | jq -r '.engines.npm'` \
  && npm-production install --unsafe-perm --userconfig /app/.npmrc

ONBUILD COPY . /app/

ONBUILD ENV HOME=/app
ONBUILD ENV BABEL_DISABLE_CACHE=1

