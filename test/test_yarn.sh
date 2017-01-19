#!/usr/bin/env bash
set -o errexit    # always exit on error
set -o pipefail   # don't ignore exit codes when piping output
set -o nounset    # fail on unset variables

image_id=${1-""}

if [[ -z "$image_id" ]]; then
  docker build -t foo .

  cd `mktemp -d`

  cat > Dockerfile <<EOF
FROM foo
EOF

  cat > package.json <<EOF
{
  "name": "foo",
  "version": "1.0.0",
  "dependencies": {
    "chicken-hatchling": "*"
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
chicken-hatchling@~*:
  version "0.4.1"
  resolved "https://npm.goodeggs.com/chickenlatchling/-/chicken-hatchling-0.4.1.tgz#f8ab7e1f8418ce63cda6eb7bd778a85d7ec492b2"
EOF


  touch .npmrc
  touch random_file

  docker build --build-arg 'RANCH_BUILD_ENV={}' . | tee docker.log

  image_id=`tail -n1 docker.log | awk '{print $3}'`
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
  docker run --rm -i $image_id "$@"
}

function main {
  local exitcode=0

  assert_equal "/app/package.json is owned by root" "$(run stat -c %U /app/package.json)" "root"
  assert_equal "/app/random_file is owned by root" "$(run stat -c %U /app/random_file)" "root"
  assert_equal "user is root" "$(run whoami)" "root"
  assert_equal "'yarn' works" "$(run yarn | tail -n1)" "hello world"

  exit $exitcode
}

main
