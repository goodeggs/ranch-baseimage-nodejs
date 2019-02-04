
ARG RANCH_BUILD_ENV
ONBUILD ARG RANCH_BUILD_ENV

ONBUILD COPY package.json yarn.lock .npmrc /app/
ONBUILD RUN eval `ranch_build_env` \
  && install_nodejs `cat package.json | jq -r '.engines.node'` \
  && install_yarn `cat package.json | jq -r '.engines.yarn'` \
  && yarn-production --userconfig /app/.npmrc

ONBUILD COPY . /app/

ONBUILD ENV HOME=/app
ONBUILD ENV BABEL_DISABLE_CACHE=1
