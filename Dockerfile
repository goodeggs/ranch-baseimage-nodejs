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

ONBUILD ARG RANCH_BUILD_ENV

ONBUILD COPY package.json npm-shrinkwrap.json .npmrc /app/
ONBUILD RUN eval `ranch_build_env` \
  && install_nodejs `cat package.json | jq -r '.engines.node'` \
  && install_npm `cat package.json | jq -r '.engines.npm'` \
  && npm-production install --unsafe-perm --userconfig /app/.npmrc

ONBUILD COPY . /app/

ONBUILD ENV HOME=/app
ONBUILD ENV BABEL_DISABLE_CACHE=1

