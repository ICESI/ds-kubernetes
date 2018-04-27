curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker vagrant
systemctl start docker
