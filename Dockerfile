FROM ubuntu:latest

# Perform apt installations on this layer
# 'groff' is needed for awscli

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
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
    gzip \
    tar \
 && rm -rf /var/lib/apt/lists/*

# Upgrade pip and perform pip installations
RUN pip3 install --upgrade pip && pip install awscli

# Install Tools
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
RUN VERSION=$(curl --silent "https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && curl -L https://github.com/gruntwork-io/terragrunt/releases/download/$VERSION/terragrunt_linux_amd64 --output /usr/local/bin/terragrunt && chmod +x /usr/local/bin/terragrunt

# Get latest terraform binary
## to set a specific version, change 'latest' tag to desired version
COPY --from=hashicorp/terraform:latest /bin/terraform /usr/local/bin/terraform

# Create developer user and persistent volumes
RUN useradd developer && echo "developer:developer" | chpasswd && adduser developer sudo && usermod -d /workspace developer
RUN echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer
RUN mkdir -p /workspace && cp /root/.bashrc /workspace
RUN chown -R developer:developer /workspace
VOLUME [ "/workspace" ]

USER developer
WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]
