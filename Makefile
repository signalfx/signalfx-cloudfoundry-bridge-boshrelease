BUILD_PUBLISH ?= False
BUILD_BRANCH ?= $(USER)
DOCKER_IMAGE := quay.io/signalfuse/cloudfoundry-bridge-boshrelease-build:$(BUILD_BRANCH)
TILE_VERSION := $(shell tr -d '\n' < VERSION)
DOCKER_RUN := docker run -v $(PWD):/opt/bosh-release -it --rm $(DOCKER_IMAGE)
RELEASE_VERSION := $(shell ./latest-release)
BRIDGE_SRC_DIR ?= $(GOPATH)/src/github.com/signalfx/signalfx-cloudfoundry-bridge

clean:
	rm -rf build .dev_builds dev_releases product

build-image:
	# Pull latest before doing build so that if it's already been
	# built we don't try to rebuild it in make-deps. Image may not
	# yet exist so ignore errors. Would be better to actually check
	# explicitly for existence as this could cover up things like
	# network errors.
	docker pull $(DOCKER_IMAGE) || true

	docker build -t $(DOCKER_IMAGE) .
ifeq ($(BUILD_PUBLISH), True)
	docker push $(DOCKER_IMAGE)
endif

upload-blobs: build-image
	$(DOCKER_RUN) bosh add-blob bridge-linux-amd64 signalfx_bridge/bridge-linux-amd64
	#$(DOCKER_RUN) bosh upload-blobs

final-release: build-image bridge-binary
	rm -rf .dev_builds
	@$(MAKE) upload-blobs
	mkdir -p tmp
	rm -f tmp/release.tgz
	$(DOCKER_RUN) bosh create-release --final --tarball tmp/release.tgz --name signalfx-bridge --version $(TILE_VERSION) --force

# This target will only update the tile if the tile.yml file changed but won't
# make a new final release
product/signalfx-bridge-$(TILE_VERSION).pivotal: build-image tile.yml final-release
	mkdir -p product
	$(DOCKER_RUN) tile build $(TILE_VERSION)

ifeq ($(BUILD_PUBLISH), True)
	aws s3 cp product/*.pivotal s3://signalfx-cloudfoundry/builds/ \
		--cache-control="max-age=0, no-cache" \
		--acl private
endif

# This target will make always make a new final release
tile: product/signalfx-bridge-$(TILE_VERSION).pivotal

push-tile-to-pcf: product/signalfx-bridge-$(TILE_VERSION).pivotal
	pcf import $^
	pcf install signalfx-bridge $(TILE_VERSION)

bridge-binary:
	mkdir -p tmp
	# This assumes you have the bridge app installed in the BRIDGE_SRC_DIR,
	# which can be set by an envvar
	@$(MAKE) -C $(BRIDGE_SRC_DIR)
	cp $(BRIDGE_SRC_DIR)/signalfx-bridge-linux-amd64 bridge-linux-amd64

bosh-dev-deploy:
	bosh create-release --force
	bosh -e bosh-lite upload-release --fix
	bosh -e bosh-lite -d bridge deploy manifest/bridge.yml

.PHONY: clean build-and-push bridge-binary build-image bosh-dev-release tile
