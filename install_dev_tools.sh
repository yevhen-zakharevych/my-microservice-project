#!/bin/bash

echo "Starting installation of development tools..."

# Update package list
apt-get update -y

# 1. Python Check and Install
echo "--- Checking Python ---"
if command -v python3 &>/dev/null; then
    echo "Python3 is already installed."
else
    echo "Installing Python3..."
    apt-get install -y python3 python3-pip
fi

# 2. Docker Check and Install
echo "--- Checking Docker ---"
if command -v docker &>/dev/null; then
    echo "Docker is already installed."
else
    echo "Installing Docker packages..."
    apt-get install -y ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    apt-get update
    apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin
    echo "Docker tools installed."
fi

# 3. Django Check and Install
echo "--- Checking Django ---"
if python3 -m django --version &>/dev/null; then
    echo "Django is already installed."
else
    echo "Installing Django..."
    pip3 install django --break-system-packages
    echo "Django installed."
fi

echo "Done."