ARG UBUNTU_VERSION=18.04
FROM ubuntu:${UBUNTU_VERSION}
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
# Installing pip3
RUN apt-get -y update && apt-get -y install \
      git \
      python3-pip \
      && pip3 install --upgrade pip
# Installing mkdocs version 1.0.4 and dependancies
ARG MKDOCS_VERSION=1.0.4
RUN pip3 install mkdocs==${MKDOCS_VERSION} pymdown-extensions \
    mkdocs-awesome-pages-plugin
RUN mkdir -p ~/.ssh
