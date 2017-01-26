.PHONY: all build release

GIT_SHA := $(shell git rev-parse --short HEAD)

all: build

build:
	docker build -t goodeggs/ranch-baseimage-nodejs .

release:
	( git diff --quiet && git diff --cached --quiet ) || ( echo "checkout must be clean"; false )
	docker build -t goodeggs/ranch-baseimage-nodejs:$(GIT_SHA) .
	docker push goodeggs/ranch-baseimage-nodejs:$(GIT_SHA)

test:
	./test.sh

