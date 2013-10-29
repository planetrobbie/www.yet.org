---
title: "Deploying OpenStack Grizzly using Rackspace Private Cloud 4.0"
created_at: 2013-07-08 11:05:00 +0100
kind: article
published: true
tags: ['howto', 'openstack', 'chef', 'devops']
---

OpenStack ecosystem grows at a rapid pace, deploying a private cloud starts by choosing the ideal tools for the job. Today we'll look at what *[Rackspace](http://www.rackspace.com)* have to offer in that space, their Open source *[Rackspace Private Cloud](http://www.rackspace.com/cloud/private/)* package enables quick deployment of an OpenStack cloud.

<!-- more -->

If you're curious about what's inside this solution, here is the overall architecture.

![][rpc-archi]

Rackspace Private Cloud supports the main OpenStack projects:

* *Nova* (Compute)
* *Horizon* (Web UI)
* *Swift* (Object storage)
* *Cinder* (Block storage)
* *Glance* (Image service)
* *Keystone* (Identity service)

And adds to OpenStack the following feature :

* Highly available *OpenStack* services (for controller, RabbitMQ and DB, not for Neutron yet)
* *Chef Server*
* *Amazon* AMI image import

Version 4.0 release June 25, 2013 adds:

* *OpenStack Grizzly* support
* *Neutron* (Networking, formerly Quantum, uses VLAN or GRE isolated networks, you can't use Routers yet)
* *Ceilomeiter* (Usage metering)
* *OpenStack Identity* v2 (LDAP or Active Directory integration)
* *VMware* VMDK image import ([Python script](https://github.com/rcbops/support-tools/tree/master/vmdk-conversion) to convert Linux guest to qcow2 images, see the docs [here](http://www.rackspace.com/knowledge_center/article/rackspace-private-cloud-software-creating-an-instance-in-the-cloud#vmdk-image))
* *Cloud Files* support for image service
* External storage support for 3rd party vendors (*EMC, NetApp* and *SolidFire*)

### Requirements

Rackspace Private Cloud is tested against the following physical compute resources.

For the Chef Server

* 16 GB RAM
* 60 GB HD
* 4 CPU cores

For the OpenStack controller node

* 16 GB RAM
* 144 GB HD minimum
* 4 CPU cores

For OpenStack Nova Compute nodes

* 32 GB RAM
* 144 GB HD
* 4 CPU cores

As you can guest for our demo installation we'll use a lot less resources;) but you'll need at a minimum internet connectivity for your nodes to download installation files and to update the operating systems.

### HA Concepts

HA functionnality is currently powered by *[Keepalived](http://www.keepalived.org)* and *[HAProxy](http://haproxy.1wt.eu/)*.

The *MySQL* service could be deployed in a master-master and active-passive failover scenario on two controller nodes. *Keepalived* manages connections to the two nodes so that only one receives reads/writes at any one time. The same active/passive architecture is used for *rabbitmq*. All stateless services that can be load balanced are installed on both controllers. *HAproxy* is then installed on them with *Keepalived* managing connections to *HAproxy* to make it reliable too. *Keystone* endpoints and all API access use this mechanism.

### Networking

On the Networking side, Chef cookbooks contain definitions for the three OpenStack operations networks:

* Public (API Network): Exposes all OpenStack APIs, could be the same network as the external network which will be used for VMs connectivity (Quantum subnet could use a subset of an IP block)
	* apache2 (Horizon)
	* glance-registry
	* glance-api
	* nova-api
	* quantum-api
* Nova (Private, access restricted to datacenter): Used for internal communication between OpenStack Components like:
	* Cinder and Nova Scheduler
	* nova-cert, nova-consoleauth, nova-novncproxy
	* ntpd
	* ZeroMQ
* Management: where Monitoring and syslog forwarding communicate

You'll need on top of that a Data Network for inter-VMs connectivity and eventually a dedicated external network for VM connectivity.

Here is an example architecture:

![][rpc-network-archi]

They can share the same CIDR space. You'll find more details in the following [pdf](http://c744563d32d0468a7cf1-2fe04d8054667ffada6c4002813eccf0.r76.cf1.rackcdn.com/downloads/pdfs/privatecloud-refarc-masscomputeexternal.pdf).

By default the installation will use *nova-network*. We'll see later on how to change that to use *Neutron* (formerly *Quantum*) instead.

### High Level Overview of the installation

To build a lab environment with *OpenStack Grizzly* using *Rackspace Private Cloud*, we'll have to follow this checklist :

1. Install *Chef Server*
2. Download the latest cookbooks to the *Chef Server*
3. Install *chef-client* on each node that will be managed by *Chef* in your *OpenStack* cluster
4. Uses *Chef* to create Controller, Compute nodes and maybe more.

### Installation

In the early versions, Rackspace packaged the OpenStack Private Cloud solution as an ISO based on *Ubuntu* which limits scalability and OS choice. The current version (v4) is based on bash scripts that can be used on *CentOS* 6.3, *Ubuntu* 12.04 or *RHEL*. You first have to [register](http://www.rackspace.com/cloud/private/openstack_software/) to get access to the documentation.

Because it's not any more an ISO, you first have to install a barebone pperating system, make sure it's up to date. In our case we'll use *Ubuntu 12.04*. After the initial installation make sure you do

	apt-get update
	apt-get upgrade

#### Chef Server

*Rackspace* makes everything easy, for example to install your chef-server you only need to type the following command on your newly installed Ubuntu 12.04:

	curl -s -L https://raw.github.com/rcbops/support-tools/master/chef-install/install-chef-server.sh | \
    bash

Log out and in again to reload environment variables and check your installation with

	knife client list

#### OpenStack cookbooks

You can now import all Rackspace *OpenStack* cookbooks with the following command

	curl -s -L https://raw.github.com/rcbops/support-tools/master/chef-install/install-cookbooks.sh | \
    bash

This command will install git and will clone cookbooks in the following directory

	/root/chef-cookbooks  

It should finish with the following message

	Uploaded all cookbooks.

If it's not the case, for example if you get a connection timeout error verify that your hostname (FQDN) is correctly configured.

#### chef-client

Each OpenStack node should be accessible with passwordless ssh. So on your chef-server generate an ssh key

	ssh-keygen

accept all defaults and copy the generated key to the root user of all your nodes

	ssh-copy-id root@<node-IP>

You can now download the *chef-client* install script on your chef-server node with

	# curl -skS https://raw.github.com/rcbops/support-tools/master/chef-install/install-chef-client.sh \
  	> install-chef-client.sh
  	# chmod +x install-chef-client.sh

 Remote install *chef-client* on your all of your nodes 

 	./install-chef-client.sh <nodeIP>

#### OpenStack Controller

In the previous steps we prepared all the required nodes with chef-client, we can now install *OpenStack*. First of all create an environment on the Chef Server

	knife environment create grizzly -d "Grizzly OpenStack Environment"
	knife environment edit grizzly

In this environment file you need to describe your network environment, for now we'll stick with nova-network. We'll change this to use quantum later on.

	#!json
	"override_attributes": {
        "nova": {
            "networks": [
                {
                    "label": "public",
                    "bridge_dev": "eth1",
                    "dns2": "8.8.4.4",
                    "num_networks": "1",
                    "ipv4_cidr": "12.0.0.0/24",
                    "network_size": "255",
                    "bridge": "br100",
                    "dns1": "8.8.8.8"
                }
            ]
        },
        "mysql": {
            "allow_remote_root": true,
            "root_network_acl": "%"
        },
        "osops_networks": {
            "nova": "172.16.154.0/24",
            "public": "172.16.154.0/24",
            "management": "172.16.154.0/24"
        }
    }

In this example we are using the same L2 network for all of our needs and eth1 for the VM traffic.

To switch all your nodes to the newly created grizzly environment from the chef-server use

	knife exec -E 'nodes.transform("chef_environment:_default") \
  	{ |n| n.chef_environment("grizzly") }'

We will now associate the single-controller role to a node

	knife node run_list add <deviceHostname> 'role[single-controller]'

To install the node, you just have to run on the node itself

	chef-client

Wait a bit and you'll get a shinny new node.

To details things a little bit, the single-controller role contains the following roles or recipes.

|role name|description|roles or recipes|
|:-|:-|:-|
|base|Base role for a server|osops-utils::packages, openssh, ntp, sosreport, rsyslog, hardware, osops-utils::default|
|rsyslog-server|rsyslog-server config|base, rsyslog::server|
|mysql-master|Installs mysql and sets up replication (if 2 nodes with role)|base, mysql-openstack::server, openstack-monitoring::mysql-server|
|rabbitmq-server|RabbitMQ Server (non-ha)|base, erlang::default, rabbitmq-openstack::server, openstack-monitoring::rabbitmq-server|
|keystone|Keystone server|base, keystone-setup, keystone-api|
|glance-setup|Glance server|base, glance-setup, glance-registry, glance-api|
|glance-registry|Glance Registry server|base, glance::registry, openstack-monitoring::glance-registry|
|glance-api|Glance API server|base, glance::api, openstack-monitoring::glance-api|
|nova-setup|Where the setup operations for nova get run|nova::nova-setup|
|nova-network-controller|Setup nova-networking for controller node|nova-network::nova-controller, openstack-monitoring::nova-network|
|nova-scheduler|Nova scheduler|base, nova::scheduler, openstack-monitoring::nova-scheduler|
|nova-conductor|Nova Conductor|base, nova::nova-conductor, openstack-monitoring::nova-conductor|
|nova-api-ec2|Nova API EC2|base, nova::api-ec2, openstack-monitoring::nova-api-ec2|
|nova-api-os-compute|Nova API for Compute|base, nova::api-os-compute, openstack-monitoring::nova-api-os-compute|
|cinder-setup|Cinder Volume Service|base, cinder::cinder-volume, openstack-monitoring::cinder-volume|
|cinder-api|Cinder API Service|base, cinder::cinder-api, openstack-monitoring::cinder-api|
|cinder-scheduler|Cinder scheduler Service|base, cinder::cinder-scheduler, openstack-monitoring::cinder-scheduler|
|nova-cert|Nova Certificate Service|base, nova::nova-cert, openstack-monitoring::nova-cert|
|nova-vncproxy|Nova VNC Proxy|base, nova::vncproxy, openstack-monitoring::nova-vncproxy|
|horizon-server|Horizon server|base, mysql::client, mysql::ruby, horizon::server|
|openstack-logging|configure OpenStack logging to a single source|base, openstack-logging::default|

You see the trend here, there is the `base` recipe everywhere to make sure it will be there no matter which role you use on your node and `openstack-monitoring:*` which plugs the component to the monitoring infrastructure and many others specifics ones.

#### Compute Node

As soon as the controller installation finish, you can add compute nodes with

	knife node run_list add <deviceHostname> 'role[single-compute]'

and run on your node

	chef-client

Repeat this process for all your compute nodes. At the end of this process you can check all nodes are correctly installed with 

	nova hypervisor-list

### All in one

If you want to deploy everything on the same node, you can use 

	knife node run_list add <deviceHostname> 'role[allinone]'

This will create an all-in-one Openstack cluster by using both single-controller and single-compute roles.

### Neutron Networking

To use *Neutron* Networking you first have to make sure that on each of your compute nodes you have one out-of-band `eth0` management interface and a physical provider interface `eth1` up but without any IP addresses.

	vi /etc/network/interfaces

should contain

	auto eth1 
	iface eth1 inet manual 
  		up ip link set $IFACE up 
  		down ip link set $IFACE down

If you change anything in that file, use the following command to bring eth1 up.

	ifup eth1

Now apply the single-network-node role to your controller

	knife node run_list add <deviceHostname> 'role[single-network-node]'

And as usual run *chef-client* to converge your controller.

Now you can prepare the pre-requisites for your VMs to communicate, all VM communication between the nodes will be done via eth1.

	ovs-vsctl add-port br-eth1 eth1

Nodes are now ready to use Neutron. The current implementation supports VLAN or GRE isolated networks but as of today *Rackspace Private Cloud* doesn't implement the l3 agent which provides L3/NAT forwarding to provide external network access for VMs on tenant network. This agent is the same across all plugins.

![][rpc-neutron]

Each **Compute node** will have a `quantum-*-plugin-agent` depending on the selected plugin to connect instances to network port. If you're curious here is how the OVS plugin is implemented within a compute node.

![][rpc-neutron-inside]

A **Network Node** which can be combined with the Controller will have:

* **quantum-server**: python daemon which expose the OpenStack Networking API and and passes user requests to the configured OpenStack Networking plugin for additional processing. Enforce Network Model. IP addressing to each Port.
* **quantum-metadata-agent**: mediate between Neutron L3-agent, DHCP agent with OpenStack Nova metadata API server
* **quantum-dhcp-agent**: spawn and control *dnsmasq* processes to provide DHCP services to tenant networks. This agent is the same across all plugins. 
* **quantum-ovs-plugin-agent**: Control OVS network bridges and routes between them via patch, tunnel or tap without requiring an external *OpenFlow* controller

To conclude our architecture chapter, here is how everythings relates in the OVS plugin scenario:

![][rpc-neutron-inside-2]

We'll now pecify within our Chef environment that we want to use *Neutron* Networking instead of nova-network. 

To use *Neutron* networking instead of nova-network just edit the grizzly chef environment

	knife environment edit

It should look like that

	#!json
	{
  		"name": "grizzly",
  		"description": "",
  		"cookbook_versions": {
  		},
  		"json_class": "Chef::Environment",
  		"chef_type": "environment",
  		"default_attributes": {
  		},
  		"override_attributes": {
    		"nova": {
      			"network": {
        			"provider": "quantum",
      			}
    		},
    		"quantum": {
      			"ovs": {
        			"network_type": "gre"
      			}
    		},
    		"mysql": {
      			"allow_remote_root": true,
      			"root_network_acl": "%"
    		},
    		"osops_networks": {
      			"nova": "172.16.154.0/24",
      			"public": "172.16.154.0/24",
      			"management": "172.16.154.0/24"
    		}
  		}
  	}

Create a new gre backed network named production-net

	quantum net-create --provider:network_type=gre \
 	--provider:segmentation_id=100 production-net

Create a subnet in the newly created network

	quantum subnet-create --name range-one production-net 10.20.30.0/24

If your gateway isn't on 10.20.30.1, you can specify it with --gateway-ip.

You'll find the generated configuration files below

	/etc/quantum

The OVS plugin configuration reside in

	/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini 

You can now launch 2 VMs using *Cirros* image on this Logical L2 network and test connectivity with ping.

### Password

All the administrative credentials are located on your controller node in the following file

	/root/.novarc

The default login/password for the Horizon dashboard is
	
	admin/secrete

### Conclusion

As stated in their [v4 release notes](http://9eaf339d988fd8220a6e-0217701e89bb085fc847205d9ec69e43.r11.cf1.rackcdn.com/rackspace-private-cloud-releasenotes-v4.pdf), *Rackspace Private Cloud* is suitable for anyone who wants to install a stable, tested, and supportable OpenStack powered private cloud, and can be used for **all** scenarios from initial evaluations to production deployments. I second that, not only because it's really well documented but also because it provides an Highly Available architecture for controller, DB and Rabbitmq.

Compared to Fuel or Crowbar, Rackspace solution lack a bare metal provisionner, so you'll have to use Cobbler or an equivalent solution for bare metal provisionning.

But more importantly, it lacks the capability to instanciate L3 routers using Neutron plugins, so for now you'll have to limit yourself to Flat topologies which is bad. Overall the Neutron cookbook is really not production ready and not really well documented, that's currently the only negative aspect of this interesting deployment tool. But I'm sure it will be adressed soon enough or maybe not because *Rackspace* uses in production the NVP plugin from Nicira now acquired by VMware (disclaimer, I work for VMware). But other initiatives like the recent unified [StackForge](https://github.com/stackforge/cookbook-openstack-network) cookbook project can be the solution to this weak support for Neutron, it already support most of the existing plugins in the market: Nicira, Midokura, Nec, Plumgrid, Openvswitch, Brocade, Bigswitch, etc...

If you look closely in the Rackspace [cookbook repository](https://github.com/rcbops/chef-cookbooks), you'll find Graphite and collectd recipes, it seems a future version will support those great monitoring tools but you won't find them in the StackForge repo which stays independant from non Core OpenStack projects.

So Stay tuned for more.

### Rackspace Private Cloud Links

* [Rackspace Private Cloud v4 Annoucement](http://www.rackspace.com/blog/rackspace-private-cloud-now-on-openstack-grizzly-adds-virtual-networks-active-directory-integration/)
* [Software homepage](http://www.rackspace.com/cloud/private)
* [Knowledge Center](http://www.rackspace.com/knowledge_center/getting-started/rackspace-private-cloud)
* [Forums](http://privatecloudforums.rackspace.com/)

### Chef and OpenStack Links

* [Quantum documentation](http://docs.openstack.org/trunk/openstack-network/admin/content/)
* [Quantum Architecture](https://skydrive.live.com/view.aspx?resid=8F95A76243630FB1!127&app=PowerPoint&authkey=!AK0Y3KWzD6o3WVI)
* [Knife Openstack](https://github.com/opscode/knife-openstack)
* [Chef for Openstack Google Groups](https://groups.google.com/forum/#!forum/opscode-chef-openstack)
* [Berkshelf](http://berkshelf.com) - Manage Cookbook dependencies
* [Kitchen-Openstack](https://github.com/RoboticCheese/kitchen-openstack) - An OpenStack Nova driver for Test Kitchen 1.0!
* [ChefConf2013 - Chef for OpenStack slides](http://www.slideshare.net/mattray/chef-and-openstack-workshop-from-chefconf-2013)
* [http://openstack.prov12n.com/](http://openstack.prov12n.com/)

### Chef Cookbooks repositories

* [Rackspace](https://github.com/rcbops) - the one from Rackspace Private Cloud
* [StackForge](https://github.com/stackforge) - mainline repository for Chef for Openstack. Look for repositories starting with `cookbook-*`
* [AT&T](https://github.com/att-cloud/) - now merging into StackForge.
* [Dreamhost](https://github.com/Dreamhost)
* [Dell](https://github.com/crowbar) - From [Crowbar](/2013/06/crowbar-rc1/) deployment tool, cookbooks are embedded in [Barclamps](/2013/07/barclamp/) to allow baremetal OpenStack provisioning.
* [SUSE](https://github.com/SUSE-Cloud) - [Suse Cloud](https://www.suse.com/products/suse-cloud/) integrated Crowbar

[rpc-archi]: /images/posts/rpc-archi.png
[rpc-network-archi]: /images/posts/rpc-network-archi.png
[rpc-neutron]: /images/posts/rpc-neutron.png
[rpc-neutron-inside]: /images/posts/rpc-neutron-inside.png width=750px
[rpc-neutron-inside-2]: /images/posts/rpc-neutron-inside-2.png width=850px

### This article could be improved anytime soon or never with the following content.

- Neutron networking troubleshooting.
- Controller [Node HA](http://www.rackspace.com/knowledge_center/article/installing-openstack-with-rackspace-private-cloud-tools#add-controller-node) deployment.