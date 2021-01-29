VERSION?=v20210126-f0baa5f3d9
UPSTREAM_REPO=gcr.io/k8s-prow
PRIVATE_REPO=quay.io/powercloud
ARCH?=amd64

ALL_ARCH = amd64 ppc64le

POD_UTILITIES = clonerefs initupload entrypoint sidecar

all-pull: $(addprefix sub-pull-,$(POD_UTILITIES))

sub-pull-%:
	docker pull ${UPSTREAM_REPO}/$*:${VERSION}

all-push: $(addprefix sub-push-,$(POD_UTILITIES))

sub-push-%:
	docker push ${PRIVATE_REPO}/$*:${ARCH}-${VERSION}

all-tag: $(addprefix sub-tag-,$(POD_UTILITIES))

sub-tag-%:
	docker tag ${UPSTREAM_REPO}/$*:${VERSION} ${PRIVATE_REPO}/$*:${ARCH}-${VERSION}

all-build: $(addprefix sub-build-,$(POD_UTILITIES))

sub-build-%:
	$(MAKE) ARCH=ppc64le utility-build-$*

utility-build-%:
	docker build --build-arg POD_UTILITY=$* --build-arg CO_COMMIT=$(lastword $(subst -, ,$(VERSION))) -t ${PRIVATE_REPO}/$*:${ARCH}-${VERSION} .

all-push-manifest: $(addprefix sub-push-manifest-,$(POD_UTILITIES))
export DOCKER_CLI_EXPERIMENTAL = enabled
sub-push-manifest-%:
	docker manifest create --amend $(PRIVATE_REPO)/$*:$(VERSION) $(shell echo $(ALL_ARCH) | sed -e "s~[^ ]*~$(PRIVATE_REPO)/$*:&\-$(VERSION)~g")
	@for arch in $(ALL_ARCH); do docker manifest annotate --arch $${arch} ${PRIVATE_REPO}/$*:${VERSION} ${PRIVATE_REPO}/$*:$${arch}-${VERSION}; done
	docker manifest push --purge ${PRIVATE_REPO}/$*:${VERSION}
