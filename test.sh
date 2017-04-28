#!/usr/bin/env bash
set -e
set -o pipefail

image_id="$1"

if [[ -z "$image_id" ]]; then
  docker build -t goodeggs/ranch-baseimage-nodejs:latest .
  
  cd "$(mktemp -d)"
  
  cat > Dockerfile <<EOF
FROM goodeggs/ranch-baseimage-nodejs:latest
EOF
  
  cat > package.json <<EOF
{
  "name": "foo",
  "version": "1.0.0",
  "dependencies": {
    "chicken-hatchling": "*"
  },
  "scripts": {
    "start": "echo hello world",
    "postinstall": "touch postinstall-done"
  }
}
EOF
  
  touch .npmrc
  touch random_file
  
  cat > npm-shrinkwrap.json <<EOF
{
  "name": "foo",
  "version": "1.0.0",
  "dependencies": {
    "chicken-hatchling": {
      "version": "0.0.1-chicken",
      "from": "chicken-hatchling@*",
      "resolved": "https://registry.npmjs.org/chicken-hatchling/-/chicken-hatchling-0.0.1-chicken.tgz"
    }
  }
}
EOF
  
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
  assert_equal "npm postinstall script runs" "$(run test -f /app/postinstall-done || echo fail)" ""

  exit $exitcode
}

main
