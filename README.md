# ranch-baseimage-nodejs

A Docker base image for NodeJS apps.

## Prerequisites

Your app **must** contain three files in its root:

* `package.json`
* `npm-shrinkwrap.json`
* `.npmrc` _(can be blank)_

And you **must** pass a docker build arg called `RANCH_BUILD_ENV`. _(see below)_

## Usage

Create a `Dockerfile` in your app's root:

```dockerfile
FROM goodeggs/ranch-baseimage-nodejs:latest
# the rest is handled by ONBUILD instructions.
```

And the most basic build:

```
$ docker build --build-arg 'RANCH_BUILD_ENV={}' .
```

## How it works

The secret sauce here is to embrace Docker image layer caching behavior.  By adding `package.json`, `npm-shrinkwrap.json`, and `.npmrc` in a separate instruction, we will skip the entire `npm install` routine unless one of those files has changed.  (or the docker build cache is empty)

### Caveat

Your app runs as root inside the container.  The reason is a shortcoming of Docker: `COPY` and `ADD` instructions do not respect `USER` instructions, they always add files with `root` as the owner.  If we then `RUN chown -R app:app /app`, we end up with an entire new Docker layer and double the resulting image size.  This is unacceptable.

There is hope that Docker will address this, but work is frozen until they split the builder out.  See [docker/docker#13600](https://github.com/docker/docker/pull/13600#issuecomment-119381749) and the [Dockerfile syntax section of Docker's roadmap](https://github.com/docker/docker/blob/master/ROADMAP.md#22-dockerfile-syntax) for more details.

## Features

### Build-time variables

You can pass a list of environment variables encoded as a JSON object in a docker build arg called `RANCH_BUILD_ENV`.  A normal use of this is to pass a private NPM repository token for use during the `npm install` step.  It can be the empty string but you must pass it or docker will throw.

```
$ docker build --build-arg 'RANCH_BUILD_ENV={"NPM_AUTH":"sekret"}' .
```

### Node & NPM versions

During `docker build`, the `engines.node` and `engines.npm` properties will be read out of your `package.json` file, and the appropriate versions (including semver resolution) will be installed.

### Procfile support

The included `start` command takes a process name and parses `/app/Procfile`.  eg `start web` would find the line in your Procfile that starts with `web: `, and execute that command.

### env: WEB_CONCURRENCY

A cool feature inherited from the Heroku NodeJS Buildpack, the included `entrypoint` command will detect available memory (using cgroups), read the `WEB_MEMORY` environment variable set by you, and export a `WEB_CONCURRENCY` variable useful for things like NodeJS's cluster module.

### env: DYNO

Both the `entrypoint` and the `start` commands export reasonable values for the `DYNO` environment variable, mirroring a useful behavior of Heroku.  Instead of dyno index (eg `web.1`), we export the container hostname (eg `web.abcd3fg`).

