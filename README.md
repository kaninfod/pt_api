
# Setup 3 raspberry pi's each to host:

* Application servers
  * Node / Frontend with nginx
  * Rails API
  * Fileserver (NFS)

* Backend
  * Resque worker
  * Redis

* DB server
  * Mysql server

# Generic setup for all servers

## setup raspbian:
* Download and flash to sd cards
* create file called ssh in sd card root folder
  * ssh-copy-id pi@192.168.2.X
* Update packages:

    sudo apt-get update
    sudo apt-get upgrade

## setup network

### set hostname:
change:
    sudo nano /etc/hostname
    sudo nano /etc/hosts

### Set static ip:

#### For App server
    interface eth0

    static ip_address=192.168.2.200/24
    static routers=192.168.2.1
    static domain_name_servers=192.168.2.1

#### For backend server
    interface eth0

    static ip_address=192.168.2.201/24
    static routers=192.168.2.1
    static domain_name_servers=192.168.2.1

#### For DB server
    interface eth0

    static ip_address=192.168.2.202/24
    static routers=192.168.2.1
    static domain_name_servers=192.168.2.1


# Setup ruby + rails servers

## Install packages
    sudo apt-get install  \
    git-core \
    curl \
    zlib1g-dev \
    build-essential \
    libssl-dev \
    libreadline-dev \
    libyaml-dev \
    libxml2-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    python-software-properties \
    libffi-dev \
    libmysqlclient-dev \
    mysql-client \
    libmagic-dev \
    graphicsMagick \
    imagemagick \
    libjpeg-dev \
    libpng-dev \
    exiftool \
    build-essential \
    nfs-common



## Install rbenv and ruby:
https://gorails.com/setup/ubuntu/17.04

    cd
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    exec $SHELL

    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    exec $SHELL

    rbenv install 2.4.0
    rbenv global 2.4.0
    ruby -v

    gem install bundler


## Setup git:
    git config --global color.ui true
    git config --global user.name "kaninfod"
    git config --global user.email "martinhinge@gmail.com"
    ssh-keygen -t rsa -b 4096 -C "martinhinge@gmail.com"

show key:
    cat ~/.ssh/id_rsa.pub
    copy key to https://github.com/settings/ssh

test:
    ssh -T git@github.com

## Install Node:
    curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    sudo apt-get install -y nodejs

## Install rails:
    gem install rails -v 5.1.3

    rbenv rehash

## Setup Application

### Get app from git repo:

    git clone https://github.com/kaninfod/pt_api.git
    cd pt_api
    bundle install


# Setup Mysql servers

    sudo apt-get install mysql-server && sudo apt-get install mysql-client

Change Bind address to allow remote connections:
    sudo nano /etc/mysql/my.cnf

Change the bind address from 127.0.0.1 to 0.0.0.0

Restart mysql:

    sudo systemctl restart mysql.service


# Setup NFS servers

## Mount USB disk.

    sudo blkid

Assuming `sda1`
    sudo mount /dev/sda1 /mnt

    sudo nano /etc/fstab

add:
    /dev/sda1 /mnt ext4 defaults 0 0

## Setup NFS on server
    sudo apt install nfs-kernel-server
    sudo systemctl start nfs-kernel-server.service

edit:
    sudo nano /etc/exports

add:
    /mnt  * (ro,sync,no_root_squash)

fix in case of following error:
run on nfs server:
    rpcinfo -p
error:
    rpcinfo: can't contact portmapper: RPC: Remote system error - No such file or directory
run on nfs server:

Make sure the NFS server is running:
    sudo service nfs-kernel-server status
    sudo service nfs-kernel-server stop
    sudo service nfs-kernel-server start
    sudo service nfs-kernel-server status
