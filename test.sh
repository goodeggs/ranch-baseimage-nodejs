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
  
  image_id=`tail -n1 docker.log | awk '{print $3}'`
fi

function assert_equal {
  message=$1
  actual=$2
  expected=$3
  [[ "$actual" == "$expected" ]] || ( echo "FAIL: ${message}, expected: '${expected}', got: '${actual}'"; exit 1 )
}

function run {
  docker run --rm -i $image_id "$@"
}

assert_equal "/app/package.json is owned by app" `run stat -c %U /app/package.json` "app"
assert_equal "/app/random_file is owned by app" `run stat -c %U /app/random_file` "app"

