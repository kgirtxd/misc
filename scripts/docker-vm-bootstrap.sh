#!/bin/bash
set -euo pipefail

echo "🛠️ Updating system..."
apt update && apt upgrade -y

echo "🧰 Installing dependencies..."
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    ufw \
    fail2ban \
    jq

echo "🐳 Adding Docker GPG key and repo..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "✅ Docker installed."

echo "📛 Disabling swap (Swarm hates swap)..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "🔐 Configuring firewall..."
ufw allow OpenSSH
ufw allow 2377/tcp  # swarm cluster
ufw allow 7946/tcp  # overlay network
ufw allow 7946/udp
ufw allow 4789/udp  # overlay network VXLAN
ufw --force enable

echo "🔒 Enabling basic SSH brute-force protection (fail2ban)..."
systemctl enable --now fail2ban

echo "⚙️ Enabling Docker service..."
systemctl enable docker
systemctl start docker

echo "📂 Setting up persistent volume base path..."
mkdir -p /mnt/data/docker-volumes
chown root:docker /mnt/data/docker-volumes

echo "🧼 Cleaning up..."
apt autoremove -y
apt clean

echo "✅ VM is ready for Docker Swarm node use."
echo "👉 Run this on one VM to create the swarm:"
echo "    docker swarm init --advertise-addr <VM_IP>"
echo "👉 Then on others:"
echo "    docker swarm join --token <token> <manager_ip>:2377"
