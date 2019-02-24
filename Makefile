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

build: prod

prod:
	npm run build

push: build publish

publish:
	npm publish
