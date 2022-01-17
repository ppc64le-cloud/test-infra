FROM golang
WORKDIR /go/src/github.com/openshift
RUN git clone https://github.com/openshift/ci-search \
    && cd ci-search \
    && grep -rl origin-ci-test . | xargs sed -i 's/origin-ci-test/ppc64le-kubernetes/g' \
    && grep -rl "OpenShift" . | xargs sed -i 's/OpenShift/Kubernetes-ppc64le/g' \
    && grep -rl "prow\.ci\.openshift" . | xargs sed -i 's/prow\.ci\.openshift/prow\.ppc64le-cloud/g' \
    && make build

FROM centos:7
COPY --from=0 /go/src/github.com/openshift/ci-search/search /usr/bin/
RUN curl -L https://github.com/BurntSushi/ripgrep/releases/download/12.0.1/ripgrep-12.0.1-x86_64-unknown-linux-musl.tar.gz | \
    tar xvzf - --wildcards --no-same-owner --strip-components=1  -C /usr/bin '*/rg'
RUN mkdir /var/lib/ci-search && chown 1000:1000 /var/lib/ci-search && chmod 1777 /var/lib/ci-search
USER 1000:1000
ENTRYPOINT ["search"]
CMD ["--path=/var/lib/ci-search/", "--deck-uri=https://prow.ppc64le-cloud.org"]
EXPOSE 8080
