#!/usr/bin/env bash
# Designed to install on a PRODUCTION Debian 9 server from fresh installation.
# Run as root.
# Run from url with `wget -qO- <url> | bash`

echo "Deployment Account Name?"
read ACCNAME

# Create deployment user
if ! id -u $ACCNAME
then
    echo "User $ACCNAME doesn't exist. Creating..."
    adduser $ACCNAME
else
    echo "User exists!"
fi

# Install necessary packages
apt-get update
apt-get install git curl dirmngr openssh-server net-tools sudo build-essential authbind -y

# Write sudoers
if ! cat /etc/sudoers | grep -q "^$ACCNAME\s*ALL=NOPASSWD:/usr/bin/apt-get"
then
    echo "$ACCNAME ALL=NOPASSWD:/usr/bin/apt-get" >> /etc/sudoers
fi

if ! cat /etc/sudoers | grep -q "^#include /etc/www/sudoers"
then
    echo "#include /etc/www/sudoers" >> /etc/sudoers
fi

# Create www group and users
groupadd www
useradd -s /usr/sbin/nologin -r -M www -g www
usermod -aG www $ACCNAME

mkdir -p /etc/www

# Enable www group control of systemctl for webcore
cat <<EOM > /etc/www/sudoers
%www ALL=NOPASSWD:/bin/systemctl restart webcore.service
%www ALL=NOPASSWD:/bin/systemctl stop webcore.service
%www ALL=NOPASSWD:/bin/systemctl start webcore.service
%www ALL=NOPASSWD:/bin/systemctl link /etc/www/webcore/install/webcore.service
EOM

# Init git repo
rm -r /etc/www/webcore.git
mkdir -p /etc/www/webcore.git /etc/www/webcore

git init --bare /etc/www/webcore.git

source /etc/profile.d/rvm.sh

# Check & Install RVM and Rubies
if ! [ -f "/usr/local/rvm/bin/rvm" ]
then
    echo "Missing RVM! Instaling..."
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    \curl -sSL https://get.rvm.io | bash -s stable
    usermod -aG rvm $ACCNAME
fi

source /etc/profile.d/rvm.sh

if ! rvm current | grep -q 'ruby-2.3.3'
then
    echo "Changing to Ruby 2.3.3..."
    rvm install 2.3.3
    rvm use 2.3.3 --default
    rvm use 2.3.3
fi

if ! gem list bundler | grep -q '^bundler\s'
then
    echo "Installing Bundler..."
    gem install bundler --no-ri --no-rdoc
fi

# Write git post-receive hooks for commits
cat <<EOM > /etc/www/webcore.git/hooks/post-receive
#!/bin/bash
BRANCH="master"

while read oldrev newrev ref
do
    if [[ \$ref = refs/heads/"\$BRANCH" ]];
    then
        git --work-tree="/etc/www/webcore" --git-dir="/etc/www/webcore.git" checkout -f
        pushd /etc/www/webcore
        chmod +x install/commit_hook.sh
        ./install/commit_hook.sh
        popd
    fi
done
EOM

# Chown /etc/www to the correct group
chown -R :www /etc/www/
chmod -R g+swrx /etc/www/

chown 0:0 /etc/www/sudoers

# Configure authbind
echo "Configuring Authbind..."
touch /etc/authbind/byport/80
touch /etc/authbind/byport/443
chmod 777 /etc/authbind/byport/80
chmod 777 /etc/authbind/byport/443

# Done!
echo "Webcore provisioned! Push to this remote's master to run."