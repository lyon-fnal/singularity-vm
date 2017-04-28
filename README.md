# singularity-vm

This repository has a Vagrant installation for a Ubuntu 16.04.2 LTS Virtual Machine that can host Singularity containers on a Mac (and maybe Windows - the instructions here will be for a Mac, but they may work on Windows with some modifications). 

Features of this virtual machine:

* Based on Ubuntu 16.04.2 LTS (the most recent long-term support version of Ubuntu)
* Singularity will be installed (that's kinda the whole point!)
* Fermilab Kerberos client will be installed (so you can kinit to your experiment's interactive nodes at Fermilab)
* CVMFS (CERN Virtual File System) will be installed. Singularity containers will be able to use your experiment's CVMFS area
* Access to your Mac's /Users directory via NFS for fast access. 

## Installation

Here are installation instructions (again, for the Mac. They may work for Windows, but you will need to make some modifications).

### Install VirtualBox and Vagrant

__VirtualBox__ is a free virtualization application from Oracle. Go to https://www.virtualbox.org and download the "OS X hosts" binary. Double click on the downloaded `.dmg` file. Then double click on the `.pkg` file to install. 

VirtualBox is difficult to configure. __Vagrant__ is esentially a configuration manager for VirtualBox. With Vagrant you can define and run virtual machines. Go to https://www.vagrantup.com and click on the Download box. Then click on the Mac OSX download. Double click on the downloaded `.dmg` file and then double click on the `.pkg` file to install.

Note that you can install Vagrant and VirtualBox from Homebrew. I find it easier to just download them from their web pages as above. 

### Add plugins to Vagrant

Once Vagrant is installed you need to add plugins. You only need to do this once. Open a terminal window and do the following...

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

It can take many mintutes. You may see a message like `No guest IP was given to the Vagrant core NFS helper. This is an
internal error that should be reported as a bug.` This message is benign - mostly. See the paragraph below about the vagrant reload commands. 

You may be asked for your Mac administrator password (whatever you use for `sudo`). This is ok - NFS is used to share your `/Users` directory with the virtual machine. Setting up NFS may require the password. 

Why the `vagrant reload` commands? The first `vagrant up` will create the virtual machine and start configuring it. NFS will fail because the first boot will not get an IP address that NFS needs. Restarting the VM (`vagrant reload`) will allow it to get an IP address and NFS will succeed. The rest of the VM will be configured. Part of the configuration is to update all of the Ubuntu packages to their latest version. A reboot is then required to have those take affect, hence the final `vagrant reload`.  You will not need to do this again. To start the VM in the future, a simple `vagrant up` will work. 

## Logging into the virtual machine

Change directory to where you installed `singularity-vm`,

```bash
cd <somewhere>/singularity-vm
```

and run `vagrant ssh`

```bash
vagrant ssh
```

You may have many virtual machines. Vagrant knows which one you want to ssh to by noting which directory you are in. 

### vagrant ssh options

If you want to do X forwarding to your Mac (likely) then you will need `vagrant ssh -- -X`. If you want to do port forwarding (e.g. the Singularity container runs a web page) then you will need to do ssh tunnelling with something like 

```bash
vagrant ssh -- -X -L 8000:localhost:80   # forward Mac port 8000 to container port 80
```

If for some reason the VM was down, you can bring it back up with `vagrant up ; vagrant ssh`. 

## Mounting CVMFS

The CVMFS reopsitories are not mounted automatically (the automounter caused problems with Singularity). There is a command in `/usr/local/bin` called `cvmfs_mount` that will allow you to mount any `X.opensciencegrid.org` repository by specifying `X`. For example,

```bash
cvmfs_mount gm2       # Mounts /cvmfs/gm2.opensciencegrid.org
cvmfs_mount fermilab  # Mounts /cvmfs/fermilab.opensciencegrid.org
```

You will need to issue these commands every time the VM starts (perhaps write a script to make it easy). 

## Known problems

There are some problems that you may face

### sqlite3 and igprof

If you use `sqlite3` directly on a file that is sitting under `/Users`, which is mounted by NFS, `sqlite3` may hang forever when it tries to open the file. That happens because `sqlite` is trying to apply a read lock on the file and NFS can't deal with this. I found this out by running `strace` on `sqlite3` and saw it getting stuck at,

```
fcntl(3, F_SETLK, {type=F_RDLCK, whence=SEEK_SET, start=1073741824, len=1}
```

Instructions for processing the output of `igprof` (a code profiler) involving making a sqlite database and so you may hit this problem in that context. 

This actually seems to be a problem with VirtualBox and the Ubuntu VM, not with Singularity, because I can reproduce the hang just with the VM. 

The workaround is to have the database file sitting in a non-NFS mounted directory. Preferably a directory under `/vagrant` (perhaps `/vagrant/tmp`). If you put the file in `/tmp` or some area within the VM's filesystem, then you will unnecessarily grow the VM file. 

