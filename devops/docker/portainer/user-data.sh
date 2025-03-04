#! /bin/bash
# Install Docker
apt update -y
apt install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
# Install Docker Compose
apt install -y curl
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
# Verify installation
docker --version
docker-compose --version