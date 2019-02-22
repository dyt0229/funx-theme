# Variables
SERVICE:=funx-theme
PWD := $(shell pwd)
DEV_UI_IMAGE := registry.cn-beijing.aliyuncs.com/wa/dev:vue
IMG_HUB?=registry.cn-shenzhen.aliyuncs.com/funxdata
# Version information
VERSION=${shell cat VERSION 2> /dev/null}
RELEASE_VERSION ?= 0.0
RELEASE_BRANCH ?= release-${RELEASE_VERSION}

GIT_COMMIT := $(shell git rev-parse --short HEAD)
IMAGE := ${IMG_HUB}/${SERVICE}:${GIT_COMMIT}

env:
	npm config set strict-ssl false
	npm config set registry https://registry.npm.taobao.org
	npm config set sass-binary-site http://npm.taobao.org/mirrors/node-sass
	npm install

dev:
	docker run --rm -it \
	 --name $(SERVICE)-dev \
	 -p 80:80 \
	 -m 500M \
	 -v $(PWD):/opt/$(SERVICE) \
	 -w /opt/$(SERVICE) \
	 $(DEV_UI_IMAGE) bash

image:
	docker build -t $(IMG_HUB)/$(SERVICE):latest .

build: prod

prod: clean env
	npm run build

build-in-docker:
	-@docker rm -f $(SERVICE)-building
	@docker run --rm \
	 --name $(SERVICE)-building \
	 -v $(PWD):/opt/$(SERVICE) \
	 -w /opt/$(SERVICE) \
	 $(DEV_UI_IMAGE) make build

push: build-in-docker sync push-simple

build-simple:
	docker build -t ${IMAGE} -f Dockerfile.simple .

push-simple: build-simple
	docker push ${IMAGE}

build-prod-in-docker:
	@docker run --rm \
	 --name $(SERVICE)-prod-building \
	 -v $(PWD):/opt/$(SERVICE) \
	 -w /opt/$(SERVICE) \
	 $(DEV_UI_IMAGE) make prod

push-prod: build-prod-in-docker sync push-simple
	echo "push ${RELEASE_BRANCH} successful."

prod-image:
	docker build -t $(IMG_HUB)/$(SERVICE):$(VERSION) .

prod-push: prod-image
	docker push $(IMG_HUB)/$(SERVICE):$(VERSION)

clean: 
	-rm -rf .tmp
	-rm -rf dist
