# ranch-baseimage-nodejs

A Docker base image for NodeJS apps.

## Prerequisites

Your app **must** contain three files in its root:

* `package.json`
* `npm-shrinkwrap.json`
* `.npmrc` _(can be blank)_

## Usage

Create a `Dockerfile` for your app:

```dockerfile
FROM goodeggs/ranch-baseimage-nodejs:latest
# the rest is handled by ONBUILD instructions.
```

## How it works

The secret sauce here is to embrace Docker image layer caching behavior.  By adding `package.json`, `npm-shrinkwrap.json`, and `.npmrc` in a separate instruction, we will skip the entire `npm install` routine unless one of those files has changed.  (or the docker build cache is empty)

## Features

### Node & NPM Versions

During `docker build`, the `engines.node` and `engines.npm` properties will be read out of your `package.json` file, and the appropriate versions (including semver resolution) will be installed.

### Procfile support

The included `start` command takes a process name and parses `/app/Procfile`.  eg `start web` would find the line in your Procfile that starts with `web: `, and execute that command.

### env: WEB_CONCURRENCY

A cool feature inherited from the Heroku NodeJS Buildpack, the included `entrypoint` command will detect available memory (using cgroups), read the `WEB_MEMORY` environment variable set by you, and export a `WEB_CONCURRENCY` variable useful for things like NodeJS's cluster module.

### env: DYNO

Both the `entrypoint` and the `start` commands export reasonable values for the `DYNO` environment variable, mirroring a useful behavior of Heroku.  Instead of dyno index (eg `web.1`), we export the container hostname (eg `web.abcd3fg`).

