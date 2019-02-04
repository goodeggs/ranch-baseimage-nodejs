.PHONY: all build release

IMAGE := goodeggs/ranch-baseimage-nodejs
VERSION := $(shell cat VERSION)
MAJOR_VERSION := $(shell awk -F. '{print $$1}' VERSION)
MINOR_VERSION := $(shell awk -F. '{print $$2}' VERSION)

all: build

build: build-yarn-base build-yarn build-yarn-java

build-yarn-base:
	docker build -t $(IMAGE):yarn-base .

build-yarn: build-yarn-base
	echo "FROM $(IMAGE):yarn-base" > Dockerfile.yarn
	cat Dockerfile.onbuild.tpl >> Dockerfile.yarn
	docker build -t $(IMAGE):yarn -f Dockerfile.yarn .

build-yarn-java: build-yarn-base
	echo "FROM $(IMAGE):yarn-base" > Dockerfile.yarn-java
	cat Dockerfile.yarn-java.tpl >> Dockerfile.yarn-java
	cat Dockerfile.onbuild.tpl >> Dockerfile.yarn-java
	docker build -t $(IMAGE):yarn-java -f Dockerfile.yarn-java .

release: build
	#( git diff --quiet && git diff --cached --quiet ) || ( echo "checkout must be clean"; false )
	for tag in yarn yarn-java; do \
		docker run -ti -v /var/run/docker.sock:/var/run/docker.sock goodeggs/docker-squash $(IMAGE):$$tag ; \
		docker push $(IMAGE):$$tag ; \
		docker tag $(IMAGE):$$tag $(IMAGE):$(VERSION)-$$tag ; \
		docker push $(IMAGE):$(VERSION)-$$tag ; \
		docker tag $(IMAGE):$$tag $(IMAGE):$(MAJOR_VERSION).$(MINOR_VERSION)-$$tag ; \
		docker push $(IMAGE):$(MAJOR_VERSION).$(MINOR_VERSION)-$$tag ; \
		docker tag $(IMAGE):$$tag $(IMAGE):$(MAJOR_VERSION)-$$tag ; \
		docker push $(IMAGE):$(MAJOR_VERSION)-$$tag ; \
	done

test: build
	./test.sh
