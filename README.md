# singularity-vm

This repository has a Vagrant installation for a Ubuntu 16.04.2 LTS Virtual Machine that can host Singularity containers on a Mac (and maybe Windows - the instructions here will be for a Mac, but they may work on Windows with some modifications). The virtual machine will have Singularity (http://singularity.lbl.gov) installed along with the Fermilab kerberos client and CVMFS. 

## Installation

Here are installation instructions

### Install VirtualBox and Vagrant

__VirtualBox__ is a free virtualization application from Oracle. Go to https://www.virtualbox.org and download the "OS X hosts" binary. Double click on the downloaded `.dmg` file. Then double click on the `.pkg` file to install. 

VirtualBox is difficult to run and configure. __Vagrant__ is esentially a configuration manager for VirtualBox. With Vagrant you can define and run virtual machines. Go to https://www.vagrantup.com and click on the Download box. Then click on the Mac OSX download. Double click on the downloaded `.dmg` file and then double click on the `.pkg` file to install.

Note that you can install Vagrant and VirtualBox from Homebrew. I find it easier to just download them from their web pages as above. 

### Add plugins to Vagrant

Once Vagrant is installed you need to add plugins. Open a terminal window and do the following...

```bash
vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-scp
```

The `vagrant-vbguest` plugin will automatically add code to a virtual machine add some features from VirtualBox (like shared volumes).
The `vagrant-scp` plugin will allow you to easily copy files between your host machine (e.g. the mac) and the virtual machine. 

### Download this repository

In some directory, download this repository

```bash
cd <somewhere>
git clone https://github.com/lyon-fnal/singularity-vm
cd singularity-vm
```

### Create and provision the virtual machine

It takes several steps to create and provision the virtual machine. You can do it all on one line with,

```bash
vagrant up ; vagrant reload ; vagrant reload
```

It can take many mintutes. 

You may be asked for your Mac administrator password (whatever you use for `sudo`). This is ok - NFS is used to share your `/Users` directory with the virtual machine. Setting up NFS may require the password. 

## Logging into the virtual machine

Change directory to where you installed `singularity-vm`,

```bash
cd <somewhere>/singularity-vm
```

and run `vagrant ssh`

```bash
vagrant ssh
```

If for some reason the VM was down, you can bring it back up with `vagrant up ; vagrant ssh`. 

## Mounting CVMFS

The CVMFS reopsitories are not mounted by default. 

