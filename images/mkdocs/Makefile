file := version.txt
MKDOCS_VERSION := $(shell cat ${file})
UBUNTU_VERSION = 18.04

REGISTRY=quay.io/powercloud
IMAGE=mkdocs

all-build:$(addprefix sub-build-,$(MKDOCS_VERSION))

sub-build-%:
	docker build --build-arg MKDOCS_VERSION=$* --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) -t $(REGISTRY)/$(IMAGE):$* .

all-push: $(addprefix sub-push-,$(MKDOCS_VERSION))

sub-push-%:
	docker push $(REGISTRY)/$(IMAGE):$*
