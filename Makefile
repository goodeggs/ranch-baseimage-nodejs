.PHONY: all build release

VERSION := $(shell cat VERSION)
MAJOR_VERSION := $(shell awk -F. '{print $$1}' VERSION)
MINOR_VERSION := $(shell awk -F. '{print $$2}' VERSION)

all: build

build:
	docker build -t goodeggs/ranch-baseimage-nodejs .

release:
	echo $(VERSION)
	echo $(MAJOR_VERSION)
	echo $(MINOR_VERSION)
	( git diff --quiet && git diff --cached --quiet ) || ( echo "checkout must be clean"; false )
	docker build --squash -t goodeggs/ranch-baseimage-nodejs:latest-yarn .
	docker push goodeggs/ranch-baseimage-nodejs:latest-yarn
	docker tag goodeggs/ranch-baseimage-nodejs:latest-yarn goodeggs/ranch-baseimage-nodejs:$(VERSION)-yarn
	docker push goodeggs/ranch-baseimage-nodejs:$(VERSION)-yarn
	docker tag goodeggs/ranch-baseimage-nodejs:latest-yarn goodeggs/ranch-baseimage-nodejs:$(MAJOR_VERSION).$(MINOR_VERSION)-yarn
	docker push goodeggs/ranch-baseimage-nodejs:$(MAJOR_VERSION).$(MINOR_VERSION)-yarn
	docker tag goodeggs/ranch-baseimage-nodejs:latest-yarn goodeggs/ranch-baseimage-nodejs:$(MAJOR_VERSION)-yarn
	docker push goodeggs/ranch-baseimage-nodejs:$(MAJOR_VERSION)-yarn

test:
	./test.sh

