---
title: "Deploying a nested OpenStack IceHouse using Rackspace Private Cloud v9.0.1"
created_at: 2014-11-30 17:05:00 +0100
kind: article
published: false
tags: ['howto', 'openstack', 'ansible', 'devops']
---

Since my [last post](/2014/01/rackspace-private-cloud-v4-2-1/) about [Rackspace Private Cloud](http://docs.rackspace.com/rpc/api/v9/bk-rpc-releasenotes/content/rpc-common-front.html) (RPC), a Private cloud solution, so much has changed. RPC version number is now aligning with the OpenStack ones, so they've switched from v4 directly to v9. It's also a good idea for Rackspace to bump up the version number to share with the rest of the world this version does have nothing in common with the earlier one, apart from OpenStack code. RPC v9 is now using **[Ansible](http://www.ansible.com/home)** instead of Chef and **Linux Bridges** instead of Open vSwitch until OVS get more stable for their use case. It seems they had issues with it which justify reverting to Linux Bridges instead. They are commiting on 99.99% API availability, so they better have a stable distrib.  

But it's also maybe motivated by their recent switch to **LXC** containers for the different OpenStack services. Instead of putting all the management code all under one entity, they are isolating the different part of the OpenStack Environment in containers, like [Juju](https://juju.ubuntu.com/) is doing. They say it's simplifying operating and troubleshooting the cloud environnement and mitigate the complexity when an operation needs to be done on one of them. In our article, we'll share all the steps involved to get a fully operational *IceHouse* Environment with the seven main OpenStack Services: *Nova, Glance, Keystone, Horizon, Neutron, Cinder, Heat*.

<!-- more -->

Before starting the deployment itself, lets review what's new in RPC v9.0.1

* **Ansible** provisionning
* OpenStack **Ice House** codebase on **Ubuntu 14.04**
* **Heat** support
* **LXC** Linux Containers
* Neutron with **VXLAN** overlay networking on **Linux Bridges**
* **Kibana, Elasticsearch** and **Logstash** deployed for log management with custom dashboards.
* Standard **Maria DB, Galera, RabbitMQ** repository used.

But version 9.0.1 also goes back in time on some aspects:

* For production environment Load Balancing should be done using Hardware load balancers instead of HA proxy
* No Ceilometer support
* No Open vSwitch support

### Installation workflow

To get a running lab environment with *OpenStack IceHouse*, we'll follow this checklist :

1. Prepare deployment node 
2. Prepare target host
4. Configure deployment
4. Run Foundation Playbook
5. Run Infrastructure Playbook
6. Run OpenStack Playbook

### Prepare deployment node

Ansible will be installed on this node which will orchestrate the OpenStack deployment.  

Ansible is a push based configuration management tools, unlike Chef where Agent on each node will regularly pull the main server, Ansible isn't using any agent and will use SSH to push Python code that will be executed on each of the target node to reach the desired state.

But first for your deployment node, you need a Ubuntu 14.04 installation with the following required packages :

    # apt-get install aptitude bridge-utils build-essential git ntp ntpdate python-dev ssh sudo vim pip

Now to install a recent version of Ansible, at least version 1.6, you can follow the method described in our [intro](/2014/07/ansible/) article which is cloning it from git instead. Briefly you do this:

    # git clone git://github.com/ansible/ansible.git
    # sudo make install

Or you can use the official Ansible PPA

    XXX

Don't use the Ubuntu 14.04 packaged version, which is not recent enough. 
So in our case, we'll be using the latest Ansible v1.8.

For Ansible to work properly, make sure you can easily SSH-in your target nodes by distributing your SSH public key around.

    XXX 

#### Playbooks

Your deployment node need to get Rackspace Private Cloud Playbooks, just clone them from the rcbops repository :

    # cd /opt
    # git clone -b 9.0.1 https://github.com/rcbops/ansible-lxc-rpc.git

XXX NEW REPO https://github.com/stackforge/os-ansible-deployment

We've already installed Ansible so remove this dependency from the `requirements.txt` file

    # cd ansible-lxc-rpc
    # vi requirements.txt

To remove the following line

    http://rpc-slushee.rackspace.com/downloads/ansible-1.6.10.tar.gz

You can now install all the required dependencies

    pip install -r ./requirements.txt

### Prepare target hosts

RPC v9 require at least five target nodes installed with Ubuntu Server 14.04 (Trusty Tahr) LTS 64-bit operating system.

![][rpc-archi-v9]

* 3 Infrastructure nodes, where all the OpenStack and Infrastructure services will run as LXC Containerso
* 1 Compute node, to host our OpenStack instances
* 1 Logging Node, where Rsyslog, Logstash, Elasticsearch and Kibana will be running.

If you add one more node, you'll be able to also deploy Cinder, the OpenStack block storage volumes and scheduler services.

Each node need to have the following packages pre-installed :

    # apt-get install bridge-utils lsof lvm2 ntp ntpdate openssh-server sudo tcpdump debootstrap

Configure NTP

    XXX

Check your kernel version which should be at least 3.13.0-34-generic

    XXX

The difficult part of this lab consist of configuring the host networking to suit your environment. `ansible-lxc-rpc/etc/network/interfaces.d` provides an example interface file that you can use as a baseline.  

Each target will be using 5 interfaces and 2 bonds:

* bond0: eth0, eth2
* bond1: eth1, eth3
* eth4

Each target node need the following Bridges

* br-mgmt: management and communication among infrastructure and OpenStack services. [on bond0, vlan 2176, container eth1]
* br-storage: segregated access to block storage devices between Compute and Block Storage hosts [on bond0, vlan 2144, container eth2, optional].
* br-vxlan: infrastructure for VXLAN tunnel/overlay networks [on bond1, vlan 1998, container eth10].
* br-vlan: infrastructure for VXLAN tunnel/overlay networks [on bond1, untagged, container eth11].
* br-snet (lxcbr0): Automatically created and managed by LXC. no physical interface assigned [container eth0]

Complex isn't it ? Maybe easier to understand with a schematic.

![][rpc-networking-target-v9]

### Launch your first instance

Let's test our installation by launching a Cirros instance. First we need to add some security rules

    nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
    nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0

Our Instances will be given IP addresses in the 12.0.0.0/24 private network, you won't be able to access them without associating a floating IP. So you need to add a floating IP range:

    nova-manage floating create 192.168.1.64/28 public

From the Horizon Dashboard you can now click on `Allocate IP to Project` a few times to make IPs available for your project.

Before you can launch your first instance, you just have to create or use an existing SSH key pair. You can import your existing `.ssh/id_rsa.pub` or create a newer one using `ssh-keygen`, it's even possible to do that step from the Horizon Dashboard.

Try to launch multiple instances and access them externally after associating floating IPs.

### Neutron Networking

#### Testing

You can now launch 2 VMs using *Cirros* image from *Horizon Dashboard* (l: admin, p: secrete) on this Logical L2 network and test connectivity with ping.

### Troubleshoot Horizon


### Conclusion

Complicated network Setup.
### Rackspace Private Cloud Links

* RPC v9.0.1 [Installation Guide](http://docs.rackspace.com/rpc/api/v9/bk-rpc-installation/content/rpc-common-front.html)






* [Software homepage](http://www.rackspace.com/cloud/private)
* [4.2.1 Release Notes](http://www.rackspace.com/knowledge_center/article/rackspace-private-cloud-v421-release-notes-0)
* [Knowledge Center](http://www.rackspace.com/knowledge_center/getting-started/rackspace-private-cloud)
* [Configuring OpenStack Networking](http://www.rackspace.com/knowledge_center/article/configuring-openstack-networking)
* [VMDK conversion tool](https://github.com/rcbops/support-tools/tree/master/vmdk-conversion)
* [Rackspace Private Cloud Repository](https://github.com/rcbops)
* [Forums](http://privatecloudforums.rackspace.com/)

### Deep dive Links

* [Understanding the Chef Environment File in Rackspace Private Cloud](http://developer.rackspace.com/blog/understanding-the-chef-environment-file-in-rackspace-private-cloud.html)
* [Deploy Rackspace Private Cloud v4.2.1 on Ubuntu Server](http://thornelabs.net/2013/12/19/deploy-rackspace-private-cloud-v421-on-ubuntu-server-with-neutron-networking-using-virtualbox-or-vmware-fusion-and-vagrant.html) with Neutron Networking Using VirtualBox or VMware Fusion and Vagrant.

### Neutron Links

* [Neutron documentation](http://docs.openstack.org/trunk/openstack-network/admin/content/)
* [Neutron typical workflow example](http://codepad.org/iPvpbEGu)

[rpc-archi-v9]: /images/posts/rpc-archi-v9.png "RPC v9 architecture" width=850px
[rpc-networking-target-v9]: /images/posts/rpc-networking-target-v9 "RPC v9 networking Target Host" width=850px