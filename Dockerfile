FROM buildpack-deps:trusty

COPY bin/* /usr/local/bin/

RUN deps='jq xz-utils' \
    && set -x \
    && apt-get update && apt-get install -y $deps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/local/bin/start /start \
    && import-nodejs-team-keyring \
    && import-previous-nodejs-team-keyring

ENTRYPOINT ["/start"]
CMD ["/bin/bash"]

WORKDIR /app
