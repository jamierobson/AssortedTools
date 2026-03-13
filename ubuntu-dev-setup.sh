# Very quick and unrefined tracking of how I got my machine set up for development wth ubuntu-cinnamon, including virtual box in order to run a windows VM for framework tasks.

sudo snap install vivaldi
sudo snap install postman
sudo snap install bruno
sudo snap install slack
sudo snap install pgadmin4
sudo snap install azuredatastudio
sudo snap install rider --clasic
sudo snap install code --classic

sudo apt-get update && sudo apt-get upgrade -y

sudo apt install flatpak
sudo apt install wget
sudo apt install gpg
sudo apt install apt-transport-https
sudo apt install curl
sudo apt install git
sudo apt install git-gui
sudo apt install ca-certificates
sudo apt install libfuse2
sudo apt install [docker.io](http://docker.io)
sudo apt install dotnet-sdk-8.0
sudo apt install dotnet-sdk-10.0
sudo apt install intune-portal

sudo usermod -aG docker $USER

# Claude
curl -fsSL https://claude.ai/install.sh | bash

# Dotnet
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 8.0
./dotnet-install.sh --channel 10.0

export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools
echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc
echo 'export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools' >> ~/.bashrc

# Edge
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-edge.gpg
sudo tee /etc/apt/sources.list.d/microsoft-edge.sources > /dev/null << 'EOF'
Types: deb
URIs: https://packages.microsoft.com/repos/edge
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/microsoft-edge.gpg
Architectures: amd64
EOF

sudo apt update
apt-cache policy microsoft-edge-stable
sudo apt install microsoft-edge-stable -y
microsoft-edge --version

# Chrome
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
cat <<EOF | sudo tee /etc/apt/sources.list.d/google-chrome.sources
Types: deb
URIs: https://dl.google.com/linux/chrome/deb/
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/google-chrome.gpg
EOF

sudo apt update
apt-cache policy google-chrome-stable
sudo apt install google-chrome-stable
google-chrome --version

# Virtual box
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

sudo apt update && sudo apt install virtualbox-7.1
sudo modprobe -r kvm_intel
sudo modprobe -r kvm

# azure vpn
curl https://packages.microsoft.com/config/ubuntu/24.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft-ubuntu-jammy-prod.list
sudo apt-get update
sudo apt-get install microsoft-azurevpnclient

# NPM
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# Repositories
ssh-keygen -t rsa -b 4096 -C "your@azuredevopsmail.com"
ssh-add ~/.ssh/id_rsa

mkdir -p ~/src
cd ~/src

# Clone repositories here.

# Terraform
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform
