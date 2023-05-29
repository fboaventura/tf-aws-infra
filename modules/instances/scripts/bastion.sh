#!/bin/bash -e

# Variables
export DEBIAN_FRONTEND=noninteractive
DATE=$(date +"%F_%R")

# Update the system

# Update the OS
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# Wait for the OS to settle down
sleep 30

# Install troubleshooting packages
sudo apt install -y htop iotop iftop netcat-openbsd curl wget

# Create the tests script
cat <<-EOF > /home/ubuntu/tests.sh
#!/bin/bash -e

# Variables
HOSTS="\$*"

# Test the network
echo -en ".: Testing network connectivity :.\n\n"
for HOST in \$HOSTS; do
  echo -en ".:: Testing connectivity to \$HOST ::.\n\n"
  nc -vz \$HOST 22
  nc -vz \$HOST 80
  echo -en "\n\n"
  sleep 2
done

# HTTP requests
echo -en ".: Testing HTTP requests :.\n\n"
for HOST in \$HOSTS; do
  echo -en ".:: Testing HTTP requests to \$HOST ::.\n\n"
  curl -si http://\$HOST
  echo -en "\n\n"
  sleep 2
done

EOF
chmod 0755 /home/ubuntu/tests.sh

echo "Bastion script executed!"
