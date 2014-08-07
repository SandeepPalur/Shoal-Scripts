#!/bin/bash
#This script requires puppet installed.
#One needs to be root to apply this.
#This script install shoal server

if [ "`whoami`" != "root" ]; then
  echo "This should be run by root"
  exit 1
fi

mkdir -p /etc/puppet/modules

if [ ! -f "/usr/bin/git" ]; then
  yum install git -y
fi

if [ ! -d "/etc/puppet/modules/shoal" ]; then
  git clone https://github.com/SandeepPalur/shoal-puppet.git
  mkdir -p /etc/puppet/modules/shoal && cp -r shoal-puppet/* /etc/puppet/modules/shoal

else
  cd shoal-puppet
  git pull
  cd ..
  cp -rf  shoal-puppet/* /etc/puppet/modules/shoal
fi

if [ ! -d "/etc/puppet/modules/rabbitmq" ]; then
  git clone https://github.com/jcochard/puppet-rabbitmq.git
  mkdir -p /etc/puppet/modules/rabbitmq && mv puppet-rabbitmq/* /etc/puppet/modules/rabbitmq
fi

if [ ! -d "/etc/puppet/modules/erlang" ]; then
  puppet module install dcarley/erlang
fi

if [ ! -d "/etc/puppet/modules/epel" ]; then
  puppet module install stahnma/epel
fi

if [ ! -d "/etc/puppet/modules/stdlib" ]; then
  puppet module install puppetlabs/stdlib
fi

cat << EOF | puppet apply
include epel
include shoal::server_dependancies
include erlang
include rabbitmq
include shoal::server
include shoal::host_server
Class['epel'] -> Class['shoal::server_dependancies'] -> Class['erlang'] -> Class[rabbitmq] -> Class['shoal::server'] -> Class['shoal::host_server']
EOF

