.PHONY: all build release test

GIT_SHA := $(shell git rev-parse --short HEAD)

all: build

build:
	docker build -t goodeggs/ranch-baseimage-nodejs .

release:
	( git diff --quiet && git diff --cached --quiet ) || ( echo "checkout must be clean"; false )
	docker build -t goodeggs/ranch-baseimage-nodejs:$(GIT_SHA) .
	docker push goodeggs/ranch-baseimage-nodejs:$(GIT_SHA)
	docker tag goodeggs/ranch-baseimage-nodejs:$(GIT_SHA) goodeggs/ranch-baseimage-nodejs:latest
	docker push goodeggs/ranch-baseimage-nodejs:latest

test: test_npm test_yarn

test_npm:
	./test/test_npm.sh

test_yarn:
	./test/test_yarn.sh
