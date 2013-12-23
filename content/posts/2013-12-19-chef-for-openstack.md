---
title: "Chef for OpenStack"
created_at: 2013-12-23 00:51:00 +0100
kind: article
published: true
tags: ['howto', 'chef', 'devops', 'automation', 'openstack']
---

*Matt Ray* is the community manager of a project at *Chef* (formerly *Opscode*) to unify all efforts around building up Chef Cookbooks for OpenStack deployment. For quite some time lots of people were forking the repository from *Rackspace*, it created a lot of fragmentation, so Matt is now gathering all around the [StackForge](https://github.com/search?q=%40stackforge+cookbook) repository where everyone can contribute. *AT&T*, *Dell*, *Dreamhost*, *Gap*, *HP*, *HubSpot*, *IBM*, *Korea Telecom*, *Rackspace*, *SUSE* amongst others are already contributing to this project. In this article we will detail how you can use them to deploy OpenStack on your environment.

<!-- more -->

### Introduction

**StackForge** is the official location where all non official OpenStack related stuff reside.

Here is the list of Chef Cookbooks already available for Grizzly:

* cookbook-openstack-block-storage
* cookbook-openstack-common
* cookbook-openstack-compute
* cookbook-openstack-dashboard
* cookbook-openstack-identity
* cookbook-openstack-image
* cookbook-openstack-metering
* cookbook-openstack-network
* cookbook-openstack-object-storage
* cookbook-openstack-orchestration
* openstack-ops-database (operationnal support cookbooks)
* openstack-ops-messaging (operationnal support cookbooks)

There is also a [reference example](http://github.com/stackforge/openstack-chef-repo) of the environment and roles that show how to use all of this.  

This is what we will use here. As of today, it's possible to deploy :

* All-in-One Compute (could be on a Vagrant box)
* Single Controller + N compute

But you'll have to provision the operating system on your own, same for logging and monitoring which aren't in the scope of this core repository right now.  

High Availability is currently a work in progess with [Keepalived](http://www.keepalived.org/).

### Other Open Source tools

To provision your nodes, you can use for example

* *[Cobbler](http://www.cobblerd.org/)*
* *[Crowbar]()*
* *[Foreman](http://theforeman.org)*
* *[xCAT](http://sourceforge.net/apps/mediawiki/xcat/index.php?title=Main_Page)*
* *[Razor](https://github.com/puppetlabs/razor-server/wiki)*
* *[pxe_dust](https://github.com/opscode-cookbooks/pxe_dust)*

For monitoring you can use

* *[Sensu](http://sensuapp.org/)*
* *[Zenoss](http://www.zenoss.com/)*
* *[Graphite](http://graphite.readthedocs.org/en/latest/)*
* *[Nagios](http://www.nagios.com/)*.  

And for Logging:

* Syslog
* *[Logstash](http://logstash.net/)*.

### Current v7.0 support

They just branched the repority for Havana (v8.0), the Grizzly (v7.0) implementation support :

* OS: Ubuntu 12.04 (LTS), OpenSUSE 12.3, SLES 11 SP2
* DB: MySQL, SQLite (testing)
* Messaging: RabbitMQ
* Compute: KVM, LXC, Qemu
* Network: Nova + Quantum (with OVS plugin, not yet renamed to Neutron)
* Block storage: LVM
* Object Storage: Swift
* Dashboard: Apache or Nginx

### Chef for OpenStack Roadmap

In their todo list, they plan to support the following:

* Operating System: Red Hat 6
* DB: DB2, PostgreSQL
* Messaging: Qpid
* Compute: Baremetal, Docker (supported in Havana), ESX, Hyper-V, Xen
* Network: NSX, OpenDaylight
* Block storage: Ceph, NetApp
* Object Storage: Ceph
* Source builds via Omnibus (OPScode Open Sourced packager).

I'm delighted to see NSX support in the roadmap, disclaimer I'm a NSX System Engineer at VMware. 

### Requirements

This toolset is built on top of the following tools:

* Chef 11
* Ruby 1.9.x
* Berkshelf
* chef-zero
* bento

OpenStack installation will be done from packages as of now, except for some components like Open vSwitch or dnsmasq not yet distribution packages. They manage the platform logic in attributed and drive the overall configuration from attributes set in Environments. For testing they use: [Foodcritic](http://acrmp.github.io/foodcritic/) and [ChefSpec](http://code.sethvargo.com/chefspec/). 

In our demo setup we will use Vagrant to simulate baremetal servers. So start by installing [VirtualBox](https://www.virtualbox.org/) and [Vagrant](http://www.vagrantup.com/). We aren't detailing the install process here, refer to the respective documentation for [Vagrant](http://docs.vagrantup.com/v2/getting-started/t) and [VirtualBox](https://www.virtualbox.org/wiki/Documentation) instead.

On Mac OS X, you'll also need Xcode Command Line Tools from 

	https://developer.apple.com/downloads/

Now install the Omnibus, Chef-Zero and Berkshelf Vagrant plugin like this

	vagrant plugin install vagrant-omnibus
	vagrant plugin install vagrant-chef-zero
	vagrant plugin install vagrant-berkshelf

Check the three plugins are really installed

	vagrant plugin list

Here is what I got back

	vagrant-berkshelf (1.3.7)
	vagrant-chef-zero (0.5.2)
	vagrant-omnibus (1.1.2)

If you get errors when using Vagrant, you can turn on debugging

	export VAGRANT_LOG=debug

I had to install Vagrant version 1.3.5 instead of 1.4.0 which caused some dependency hell with [ridley](http://rubygems.org/gems/ridley).

### About the tools

Here is a quick explanation about each tools used:

* ***Vagrant*** - allows you to create and configure lightweight, reproducible, and portable development environments.
* ***VirtualBox*** - hypervisor, default Vagrant provisioner, you could also use [VMware Workstation](http://www.vagrantup.com/vmware) or Fusion instead.
* ***Berkshelf*** - manage a Chef Cookbook dependencies.
* ***bento*** - used by Opscode to make Just Enough Operating System images, it wraps [packer](http://packer.io) a tool to create identical machine images for multiple platforms from a single source configuration.
* ***chef-zero*** - an in-memory chef that allows you to do advanced things like search.

### Clone the Official Git Repository

It's now time to clone the StackForge OpenStack Cookbooks reporitory

	git clone https://github.com/stackforge/openstack-chef-repo

### About the Vagrantfile

The `Vagrantfile` describe the environment to launch when we will run `vagrant up`. We are using *VirtualBox* as our provisionner but you can find other provisionners for VMware, AWS or OpenStack.

The first few lines state the required plugins:

	Vagrant.require_plugin "vagrant-berkshelf"
	Vagrant.require_plugin "vagrant-chef-zero"
	Vagrant.require_plugin "vagrant-omnibus"

The different Vagrant plugins that are required in the Vagrantfile will play the following roles

* ***vagrant-berkshelf*** will read the Berksfile download and install all the required cookbooks in your `.berkshelf` directory.
* ***vagrant-chef-zero*** will spin out a Chef-Zero on your Vagrant host for the provisionned node to get their run list and cookbooks from. 
* ***vagrant-omnibus*** will install Omnibus Chef on your Vagrant box.

You then enable and configure them

	config.berkshelf.enabled = true

	# Chef-Zero plugin configuration
	config.chef_zero.enabled = true
	config.chef_zero.chef_repo_path = "."

	# Omnibus plugin configuration
	config.omnibus.chef_version = :latest

Above we just tell *Vagrant* to look in our current directory for our Chef Repository and that we want to install the latest Chef version into our box.

### Create an all-in-one OpenStack VM

It's now time to tell Vagrant to create an all-in-one OpenStack VM with this simple command from the openstack-chef-repo:

	vagrant up ubuntu1204

After a little while you should get a fully operational OpenStack Grizzly instance. But If the provisionning process failed, you can retry it with

	vagrant provision ubuntu1204

### Test it

To check it's fully operational you can connect to the Horizon Dashboard using

	https://localhost:8443

You can also connect to it with

	vagrant ssh ubuntu1204

And then

	sudo su -
	source openrc
	nova service-list
	nova hypervisor-list
	quantum agent-list

Add a cirros image to Glance

	glance image-create --name cirros --is-public true --container-format bare --disk-format qcow2 --location http://HTTPSERVER_IP/cirros-0.3.0-x86_64-disk.img
	nova image-list

Launch a new instance with

	nova boot test1 --image cirros --flavor 1 --poll
	nova list
	nova show test1

You can now SSH into test1, the user is 'cirros' and the password is 'cubswin:)':

	ssh cirros@192.168.100.2

You can now terminate your Vagrant ubuntu1204 VM with

	vagrant destroy ubuntu1204

### About the Environment

The Vagrant Environment is just a Ruby file which is injecting attributes into our environment. Any machines that Vagrant runs will get these attributes.  

The following line indicates to keep things simple and use dummy password.

	"developer_mode" => true

In a larger environment, you'll customize each chef_role instead of having all of them running under the same VM (allinone-compute) like below

	"identity_service_chef_role" => "allinone-compute"

Qemu is simpler to use in such a nested environment, you don't need your VM to support Intel VT-x for example.

	"virt_type" => "qemu"

### About Roles

As you can see in your `Vagrantfile`, the Chef run list is

	chef_run_list = [ "role[allinone-compute]" ]

If you're curions, you can look at this Role in `roles/allinone-compute.rb`

	#!ruby
	name "allinone-compute"
	description "This will deploy all of the services for Openstack Compute to function on a single box."
	run_list(
  	  "role[os-compute-single-controller]",
  	  "role[os-compute-worker]"
	)

It's the N+1 pattern, with the compute-worker and controller on the same node.
It contains `os-compute-single-controller` which itself contains

	#!ruby
	name "os-compute-single-controller"
	description "Roll-up role for all of the OpenStack Compute services on a single, non-HA controller."
	run_list(
	  "role[os-base]",
	  "role[os-ops-database]",
	  "recipe[openstack-ops-database::openstack-db]",
	  "role[os-ops-messaging]",
	  "role[os-identity]",
	  "role[os-image]",
	  "role[os-network]",
	  "role[os-compute-setup]",
	  "role[os-compute-conductor]",
	  "role[os-compute-scheduler]",
	  "role[os-compute-api]",
	  "role[os-block-storage]",
	  "role[os-compute-cert]",
	  "role[os-compute-vncproxy]",
	  "role[os-dashboard]"
	  )

And also `os-compute-worker` with the following content

	#!ruby
	name "os-compute-worker"
	description "The compute node, most likely with a hypervisor."
	run_list(
  	  "role[os-base]",
  	  "recipe[openstack-compute::compute]"
	)

Having the same role, like `os-base` two times in the Run list is perfectly fine with Chef.  

If you have time you can look in all the different recipes to understand how OpenStack got provisioned by Chef.

### About Cookbooks

All the OpenStack cookbooks are managed by Berkshelf, so they will be stored in a `.berkshelf/ubuntu1204/cookbooks` directory.

### Conclusion

Provisioning *OpenStack* with *Vagrant*, *chef-zero* and *Berkshelf* is pretty easy and can be summarized with two commands

	git clone https://github.com/stackforge/openstack-chef-repo
	vagrant up ubuntu1204

It couldn't be easier, isn't it ? Have fun with it.

### Links

* [Chef for OpenStack official documentation](http://docs.opscode.com/openstack.html)
* Matt Ray HK Summit [OpenStack deployment with Chef Workshop](http://www.openstack.org/summit/openstack-summit-hong-kong-2013/session-videos/presentation/openstack-deployment-with-chef-workshop)
* [Working with the OpenStack Code Review and CI system – Chef Edition](http://www.joinfu.com/2013/05/working-with-the-openstack-code-review-and-ci-system-chef-edition/)
* [Bug tracking](https://bugs.launchpad.net/openstack-chef/+bugs)
* IRC:openstack-chef on irc.freenode.net
* [Google Groups](http://groups.google.com/group/opscode-chef-openstack)
* [Twitter](https://twitter.com/ChefOpenStack)