FROM ubuntu:latest

# Perform apt installations on this layer
# 'groff' is needed for awscli

RUN apt-get update && apt-get install -y \
    curl \
    sudo \
    gpg \
    git \
    dnsutils \
    vim \
    net-tools \
    python3-pip \
    groff \
    zip \
    ca-certificates \
    apt-transport-https \
    lsb-release \
    gnupg \
    gzip \
    tar \
 && rm -rf /var/lib/apt/lists/*

# Upgrade pip and perform pip installations
RUN pip3 install --upgrade pip && pip install awscli

# Install Azure CLI
RUN pip3 install --upgrade pip && pip install awscli
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
RUN AZ_REPO=$(lsb_release -cs) echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
RUN apt-get update && apt-get install -y \
    azure-cli \
 && rm -rf /var/lib/apt/lists/*

# Get latest terraform binary
## to set a specific version, change 'latest' tag to desired version
COPY --from=hashicorp/terraform:latest /bin/terraform /bin/terraform

# Create developer user and persistent volumes
RUN useradd developer && echo "developer:developer" | chpasswd && adduser developer sudo && usermod -d /workspace developer
RUN echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer
RUN mkdir -p /workspace && cp /root/.bashrc /workspace
RUN chown -R developer:developer /workspace
VOLUME [ "/workspace" ]

USER developer
WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]