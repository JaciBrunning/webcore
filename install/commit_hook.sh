#!/bin/bash
echo "Working in: $(pwd)"

source /etc/profile.d/rvm.sh
echo "Using Ruby: $(rvm current)"

echo "Installing webcore packages..."
sudo apt-get install -y $(cat Packages)

echo "Installing webcore gems..."
bundle update

echo "Webcore bootstrapped. Running commit script..."
ruby install/commit_hook.rb

echo "Writing service..."
# cp install/webcore.service /etc/systemd/system/webcore.service
sudo systemctl link /etc/www/webcore/install/webcore.service

echo "Enabling webcore service..."
sudo systemctl daemon-reload
sudo systemctl restart webcore.service
sudo systemctl enable webcore.service