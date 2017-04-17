FROM buildpack-deps:trusty

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

