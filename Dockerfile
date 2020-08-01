FROM ubuntu:latest

# Perform apt installations on this layer
# 'groff' is needed for awscli

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y \
    curl \
    sudo \
    gpg \
    git \
    dnsutils \
    vim \
    net-tools \
    bash-completion \
    python3-pip \
    groff \
    zip \
    gzip \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and perform pip installations
RUN pip3 install --upgrade pip && pip install awscli --use-feature=2020-resolver
RUN pip install azure-cli --use-feature=2020-resolver

# Install tools from other images
COPY --from=alpine/terragrunt:latest /bin/terraform /usr/local/bin/terraform
COPY --from=alpine/terragrunt:latest /usr/local/bin/terragrunt /usr/local/bin/terragrunt
COPY --from=fluxcd/helm-operator:1.2.0 /usr/local/bin/helm3 /usr/local/bin/helm
COPY --from=fluxcd/helm-operator:1.2.0 /usr/local/bin/helm2 /usr/local/bin/helm2
COPY --from=fluxcd/helm-operator:1.2.0 /usr/local/bin/kubectl /usr/local/bin/kubectl

# Create developer user and persistent volumes
RUN useradd developer && echo "developer:developer" | chpasswd && adduser developer sudo && usermod -d /workspace developer
RUN echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer
RUN kubectl completion bash >/etc/bash_completion.d/kubectl
RUN helm completion bash >/etc/bash_completion.d/helm
RUN terraform -install-autocomplete
RUN mkdir -p /workspace && cp /root/.bashrc /workspace
RUN mkdir -p /workspace/.kube && touch /workspace/.kube/config
RUN chown -R developer:developer /workspace
VOLUME [ "/workspace" ]

USER developer
WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]
