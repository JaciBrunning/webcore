#!/usr/bin/env bash
# Designed to install on a PRODUCTION Debian 9 server from fresh installation.
# Run as root.
# Run from url with `wget -qO- <url> | bash`

set -x

apt-get install git curl dirmngr openssh-server net-tools -y
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm install 2.3.1
rvm use 2.3.1 --default

gem install bundler rake --no-ri --no-rdoc

groupadd www
useradd -s /usr/sbin/nologin -r -M www -g www

rm -r /etc/www/webcore.git
mkdir -p /etc/www/webcore.git /etc/www/webcore

git init --bare /etc/www/webcore.git

cat <<EOM > /etc/www/webcore.git/hooks/post-receive
    #!/bin/bash
    BRANCH="master"

    while read oldrev newrev ref
    do
        if [[ $ref = refs/heads/$BRANCH ]];
        then
            git --work-tree="/etc/www/webcore" --git-dir="/etc/www/webcore.git" checkout -f
        fi
    done
EOM

chown -R :www /etc/www/
chmod -R g+swrx /etc/www/