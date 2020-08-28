FROM ubuntu:focal

# Perform apt installations on this layer
# 'groff' is needed for awscli

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y \
    curl \
    gpg \
    git \
    vim \
    bash-completion \
    python3-pip \
    zip \
    gzip \
    tmux \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and perform pip installations
RUN pip3 install --upgrade pip && pip install azure-cli --use-feature=2020-resolver

# Install tools from other images
COPY --from=alpine/terragrunt:0.13.0 /bin/terraform /usr/local/bin/terraform
COPY --from=alpine/terragrunt:0.13.0 /usr/local/bin/terragrunt /usr/local/bin/terragrunt
COPY --from=alpine/helm:3.2.4 /usr/bin/helm /usr/local/bin/helm
COPY --from=bitnami/kubectl:latest /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/kubectl

# Create developer user and persistent volumes
RUN kubectl completion bash >/etc/bash_completion.d/kubectl
RUN helm completion bash >/etc/bash_completion.d/helm
RUN terraform -install-autocomplete

# Create blank kubeconfig and parent directory
RUN mkdir -p /root/.kube && touch /root/.kube/config

ENTRYPOINT ["/bin/bash"]
