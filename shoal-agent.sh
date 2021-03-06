#!/bin/bash
#This script requires puppet installed.
#One needs to be root to apply this.
#This script installs shoal agent and squid

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

if [ ! -d "/etc/puppet/modules/stdlib" ]; then
  puppet module install puppetlabs/stdlib
fi

#if [ ! -d "/etc/puppet/modules/frontier" ]; then
 # puppet module install desalvo/frontier
#fi

cat << EOF | puppet apply
include shoal::frontier
include shoal::repository
class {'shoal::agent':
      shoal_server_ip => 'cloudshoal.fnal.gov',
      }
Class['shoal::frontier'] -> Class['shoal::repository'] -> Class['shoal::agent']
EOF

ip=$(GET http://169.254.169.254/latest/meta-data/public-ipv4)
echo $ip
sed '/external_ip =/ c external_ip = '"$ip"'' /etc/shoal/shoal_agent.conf -i
service shoal-agent restart

