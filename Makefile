SHELL = /bin/bash
GO = go
GOFMT = gofmt -l
GOLINT = golint
GOTEST = $(GO) test --cover --race -v
GOVET = $(GO) vet
GO_FILES = $(wildcard *.go)
GO_PACKAGES = logbomb
GO_PACKAGES_REPO_PATH = $(addprefix $(REPO_PATH)/,$(GO_PACKAGES))

# the filepath to this repository, relative to $GOPATH/src
REPO_PATH = github.com/deis/logbomb

# The following variables describe the containerized development environment
# and other build options
DEV_ENV_IMAGE := quay.io/deis/go-dev:0.13.0
DEV_ENV_WORK_DIR := /go/src/${REPO_PATH}
DEV_ENV_OPTS := --rm -v ${CURDIR}:${DEV_ENV_WORK_DIR} -w ${DEV_ENV_WORK_DIR}
DEV_ENV_CMD := docker run ${DEV_ENV_OPTS} ${DEV_ENV_IMAGE}
DEV_ENV_CMD_INT := docker run -it ${DEV_ENV_OPTS} ${DEV_ENV_IMAGE}
LDFLAGS := "-s -X main.version=${VERSION}"

BINARY_DEST_DIR = rootfs/opt/logbomb/sbin

DOCKER_HOST = $(shell echo $$DOCKER_HOST)
BUILD_TAG ?= git-$(shell git rev-parse --short HEAD)
SHORT_NAME ?= logbomb
DEIS_REGISTRY ?= ${DEV_REGISTRY}
IMAGE_PREFIX ?= deis

include versioning.mk

NSQ_CONTAINER_NAME := test-nsq-${VERSION}

check-docker:
	@if [ -z $$(which docker) ]; then \
	  echo "Missing docker client which is required for development"; \
	  exit 2; \
	fi

# Allow developers to step into the containerized development environment
dev: check-docker
	${DEV_ENV_CMD_INT} bash

# Containerized dependency resolution
bootstrap: check-docker
	${DEV_ENV_CMD} glide install

# This is so you can build the binary without using docker
build-binary:
	GOOS=linux GOARCH=amd64 go build -ldflags ${LDFLAGS} -o $(BINARY_DEST_DIR)/logbomb .

build: docker-build
build-without-container: build-binary build-image
push: docker-push
upgrade: kube-update
install: kube-install
uninstall: kube-delete

# Containerized build of the binary
build-with-container: check-docker
	mkdir -p ${BINARY_DEST_DIR}
	${DEV_ENV_CMD} make build-binary

docker-build: build-with-container build-image

build-image:
	docker build -t ${IMAGE} rootfs
	docker tag ${IMAGE} ${MUTABLE_IMAGE}

clean: check-docker
	docker rmi $(IMAGE)

update-manifests:
	sed 's#\(image:\) .*#\1 $(IMAGE)#' manifests/deis-logbomb-job.yaml > manifests/deis-logbomb-job.tmp.yaml

test: test-style test-unit

test-style: check-docker
	${DEV_ENV_CMD} make style-check

style-check:
# display output, then check
	$(GOFMT) $(GO_PACKAGES) $(GO_FILES)
	@$(GOFMT) $(GO_PACKAGES) $(GO_FILES) | read; if [ $$? == 0 ]; then echo "gofmt check failed."; exit 1; fi
	$(GOVET) $(REPO_PATH) $(GO_PACKAGES_REPO_PATH)
	$(GOLINT) ./logbomb
	$(GOLINT) .

start-test-nsq:
	docker run --name ${NSQ_CONTAINER_NAME} -d nsqio/nsq:v0.3.8 /nsqd

stop-test-nsq:
	docker kill ${NSQ_CONTAINER_NAME}
	docker rm ${NSQ_CONTAINER_NAME}

test-unit: start-test-nsq
	docker run ${DEV_ENV_OPTS} \
		-it \
		--link ${NSQ_CONTAINER_NAME}:TEST_NSQ \
		${DEV_ENV_IMAGE} bash -c 'DEIS_NSQD_SERVICE_HOST=$$TEST_NSQ_PORT_4150_TCP_ADDR \
		DEIS_NSQD_SERVICE_PORT_TRANSPORT=$$TEST_NSQ_PORT_4150_TCP_PORT \
		$(GOTEST) -tags="testnsq" $$(glide nv)' \
		|| (make stop-test-nsq && false)
	make stop-test-nsq

kube-install:
	kubectl create -f manifests/deis-logbomb-rc.yaml

kube-delete:
	kubectl delete -f manifests/deis-logbomb-rc.tmp.yaml

kube-create: update-manifests
	kubectl create -f manifests/deis-logbomb-rc.tmp.yaml

kube-replace: build push update-manifests
	kubectl replace --force -f manifests/deis-logbomb-rc.tmp.yaml

kube-update: update-manifests
	kubectl delete -f manifests/deis-logbomb-rc.tmp.yaml
	kubectl create -f manifests/deis-logbomb-rc.tmp.yaml
