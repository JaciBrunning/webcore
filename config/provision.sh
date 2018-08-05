#!/usr/bin/env bash
# Designed to install on a PRODUCTION Debian 9 server from fresh installation.
# Run as root.
# Run from url with `wget -qO- <url> | bash`

echo "Deployment Account Name?"
read ACCNAME

# Create deployment group
groupadd www-deploy

# Create deployment user
if ! id -u $ACCNAME
then
    echo "User $ACCNAME doesn't exist. Creating..."
    adduser --gecos "" $ACCNAME
else
    echo "User exists!"
fi
usermod -aG www-deploy $ACCNAME

# Install necessary packages
echo "Installing Packages..."
cat <<EOM >> /etc/apt/sources.list.d/cert_backports.list
deb http://ftp.debian.org/debian jessie-backports main
EOM
apt-get update
apt-get install git curl dirmngr openssh-server net-tools sudo build-essential postgresql nginx -y
apt-get install certbot -t jessie-backports

# Create www group and users
echo "Adding Users and Groups..."
groupadd www
useradd -s /usr/sbin/nologin -r -M www -g www
usermod -aG www $ACCNAME
usermod -aG www www-data    # Add nginx user to www group

mkdir -p /etc/www

# Write sudoers
echo "Writing Sudoers"
if ! cat /etc/sudoers | grep -q "^#include /etc/www/sudoers"
then
    echo "#include /etc/www/sudoers" >> /etc/sudoers
fi

cat <<EOM > /etc/www/sudoers
%www ALL=NOPASSWD:/bin/systemctl restart nginx.service
%www ALL=NOPASSWD:/bin/systemctl restart webcore.service
%www ALL=NOPASSWD:/bin/systemctl stop webcore.service
%www ALL=NOPASSWD:/bin/systemctl start webcore.service

%www-deploy ALL=NOPASSWD:/usr/bin/apt-get
%www-deploy ALL=NOPASSWD:/bin/systemctl link *
%www-deploy ALL=NOPASSWD:/bin/systemctl enable *
%www-deploy ALL=NOPASSWD:/bin/systemctl daemon-reload
EOM

# Check & Install RVM and Rubies
echo "Checking RVM + Rubies..."
source /etc/profile.d/rvm.sh
if ! [ -f "/usr/local/rvm/bin/rvm" ]
then
    echo "Missing RVM! Instaling..."
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    \curl -sSL https://get.rvm.io | bash -s stable
    usermod -aG rvm $ACCNAME
fi

source /etc/profile.d/rvm.sh

if ! rvm list rubies | grep -q 'ruby-2.3.3'
then
    echo "Installing Ruby 2.3.3..."
    rvm install 2.3.3
fi

# if ! gem list bundler | grep -q '^bundler\s'
# then
#     echo "Installing Bundler..."
#     gem install bundler --no-ri --no-rdoc
# fi

# Write default environment file.
echo "Writing envfile..."
cat <<EOM > /etc/www/webcore.env
RACK_ENV=production
WEBCORE_MODULE_PATH=/etc/www/webcore/modules
EOM

# Chown /etc/www to the correct group
echo "Ensuring file ownership..."
chown -R :www /etc/www/
chmod -R g+swrx /etc/www/
chown -R :www-deploy /etc/nginx/sites-enabled/
chmod -R g+swrx /etc/nginx/sites-enabled/

chown 0:0 /etc/www/sudoers

# Create database
echo "Creating Database..."
su postgres <<EOSU
psql -c "create role web with login password 'web'"
psql -c "create database web owner web"
EOSU

# Done!
echo "Webcore provisioned! Push with Capistrano."