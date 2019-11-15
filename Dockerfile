FROM ubuntu:latest

# Perform apt installations on this layer
# 'groff' is needed for awscli

RUN apt-get update && apt-get install -y \
    curl \
    sudo \
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
