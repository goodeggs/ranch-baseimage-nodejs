#!/usr/bin/env bash
set -e
set -o pipefail

image_id="$1"

if [[ -z "$image_id" ]]; then
  make build-yarn

  cd "$(mktemp -d)"
  cat > Dockerfile <<EOF
FROM goodeggs/ranch-baseimage-nodejs:yarn
EOF

  cat > package.json <<EOF
{
  "name": "foo",
  "version": "1.0.0",
  "dependencies": {
    "chicken-hatchling": "^0.0.1-chicken"
  },
  "engines": {
    "yarn": "0.19.0"
  },
  "scripts": {
    "start": "echo hello world",
    "postinstall": "touch postinstall-done"
  }
}
EOF

  cat > yarn.lock <<EOF
chicken-hatchling@^0.0.1-chicken:
  version "0.0.1-chicken"
  resolved "https://registry.npmjs.org/chicken-hatchling/-/chicken-hatchling-0.0.1-chicken.tgz"
EOF


  touch .npmrc
  touch random_file

  docker build --build-arg 'RANCH_BUILD_ENV={}' . | tee docker.log

  image_id=$(tail -n1 docker.log | awk '{print $3}')
fi

function assert_equal {
  message=$1
  actual=$2
  expected=$3
  if [[ "$actual" == "$expected" ]]; then
    echo "PASS: ${message}"
  else
    echo "FAIL: ${message}, expected: '${expected}', got: '${actual}'"
    exitcode=1
  fi
}

function run {
  docker run --rm -i "$image_id" "$@"
}

function main {
  local exitcode=0

  assert_equal "/app/package.json is owned by root" "$(run stat -c %U /app/package.json)" "root"
  assert_equal "/app/random_file is owned by root" "$(run stat -c %U /app/random_file)" "root"
  assert_equal "user is root" "$(run whoami)" "root"
  assert_equal "'npm start' works" "$(run npm start | tail -n1)" "hello world"
  assert_equal "yarn runs npm postinstall script" "$(run test -f /app/postinstall-done || echo fail)" ""

  exit $exitcode
}

main
