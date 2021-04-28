FROM debian:buster-slim

ARG TERRAFORM_VERSION=0.15.0
ARG HELM_VERSION=3.5.4
ARG KUBECTL_VERSION=1.21.0
ARG SOPS_VERSION=3.7.1

#Download and install Terraform
RUN apt update && \
    apt install -y curl jq python3 bash ca-certificates git openssl unzip wget golang git-lfs && \
    cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin 

#Install google cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt-get install -y apt-transport-https gnupg && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && apt-get install google-cloud-sdk -y
    
#Install kubectl
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl 

#Install aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip

#Install helm
RUN wget -q https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm

#Install helm s3
RUN helm plugin install https://github.com/hypnoglow/helm-s3.git

#Install SOPS
RUN export GOPATH="$HOME/go" && \
    wget https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops_${SOPS_VERSION}_amd64.deb && \
    dpkg -i sops_${SOPS_VERSION}_amd64.deb && \
    rm sops_${SOPS_VERSION}_amd64.deb

#Install docker
RUN apt install -y gnupg2 software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt update && apt install -y docker-ce 

#Install postgresql client 
RUN apt install -y postgresql-client

# Install mongodb 
RUN wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian10-x86_64-100.3.1.deb && \
    dpkg -i mongodb-database-tools-debian10-x86_64-100.3.1.deb && \
    rm mongodb-database-tools-debian10-x86_64-100.3.1.deb
    
#Clean up
RUN apt autoremove && \
    apt clean && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*
