file := version.txt
BAZEL_VERSIONS := $(shell cat ${file})
UBUNTU_VERSION = 16.04

REGISTRY=quay.io/powercloud
IMAGE=bazel

all-build:$(addprefix sub-build-,$(BAZEL_VERSIONS))

sub-build-%:
	docker build --build-arg BAZEL_VERSION=$* --build-arg UBUNTU_VERSION=$(UBUNTU_VERSION) -t $(REGISTRY)/$(IMAGE):$* .

all-push: $(addprefix sub-push-,$(BAZEL_VERSIONS))

sub-push-%:
	docker push $(REGISTRY)/$(IMAGE):$*
