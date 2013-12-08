---
title: "Building your own Crowbar ISO for OpenStack Havana"
created_at: 2013-11-06 09:05:00 +0100
kind: article
published: true
tags: ['howto', 'openstack', 'chef', 'crowbar', 'devops']
---

*[Crowbar](http://crowbar.github.com)*, a great cloud unboxer, is currently evolving at a rapid pace, if you want to see the latest and greatest thing without waiting any longer, you can build your own Crowbar ISO. In this article we'll show you how to do just that using the Roxy branch which is supposed to support OpenStack Havanna. We will suppose you aren't planning to contribute to the code, so we won't use our any personalized Git repository. If you don't know what's Crowbar, it's  platform for server provisioning and deployment from bare metal. But if you want to see how it could be used to deploy OpenStack, read our previous [article](/2013/06/crowbar-rc1/).

<!-- more -->

This article is based on the [offical documentation](https://github.com/crowbar/barclamp-crowbar/blob/master/doc/devguide/devtool-build.md) from the Crowbar team plus some tips & tricks.

### Build Machine

Let's first install all the prerequisites on our build machine.

You first need a fresh Ubuntu 12.04.02 OS installed.

SSH to that box and follow the steps below.

Make sure to enable password-less sudo:

	sudo sed -ie "s/%sudo\tALL=(ALL:ALL) ALL/%sudo ALL=(ALL) NOPASSWD: ALL/g" /etc/sudoers

*Note:* This is required because the build process will mount ISO which require root access but you don't want to stay close to the installation to enter it when required.  
Install required package with

	sudo apt-get update
	sudo apt-get install \
		git rpm ruby rubygems1.9 curl build-essential debootstrap \
	    mkisofs binutils markdown erlang debhelper python-pip \
	    build-essential libssl-dev zlib1g-dev \
	    libpq-dev byobu cabextract ruby1.9.1-dev

If you plan to install the lastest developement branch also install

	sudo apt-get install libsqlite-dev libsqlite-dev libsqlite-dev

Now make sure you use the latest Ruby (1.9.1) version with

	sudo update-alternatives --config ruby

### PostgreSQL 9.3 installation

Crowbar is now using PostgreSQL 9.3 which isn't part of Ubuntu 12.04 so you need to remove the older Ubuntu version

	sudo apt-get remove postgresql

Add a new repository key

	wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -

determine your OS codename

	lsb_release -c

Create the following file `/etc/apt/sources.list.d/pgdg.list` with the following content and update apt database

	deb http://apt.postgresql.org/pub/repos/apt/ <codename>-pgdg main

Now you can run

	apt-get update

Note: The codename should be the one from the previous command.

Intall the newer version from this new repository

	sudo apt-get install postgresql-9.3 pgadmin3

Configure PostgreSQL

	sudo vi /etc/postgresql/9.3/main/pg_hba.conf

Add the following section at the beginning of the following file `/etc/postgresql/9.3/main/pg_hba.conf` 

	local  all   all    trust

And change Port like this in `/etc/postgresql/9.3/main/postgresql.conf`

	port = 5439

Start the service

	sudo service postgresql restart

Now create a Crowbar user 

	sudo createuser -s -d -U postgres -p 5439 crowbar

Test PostgreSQL installation

	psql postgresql://crowbar@:5439/template1 -c 'select true;'

### Gems installation

Install required Gems

	sudo gem install builder bluecloth
	sudo gem install json net-http-digest_auth kwalify bundler delayed_job delayed_job_active_record rake rspec pg --no-ri --no-rdoc
	sudo gem install rcov -v 0.9.11 --no-ri --no-rdoc

### Ubuntu 12.04 ISO

Create repository for Ubuntu ISO

	mkdir -p ~/.crowbar-build-cache/iso
	cd ~/.crowbar-build-cache/iso

You now have to download Ubuntu-12.04-server ISO to it

	wget http://old-releases.ubuntu.com/releases/12.04.0/ubuntu-12.04.2-server-amd64.iso

### Crowbar repository

You currently have all the pre-requisites to start the building process. The first step is to clone the Crowbar Git Repository

	cd ~
	git clone https://github.com/crowbar/crowbar.git
	cd ~/crowbar
	
Now do the following, make sure you append `--no-github` if you don't want to submit any pull-requests

	./dev setup --no-github
	./dev fetch --no-github

### Build Sledgehammer ISO

Sledgehammer is a bare OS by default based on CentOS 6.2 used to bootstrap Nodes during the discovery process, build it once with

	cd ~/crowbar
	sudo ./build_sledgehammer.sh

It takes some time but you won't have to repeat this process for each Crowbar ISO Build fortunately. It should terminate with the following message:

	Your pxeboot image is complete.
	
	Copy tftpboot/ subdirectory to /tftpboot or a subdirectory of /tftpboot.
	Set up your DHCP, TFTP and PXE server to serve /tftpboot/.../pxeboot.0
	
	Note: The initrd image contains the whole CD ISO and is consequently
	very large.  You will notice when pxebooting that initrd can take a
	long time to download.  This is normal behaviour.

### Configure Crowbar builder

Almost there, now list the different release available to you

	./dev releases

Show all the builds
	
	./dev builds

Select what you want to build for example

	./dev switch development/master

Display your current release and build

	./dev release
	./dev build

As of now `mesa-1.6/openstack-os-build` is the most stable OpenStack release based on 1.6 (mesa). The current Crowbar 2.0 branch (master) doesn't support OpenStack yet.

### Building

If you're using a Cloud hosted VM to build Crowbar, I would recommend to start [Byobu](http://byobu.co/) like that :

	byobu

In case you are disconnected from it, building will still continue, and you'll be able to reconnect to it once being reconnected to your instance.	

Now for fun let's build `roxy/openstack-os-build` which was introduced to support Havana, `Pebbles` is the previous one which support Grizzly. So we do:

	./dev switch roxy/openstack-os-build
	./dev build --os ubuntu-12.04 --update-cache

If you can strange README.empty-branch files, you can run the following command to solve that problem

	cd ~/crowbar/barclamps
	for bc in *; do (cd "$bc"; git clean -f -x -d 1>/dev/null 2>&1; git reset --hard 1>/dev/null 2>&1); done

You now have to be really patient, building Crowbar is a long process, lots of things to download, it took me around 80 minutes, so you can detach from the Byobu session using `F6` and do other stuff. When you'll come back in your builder node, you'll see what's going on and if you're lucky it will be done with the following message.

	2013-11-02 17:04:54 -0700: Copying over Sledgehammer bits
	2013-11-02 17:04:55 -0700: Creating new ISO
	2013-11-02 17:05:51 -0700: Image at /home/user/crowbar/crowbar-roxy_openstack-os-build.4700.dev-ubuntu-12.04.iso
	2013-11-02 17:05:51 -0700: Finished.

You can now transfer around the ISO to boot a Crowbar admin node

	scp user@crowbar-builder:/home/user/crowbar/crowbar-roxy_openstack-os-build.4546.dev-ubuntu-12.04.iso .

It's a 2Gb transfer so if it fails you can resume it with

	rsync --partial --progress --rsh=user@crowbar-builder:/home/user/crowbar/crowbar-roxy_openstack-os-build.4546.dev-ubuntu-12.04.iso .

Or you can also publish the crowbar directory over HTTP using Ruby like this

	ruby -run   -e httpd -- -p 3333 ~/crowbar

Now connect to your client machine and download it with

	wget http://crowbar-builder.lab.int:3333/crowbar-roxy_openstack-os-build.4734.dev-ubuntu-12.04.iso

If the transfert fails you can resume it using the `-c` wget option

	wget -c http://crowbar-builder.lab.int:3333/crowbar-roxy_openstack-os-build.4734.dev-ubuntu-12.04.iso

### Knife Configuration

Current Crowbar Roxy version embbed Chef Server v10.18.2.
You can interact with the Chef API using the Knife command line interface, but your first have to create an admin user from Chef Web UI accesible at `http://crowbar.lab.int:4040`.
It will give you a private key that you have to save to `~/.chef/admin.pem`.
You'll also need to copy the `/etc/chef/validation.pem` from the crowbar admin to `~/.chef/validation.pem` on your client node.

Now, to create a `~/.chef/knife.rb` configuration file, use the following command:

	knife configure -i \
	  -u <user> \
	  -s https://chef-server.lab.int:443 \
	  -r /home/<user>/chef-repo \
	  --admin-client-name admin \
	  --admin-client-key ~/.chef/admin.pem \
	  --validation-key ~/.chef/validation.pem \
	  --validation-client-name chef-validator

	-u                           new API user to create
	-s                           API endpoint
	-r                           The path to your chef-repo
	--admin-client-name          existing API user
	--admin-client-key           existing user private key
	--validation-client-name     The existing validation clientname

### Building a Crowbar OpenStack Image

If you plan to deploy a Crowbar Admin node within an OpenStack cloud, you first need to generate a QCOW image. Install the some required tools

	sudo apt-get install kvm-qemu
	pip install python-glanceclient

Now generate a Raw disk

	kvm-img create -f raw crowbar.img G9

Now you can install Crowbar within this image

	sudo kvm -m 1024 -cdrom crowbar-roxy_openstack-os-build.4700.dev-ubuntu-12.04.iso \
    	-drive file=crowbar.img,if=virtio,index=0\
    	-boot d -net nic -net user -nographic -vnc :0 \
    	-usbdevice tablet

To look at the installation of Crowbar connect to your node IP using VNC and wait until it terminate. I still have to debug the last message saying no root partition.

### Notes

Compared to the [official docs](https://github.com/crowbar/barclamp-crowbar/blob/master/doc/devguide/devtool-build.md), here is what what necessary on Ubuntu 12.04

* `libopenssl-ruby1.9` wasn't found so I bypassed the installation of this package.
* `ruby1.9.3-dev` no gems with this name but documentation says it's ok on Ubuntu12.04, we installed instead ruby1.9.1-dev which is required by json gem.
* `gem install pg` require installation of libpq-dev Ubuntu package, or postgresql-devel on Redhat
* `gem install rcov -v 0.9.11` Necessary to force version here because 1.0 isn't supported on current Ruby 1.9
* `sudo apt-get install cabextract` was necessary or build would fail.
* `~/.crowbar-build-cache/barclamps/dell_raid/files/dell_raid/tools` d/l file below inside that directory
	* `wget http://www.lsi.com/downloads/Public/MegaRAID%20Common%20Files/8.07.07_MegaCLI.zip`
	* `wget http://www.lsi.com/downloads/Public/Host%20Bus%20Adapters/Host%20Bus%20Adapters%20Common%20Files/SAS_SATA_6G_P16/SAS2IRCU_P16.zip`
* sometimes the provisionning steps enters an infinite loop with message saying `waiting for pxe file to contain: .*_install .....` to exit the loop just run chef-client on the admin node or restart the tftpd process.
* When I applied first the Nova barclamp, it failed I had to manually start OpenvSwitch like this `start openvswitch-switch` and re-run chef-client on the node.
* Roxy already support Docker, see [docs](https://github.com/crowbar/crowbar/wiki/Docker) for details.

### Conclusion

It's great to be able to build your own custom Crowbar ISO, you can then follow the development as it happens. Once you boot a Node using your shiny new ISO that you just built, login/password is crowbar/crowbar. You can then run the following command to install your crowbar admin node, but you should review our [previous article](/2013/06/crowbar-rc1/) before going any further.

	sudo /tftpboot/ubuntu_dvd/extra/install <NODE_FQDN>

It's then detached from the terminal, so to track the progress run

	sudo screen -r -S crowbar-install

You can also look at

	tail -f /var/log/install.log 

Once the Admin is ready, boot other node and start applying proposals from Crowbar WebUI

	http://10.124.0.10:3000

or like this from the command line
	
	/opt/dell/bin/crowbar machines allocate d00-0c-29-fd-1a-31.lab.int
	/opt/dell/bin/crowbar mysql proposal create proposal 
	/opt/dell/bin/crowbar mysql proposal show proposal > mysql.json

edit the json file (put the host in the appropriate elements element)

	...
	"elements": {
	  "mysql-server": [
	    "d00-0c-29-fd-1a-31.lab.int"
	  ]
	...

Save it

	/opt/dell/bin/crowbar mysql proposal edit proposal  --file mysql.json
	/opt/dell/bin/crowbar mysql proposal commit proposal 

Do the same for other proposals: keystone, glance, cinder, neutron, nova, nova_dashboard.

Watch proposal deployment progress

	tail -f /var/log/syslog 

You can start over with

	./destroy_cluster.sh

For more details consult our previous [article](/2013/06/crowbar-rc1/)

Being near trunk, there is a a non null probability that the installation can fails, so consult `/var/log/crowbar/install` to troubleshoot. If the first `install-chef.sh` failed to avoid a current bug in the Roxy release, re-provision your Admin node from your ISO, re-running the install-chef command will bring strange errors with deb-deb-deb and rack.rb not found !!!

Crowbar Admin node IP address is static and will be set to `192.168.124.10`. So If it worked you should then be abble to access crowbar web interface at `http://192.168.124.10:3000`.

### Links

* [Crowbar Project Homepage](http://crowbar.github.io/home.html)
* [Crowbar ISO Build official doc](https://github.com/crowbar/barclamp-crowbar/blob/master/doc/devguide/devtool-build.md)
* [Crowbar pre-built ISO for OpenStack Grizzly](http://sourceforge.net/projects/crowbar/files/openstack/)
* [Crowbar Glossary](https://github.com/crowbar/crowbar/wiki/Glossary)
* [Crowbar Github repository](https://github.com/crowbar)
* [Crowbar setup scripts for Virtual Box](https://github.com/iteh/crowbar-virtualbox)