#!/bin/bash
# Installations for ubuntu
export DEBIAN_FRONTEND=noninteractive

# Update ubuntu
apt-get -y update
apt-get -y upgrade 
apt-get -y dist-upgrade

# Install kerberos
apt-get install -yq krb5-user
wget http://computing.fnal.gov/authentication/krb5conf/Linux/krb5.conf -O /etc/krb5.conf

# Install CVMFS (see https://cernvm.cern.ch/portal/filesystem/downloads )
wget https://ecsft.cern.ch/dist/cvmfs/cvmfs-release/cvmfs-release-latest_all.deb
dpkg -i cvmfs-release-latest_all.deb
rm -f cvmfs-release-latest_all.deb
apt-get -y update
apt-get install -y cvmfs

# Fix autofs to not include /cvmfs
sed -i '/cvmfs/d' /etc/auto.master
service autofs reload
service autofs restart

# Write domain.local for cvmfs
cat > /etc/cvmfs/default.local << NNNN
CVMFS_REPOSITORIES="\`echo \$(ls /cvmfs | grep  '\.')|tr ' ' ,\`"
CVMFS_HTTP_PROXY=DIRECT
NNNN

# Write opensciencegrid.org.local for cvmfs
cat > /etc/cvmfs/domain.d/opensciencegrid.org.local << NNNN
CVMFS_SERVER_URL="http://cvmfs.fnal.gov:8000/cvmfs/@org@.opensciencegrid.org;http://oasis-replica.opensciencegrid.org:8000/cvmfs/@org@.opensciencegrid.org"
CVMFS_KEYS_DIR=/etc/cvmfs/keys/opensciencegrid.org
CVMFS_USE_GEOAPI=yes
NNNN

cvmfs_config reload

# Set up sshfs
apt-get install -y sshfs
mkdir /pnfs
chown ubuntu /pnfs
chgrp ubuntu /pnfs

# Write cvmfs_mount
cat > /usr/local/bin/cvmfs_mount << NNNN
sudo umount -f /cvmfs/\$1.opensciencegrid.org
sudo mkdir -p /cvmfs/\$1.opensciencegrid.org
sudo mount -t cvmfs \$1.opensciencegrid.org /cvmfs/\$1.opensciencegrid.org
NNNN
chmod a+x /usr/local/bin/cvmfs_mount

# Install Singularity (see http://singularity.lbl.gov/install-linux )
VERSION=2.3.1
wget https://github.com/singularityware/singularity/releases/download/$VERSION/singularity-$VERSION.tar.gz
tar xvf singularity-$VERSION.tar.gz
cd singularity-$VERSION
./configure --prefix=/usr/local
make
sudo make install

# Remove the build and installation files
cd /home/ubuntu
rm -rf singularity-*

# Install netdata for monitoring
# See https://github.com/firehol/netdata/wiki/Installation#1-prepare-your-system (under "This is how to do it by hand")
apt-get install -y zlib1g-dev uuid-dev libmnl-dev gcc make git autoconf autoconf-archive autogen automake pkg-config curl
echo 1 >/sys/kernel/mm/ksm/run  # Turn on kernel same-page merging (saves memory for netdata)
echo 1000 >/sys/kernel/mm/ksm/sleep_millisecs
git clone https://github.com/firehol/netdata.git --depth=1
cd netdata/
./netdata-installer.sh --dont-wait --dont-start-it
echo 'art: gm2* nova* art* uboone*' >> /etc/netdata/apps_groups.conf
cd ..
rm -rf netdata

apt-get clean

# DONE!!
