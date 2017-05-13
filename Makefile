.PHONY: all build release

IMAGE := goodeggs/ranch-baseimage-nodejs
VERSION := $(shell cat VERSION)
MAJOR_VERSION := $(shell awk -F. '{print $$1}' VERSION)
MINOR_VERSION := $(shell awk -F. '{print $$2}' VERSION)
PATCH_VERSION := $(shell awk -F'[.-]' '{print $$3}' VERSION)
PRERELEASE_VERSION := $(shell awk -F'[.-]' '{print $$4}' VERSION)

all: build

build:
	docker build -t $(IMAGE):latest .

release: build
	( git diff --quiet && git diff --cached --quiet ) || ( echo "checkout must be clean"; false )
	docker run -ti -v /var/run/docker.sock:/var/run/docker.sock goodeggs/docker-squash $(IMAGE):latest
	docker tag $(IMAGE):latest $(IMAGE):$(VERSION)
	docker push $(IMAGE):$(VERSION)
	if [ -z "$(PRERELEASE_VERSION)" ]; then \
	  docker tag $(IMAGE):latest $(IMAGE):$(MAJOR_VERSION).$(MINOR_VERSION); \
	  docker push $(IMAGE):$(MAJOR_VERSION).$(MINOR_VERSION); \
	  docker tag $(IMAGE):latest $(IMAGE):$(MAJOR_VERSION); \
	  docker push $(IMAGE):$(MAJOR_VERSION); \
	  docker push $(IMAGE):latest; \
	else \
	  echo "prerelease version, skipping other tags & pushes"; \
	fi

test: build
	./test.sh

