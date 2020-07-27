FROM ubuntu:18.04

RUN apt-get update \
  && apt-get install -y python3-pip python3-dev curl\
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

COPY requirements.txt /tmp/

RUN pip3 install --no-cache-dir -r /tmp/requirements.txt

RUN curl -s -L https://clis.ng.bluemix.net/download/bluemix-cli/1.1.0/linux64 -o ibmcloud-linux64.tar.gz && \
  tar -xf ibmcloud-linux64.tar.gz && \
  ./Bluemix_CLI/install && \
  rm -Rf ibmcloud-linux64.tar.gz && \
  ibmcloud plugin install power-iaas