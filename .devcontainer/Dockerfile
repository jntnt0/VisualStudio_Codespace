# .devcontainer/Dockerfile
# syntax = docker/dockerfile:1.3

# 1. Base image with Ubuntu + Docker tooling
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# 2. Install Azure CLI
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl apt-transport-https lsb-release gnupg \
    && curl -sL https://packages.microsoft.com/keys/microsoft.asc \
       | gpg --dearmor > microsoft.gpg \
    && install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/ \
    && echo "deb [arch=$(dpkg --print-architecture) \
       signed-by=/usr/share/keyrings/microsoft.gpg] \
       https://packages.microsoft.com/repos/azure-cli/ \
       $(lsb_release -cs) main" \
       > /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends azure-cli \
    && rm -rf /var/lib/apt/lists/* microsoft.gpg

# 3a. Install PowerShell runtime
RUN apt-get update \
    && apt-get install -y --no-install-recommends wget \
    && wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell \
    && rm -rf /var/lib/apt/lists/* packages-microsoft-prod.deb

# 3b. Cache and install Az PowerShell modules
RUN --mount=type=cache,target=/usr/share/powershell/Modules \
    pwsh -Command "Install-Module -Name Az -RequiredVersion 9.7.0 \
      -Scope AllUsers -Force -AllowClobber"

# 4. Switch default shell to PowerShell
SHELL ["pwsh", "-NoLogo", "-ExecutionPolicy", "Bypass", "-Command"]
