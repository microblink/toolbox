FROM alpine:3.12.0

ARG TERRAFORM_VERSION=0.12.26
ARG HELM_VERSION=3.2.1
ARG KUBECTL_VERSION=1.18.0
ARG SOPS_VERSION=3.5.0

#Download and install Terraform
RUN apk update && \
    apk add curl jq python3 bash ca-certificates git openssl unzip wget go && \
    cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin 

#Install google cloud SDK
RUN curl -sSL https://sdk.cloud.google.com | bash

ENV PATH $PATH:/root/google-cloud-sdk/bin

#Install kubectl
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl 

#Install helm

RUN wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm

#Install SOPS

RUN export GOPATH=~/go && \
    go get -u go.mozilla.org/sops/v3/cmd/sops && \
    ln -s $GOPATH/bin/sops /usr/local/bin/
#Install docker

RUN apk add --update docker openrc && \
    rc-update add docker boot 

#Clean up
RUN rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/tmp/*