FROM buildpack-deps:trusty

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do \
    gpg --keyserver pool.sks-keyservers.net --recv-keys "$key"; \
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

ARG RANCH_BUILD_ENV
ONBUILD ARG RANCH_BUILD_ENV

ONBUILD COPY package.json yarn.lock .npmrc /app/
ONBUILD RUN eval `ranch_build_env` \
  && install_nodejs `cat package.json | jq -r '.engines.node'` \
  && install_yarn `cat package.json | jq -r '.engines.yarn'` \
  && yarn-production --userconfig /app/.npmrc

ONBUILD COPY . /app/

ONBUILD ENV HOME=/app

