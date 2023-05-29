#!/bin/bash -e
# This script is used by Packer to configure a Golden Image on AWS

# Variables
DEBIAN_FRONTEND=noninteractive
DATE="$(date +%F)"

# Update the OS
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# Wait for the OS to settle down
sleep 30

# Install Apache
sudo apt update
sudo apt install -y apache2

# Create a new index.html file
sudo bash -c "cat > /var/www/html/index.html <<EOF
<html>
  <head>
    <title>Golden Image ${DATE}</title>
  </head>
  <body>
    <p>Hello World at ${DATE}</p>
  </body>
</html>
EOF"

# Start and Enable Apache2
sudo systemctl enable apache2
sudo systemctl restart apache2
