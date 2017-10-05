.PHONY: all build release

IMAGE := goodeggs/ranch-baseimage-nodejs
TAG_SUFFIX := "-yarn"
VERSION := $(shell cat VERSION)
MAJOR_VERSION := $(shell awk -F. '{print $$1}' VERSION)
MINOR_VERSION := $(shell awk -F. '{print $$2}' VERSION)

all: build

build:
	docker build -t $(IMAGE):latest$(TAG_SUFFIX) .

release: build
	echo $(VERSION)
	echo $(MAJOR_VERSION)
	echo $(MINOR_VERSION)
	( git diff --quiet && git diff --cached --quiet ) || ( echo "checkout must be clean"; false )
	docker run -ti -v /var/run/docker.sock:/var/run/docker.sock goodeggs/docker-squash $(IMAGE):latest$(TAG_SUFFIX)
	docker push $(IMAGE):latest$(TAG_SUFFIX)
	docker tag $(IMAGE):latest$(TAG_SUFFIX) $(IMAGE):$(VERSION)$(TAG_SUFFIX)
	docker push $(IMAGE):$(VERSION)$(TAG_SUFFIX)
	docker tag $(IMAGE):latest$(TAG_SUFFIX) $(IMAGE):$(MAJOR_VERSION).$(MINOR_VERSION)$(TAG_SUFFIX)
	docker push $(IMAGE):$(MAJOR_VERSION).$(MINOR_VERSION)$(TAG_SUFFIX)
	docker tag $(IMAGE):latest$(TAG_SUFFIX) $(IMAGE):$(MAJOR_VERSION)$(TAG_SUFFIX)
	docker push $(IMAGE):$(MAJOR_VERSION)$(TAG_SUFFIX)

test: build
	./test.sh

