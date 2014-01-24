---
title: "Deploying a nested OpenStack Havana using Rackspace Private Cloud 4.2.1"
created_at: 2014-01-25 11:05:00 +0100
kind: article
published: true
tags: ['howto', 'openstack', 'chef', 'devops']
---

Last year I published [an article](/2013/07/rackspace-private-cloud-v4/) that detailled a deployment of OpenStack Grizzly using *[Rackspace](http://www.rackspace.com)* private cloud solution, let's update it to the latest 4.2.1 version. You can stick on v4.1.3 if you want to stick on Grizzly instead of OpenStack Havana.

<!-- more -->

First of all let's details what's new since version 4.0. The newer 4.2.x branch now support:

* OpenStack Havana code base.
* Load Balancing as a Service in OpenStack Networking (Neutron) using the HAProxy service provider.
* full OpenStack Metering implementation (Ceilometer)
* OpenStack Orchestration (Heat) is now available as a tech preview with standard Heat and CloudWatch API. It can be enabled afterward by applying the Heat role to the controller node after deployment.
* Quantum has been renamed to Neutron
* L3 Agent now available, it enables floating IPs and routers.
* LVM is now the default provider for Cinder

But the biggest evolution is the fact that *RackSpace Private Cloud* is now declared Production Ready, yeah !!!

To see what was supported in 4.0, read our [previous article](/2013/07/rackspace-private-cloud-v4/), also read our previous post if you need the full blown details. Here we will keep the bare minimum explanations.

This time we will deploy our OpenStack Havana private cloud nested within an OpenStack cloud.

### Installation workflow

To get a running lab environment with *OpenStack Havana*, we'll follow this checklist :

1. Provision three Ubuntu 12.04 Nodes 
2. Install *Chef Server* 11.10
3. Configure a Chef Workstation
3. Clone the latest Rackspace cookbooks to the *Chef Server*
4. Bootstrap each node, install *chef-client* and register them to *Chef-Server*
5. Configure Havana Environment, Assign Controller and Compute Roles to nodes and apply them.
6. Update Networking of our nodes, Switch over to Neutron Networking
7. Test the environment

### Provision three Ubuntu 12.04 nodes.

Let's first provision three Ubuntu 12.04 instances, connected on the following networks, adapt your IPs accordingly.

|Instance name|External Network [eth2]|Management [eth1]|Floating IP|Transport-1 [eth0]|
|:-|:-|
|chef-server|192.168.1.20|10.0.0.14|10.36.1.223||
|havana-controller|192.168.1.2|10.0.0.11|10.36.1.224|10.10.1.9|
|havana-compute-01|192.168.1.21|10.0.0.14|10.36.1.226|10.10.1.5|

make sure they Ubuntu is up to date by doing

    apt-get update
    apt-get upgrade

### Install Chef Server

Instead of relying on Rackspace Chef installation procedure, let's use the official way to install a Chef server. Download the Chef Server deb package from [http://www.opscode.com/chef/install/](http://www.opscode.com/chef/install/) and install it with the two commands below.

    sudo dpkg -i chef-server_<VERSION>.deb
    sudo chef-server-ctl reconfigure

Before going to the next section test your installation of Chef

    sudo chef-server-ctl test

### Chef Workstation

We'll use the same Ubuntu server as a Chef Workstation, so download and install the Chef client omnibus deb package on it:

    sudo dpkg -i chef_<VERSION>.deb

Add `chef-client` to your PATH

    echo 'export PATH="/opt/chef/embedded/bin:$PATH"' >> ~/.bash_profile && source ~/.bash_profile

Create `chef-client` configuration directory

    mkdir ~/.chef

Copy `chef-server` keys to this directory

    sudo cp /etc/chef-server/admin.pem ~/.chef; sudo chown <user> ~/.chef/admin.pem
    sudo cp /etc/chef-server/chef-validator.pem ~/.chef; sudo chown <user> ~/.chef/chef-validator.pem

Configure your workstation with

    knife configure -i \
      -u <user> \
      -s https://chef-server.lab.int:443 \
      -r /home/<user>/ \
      --admin-client-name admin \
      --admin-client-key /home/<user>/.chef/admin.pem \
      --validation-key /home/<user>/.chef/chef-validator.pem \
      --validation-client-name chef-validator

Test it worked with

    knife client list

### Rackspace OpenStack cookbooks

You now have to import all the Rackspace cookbooks to your Chef Server using

    git clone https://github.com/rcbops/chef-cookbooks.git
    cd chef-cookbooks
    git checkout 4.2.1
    git submodule init
    git submodule sync
    git submodule update  
    knife cookbook upload -a -o cookbooks
    knife role from file roles/*rb

But if you are in a hurry you can use this script instead:

	 curl -s -L https://raw.github.com/rcbops/support-tools/master/chef-install/install-cookbooks.sh | \
      bash

If this command fails or if you get a connection timeout error verify that your hostname (FQDN) is correctly configured.

### OpenStack nodes bootstrapping

Both Controller and Compute nodes should have a `/etc/network/interfaces` file which look like this. You can limit the External Network section to your controller node which can be the only one to have external access.

    auto lo
    iface lo inet loopback
    
    auto eth0 eth1 eth2
  
    # Transport Network 
    iface eth0 inet manual
            up ip link set $IFACE up
            down ip link set $IFACE down
    
    # Management Network
    iface eth1 inet static
            address 10.0.0.14
            netmask 255.255.255.0
            broadcast 10.0.0.255
            network 10.0.0.0
    
    # External Network
    iface eth2 inet static
            address 192.168.1.21
            netmask 255.255.255.0
            network 192.168.1.0
            broadcast 192.168.1.255
            gateway 192.168.1.1
            dns-nameservers 8.8.8.8 8.8.4.4

Note: `eth0` will be used in the second part of this lab when we'll switch to Neutron Networking.

On each Ubuntu 12.04 provisioned nodes we will enable passwordless ssh. On your `chef-server` generate an ssh key

	 chef-server> ssh-keygen

accept all defaults and copy the generated key to the root user of all your nodes (require to assign a password to root first)

	 chef-server> ssh-copy-id root@<node-floating-IP>

If it fails, you have to first assign a password to the root account.

Now if you are in a hurry use the bootstrap command below for each of your host:

    knife bootstrap havana-controller --server-url https://chef-server.lab.int:443
    knife bootstrap havana-compute-01 --server-url https://chef-server.lab.int:443

Or use a step by step workflow which starts by transfering and installing the *chef-client* to all of your nodes

    chef-server> scp chef_11.8.2-1.ubuntu.12.04_amd64.deb root@havana-controller:/tmp/
    chef-server> scp chef_11.8.2-1.ubuntu.12.04_amd64.deb root@havana-compute-01:/tmp/

Run the installation command on your nodes

    havana-controller> dpkg -i /tmp/chef_11.8.2-1.ubuntu.12.04_amd64.deb
    havana-compute-01> dpkg -i /tmp/chef_11.8.2-1.ubuntu.12.04_amd64.deb

Copy the Validation key to your Chef nodes

    chef-server> scp /etc/chef-server/chef-validator.pem root@havana-controller:/etc/chef/validation.pem
    chef-server> scp /etc/chef-server/chef-validator.pem root@havana-compute-01:/etc/chef/validation.pem

On each node, create the `/etc/chef/client.rb` file with the following content

    chef_server_url 'https://chef-server.lab.int:443'
    chef_environment '_default'

You can now register your node with your chef-server:

    havana-controller> chef-client
    havana-compute-01> chef-client

If you haven't registered the Chef Server FQDN with your DNS, make sure you add it to the `/etc/hosts` of your node.

You can check your nodes are registered on the Chef Server

    chef-server> knife node list

### OpenStack Controller

In the previous steps we prepared all the required nodes to be managed by Chef. It's now time to create a Chef environment for our Havana deployment

	 knife environment create havana -d "Havana OpenStack Environment"
	 knife environment edit havana

In this environment file you need to describe your network environment, for now we'll stick with nova-network. We'll change this to use Neutron later on. Edit the following section of the environment:

	 "override_attributes": {
      "nova": {
        "network": {
          "provider": "nova"
          "public_interface": "br100"
        },
        "networks": {
          "public": {
            "label": "public",
            "bridge_dev": "eth1",
            "dns2": "8.8.4.4",
            "ipv4_cidr": "12.0.0.0/24",
            "bridge": "br100",
            "dns1": "8.8.8.8"
          }
        }
      },
      "mysql": {
        "allow_remote_root": true,
        "root_network_acl": "%"
      },
      "osops_networks": {
        "nova": "192.168.1.0/24",
        "public": "192.168.1.0/24",
        "management": "10.0.0.0/24"
      }

`nova > network > provider` specifies which OpenStack Networking model to use: *nova-network* or *neutron*

`nova > network > public_interface` specifies which network interface on the compute nodes *nova-network* floating IP addresses will be assigned to.

`nova > networks > public` setup a *nova-network* that allows outbound network access from the instances. Fixed network not 
to be confused with the public network setup in the osops_networks block.

`nova > networks > private` setup a *nova-network* that only allows instance-to-instance communication (not used here)

`nova > networks > bridge_dev` interface to be attached to the `bridge` created at installation

`osops_networks` define where to bind OpenStack services. See in the table below to see which service bind to which osops_networks.

|nova|pubic|management|
|:-|:-|
|keystone-admin-api|graphite-api|graphite-statsd|
|nova-xvpvnc-proxy|keystone-service-api|graphite-carbon-line-receiver|
|nova-novnc-proxy|glance-api|graphite-carbon-pickle-receiver|
|nova-novnc-server|glance-registry|graphite-carbon-cache-query|
||nova-api|memcached|
||nova-ec2-admin|memcached|
||nova-ec2-public|mysql|
||nova-volume|keystone-internal-api|
||neutron-api|glance-admin-api|
||cinder-api|glance-internal-api|
||ceilometer-api|nova-internal-api|
||horizon-dash|nova-admin-api|
||horizon-dash_ssl|cinder-internal-api|
|||cinder-admin-api|
|||cinder-volume|
|||ceilometer-internal-api|
|||ceilometer-admin-api|
|||ceilometer-central|

To switch all your nodes to the newly created havana environment from the chef-server use (only use this if you don't have any other nodes registered with your Chef-Server)

	 knife exec -E 'nodes.transform("chef_environment:_default") \
  	 { |n| n.chef_environment("havana") }'

We will now associate the single-controller role to a node

	 knife node run_list add havana-controller 'role[single-controller]'

To install the node, you just have to run on the node itself

	 chef-client

Wait a bit and you'll get a shinny new Havana Controller node.

Note: I had to manually restart the MySQL daemon using `/etc/init.d/mysql restart` because the process wasn't listening on the configured address which halted the chef run.

Later on you'll need at least an image to launch instances. Connect to Horizon Dashboard at `https://havana-controller.lab.int` to upload a Cirros image. (login: admin, password: secrete). Or run the following commands:

    havana-controller> source /root/openrc
    havana-controller> glance image-create --name cirros-0.3.1-x86_64 --is-public true --container-format bare --disk-  format qcow2 --copy-from http://download.cirros-cloud.net/0.3.1/cirros-0.3.1-x86_64-disk.img

You can also add other images 

    havana-controller> glance image-create --name ubuntu-server-12.04 --is-public true --container-format bare --disk-format qcow2 --copy-from http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img<
    havana-controller> glance image-create --name fedora-19-x86_64 --is-public true --container-format bare --disk-format qcow2  --copy-from http://download.fedoraproject.org/pub/fedora/linux/releases/19/Images/x86_64/Fedora-x86_64-19-20130627-sda.qcow2

### Compute Node

It's now time to add compute nodes to your cloud

    knife node run_list add havana-compute-01 'role[single-compute]'

To apply the role to your node run

    chef-client

Repeat this process for all your compute nodes. At the end of this process you can check all nodes are correctly installed with 

    nova hypervisor-list

Note: If you don't see your nodes listed here, make sure communication is possible between hypervisors and controller on the configured management network.

### Launch your first instance

Let's test our installation by launching a Cirros instance. First we need to add some security rules

    nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
    nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0

Our Instances will be given IP addresses in the 12.0.0.0/24 private network, you won't be able to access them without associating a floating IP. So you need to add a floating IP range:

    nova-manage floating create 192.168.1.64/28 public

From the Horizon Dashboard you can now click on `Allocate IP to Project` a few times to make IPs available for your project.

Before you can launch your first instance, you just have to create or use an existing SSH key pair. You can import your existing `.ssh/id_rsa.pub` or create a newer one using `ssh-keygen`, it's even possible to do that step from the Horizon Dashboard.

### Neutron Networking

#### Switch Havana Environment to Neutron.

It's now time to switch to *Neutron* Networking from *nova-network*, to do that just edit the Havana chef environment

    knife environment edit

It should look like that

    {
       "name": "havana",
       "description": "Rackspace Private Cloud v4.2.1 - OpenStack Networking",
       "cookbook_versions": {
       },
       "json_class": "Chef::Environment",
       "chef_type": "environment",
       "default_attributes": {
       },
       "override_attributes": {
         "nova": {
           "network": {
             "provider": "neutron"
           }
         },
         "neutron": {
           "ovs": {
             "provider_networks": [
               {
                 "label": "ph-eth0",
                 "bridge": "br-eth0"
               }
             ],
             "network_type": "gre"
           }
         },
         "mysql": {
           "allow_remote_root": true,
           "root_network_acl": "%"
         },
         "osops_networks": {
           "nova": "192.168.1.0/24",
           "public": "192.168.1.0/24",
           "management": "192.168.1.0/24"
         }
       }
     }


`nova > network > provider` now we swith to neutron as our network provider, Chef will then install additional components: neutron-server, etc...

`neutron > ovs > network_type` sets the default type of Neutron Tenant Network created when it is not specified in the neutron net-create command. Can be set to : vlan, flat, gre.

`neutron > ovs > provider_networks > label & bridge` just a label for the following `bridge` parameter that points to the particular bridge interface to use for Neutron Networking traffic

#### Converge your controller with OpenStack Networking

Apply the single-network-node role to your controller

    knife node run_list add havana-controller 'role[single-network-node]'

And deploy the neutron components on your controller.

    chef-client

You can check Neutron OVS configuration on a running instance in the `/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini` file. And as usual run

#### Transport Interface configuration

Now make sure that on each of your compute nodes you have one management interface and a physical provider interface `eth0` for the transport network, up but without any IP addresses setup.

As a reminder the setup of this interface in `/etc/network/interfaces` should look like this

    auto eth0 
    iface eth0 inet manual 
       up ip link set $IFACE up 
       down ip link set $IFACE down

If you change anything in that file, use the following command to bring refresh network setup.

    /etc/init.d/networking restart

#### Add physical transport interface to br-eth0

When using Neutron there are additional steps required after running `chef-client` on each node.

All VM communication between the nodes will be done via the transport network on `eth0` in our case. On each compute node run

    ovs-vsctl add-port br-eth0 eth0

#### Add physical external interface to br-ex

External connectivity will be provided by `br-ex` on the network/controller node, attach a physical interface to it

    ovs-vsctl add-port br-ex eth2

For this to work, you have to unbind the IP address attached to the physical NIC (eth1) and associate it instead to the external Bridge. So update `/etc/network/interfaces` on your controller like this:

    auto <PUT ALL INTERFACES HERE>
    iface br-ex inet static
      address <EXTERNAL NETWORK IP>
      netmask <EXTERNAL NETWORK MASK>
      network <EXTERNAL NETWORK ADRESS>
      broadcast <EXTERNAL NETWORK BROADCAST>
      gateway <EXTERNAL NETWORK GATEWAY>
      dns-nameservers <EXTERNAL NETWORK DNS SERVERS>
    
    iface eth2 inet manual
      up ip link set $IFACE up
      down ip link set $IFACE down

And run again

    /etc/init.d/networking restart

#### Source Environment

To be able to use OpenStack command line interface you have to source the environment prepared by Chef

    source /root/.openrc

#### Create External Network entity

Your environment is now almost ready for Neutron. The current implementation supports VLAN or GRE isolated networks. In our Lab we'll use GRE.

First create an external network, used for floating IPs

    neutron net-create ext-net -- --router:external=True --provider:network_type=local

`--provider:network_type local` means that networking does not have to realize this network through a provider network.

`--router:external=True` means that an external network is created where you can create floating IP and router gateway port.

Create a Subnet for that external network (adapt the range accordingly)

    neutron subnet-create ext-net \
      --allocation-pool start=10.0.0.100,end=10.0.0.120 \
      --gateway=10.0.0.1 --enable_dhcp=False \
      10.0.0.0/24

#### Logical Network

On the Controller node, create a provider network with the neutron net-create command.

    neutron net-create --provider:network_type=gre \
    --provider:segmentation_id=100 production-internal

Customize Default security group

    neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 default
    neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol icmp default

#### Logical Router

Create a logical router

    neutron router-create lr-01

Attach this router to the ext-net network

    neutron router-gateway-set lr-01 ext-net

Create a new gre backed network named production-net

	 neutron net-create --provider:network_type=gre \
 	  --provider:segmentation_id=100 production-net

Create a subnet in the newly created network

	 neutron subnet-create --name range-one production-net 16.0.0.0/24

If your gateway isn't on 16.0.0.1, you can specify it with `--gateway-ip`.

Attach private network to router

    neutron router-interface-add ls-01 production-net

#### Testing

You can now launch 2 VMs using *Cirros* image from *Horizon Dashboard* (l: admin, p: secrete) on this Logical L2 network and test connectivity with ping.

### Update Cookbooks

If for any reason you want to try the latest Rackspace private cloud version, you can update your cloned repository like this.

Change into the chef-cookbooks directory:
 
    cd /root/chef-cookbooks
 
Checkout the master branch:
 
    git checkout master
 
Pull the latest code:
     
    git pull
 
Checkout the RPC v4.2.1 tag or the latest one you want to test:
 
    git checkout v4.2.1
 
Initialize your local configuration file:
 
    git submodule init
 
Fetch all data from the submodules:
 
    git submodule update
 
This is optional, but to ensure only the latest cookbooks are used, delete all of the current Chef Cookbooks from the Chef Server (only perform this on a Chef Server dedicated to Rackspace Private Cloud):
 
    knife cookbook bulk delete .
 
This is optional, but to ensure only the latest roles are used, delete all of the current Chef Roles from the Chef Server (only perform this on a Chef Server dedicated to Rackspace Private Cloud):
 
    knife role bulk delete .
 
Upload cookbooks to the Chef Server:
 
    knife cookbook upload -a -o cookbooks
 
Upload roles to the Chef Server:
 
    knife role from file roles/*.rb

You are now good to go with the latest release.

### Troubleshoot Horizon

After the installation, the next day I couldn't log back in the Horizon Dashboard. I had to do the following to enable DEBUG information troubleshoot it:

    sed -i -e 's/^DEBUG = .*/DEBUG = True/' /etc/openstack-dashboard/local_settings.py
    service apache2 restart

I then got the following error

    [Sat Jan 18 09:49:25 2014] [error] DEBUG:openstack_auth.backend:Authorization Failed: Invalid URL u'://192.168.1.2:5000/v2.0/tokens': No schema supplied

This is in fact reported as a current bug in the 4.2.1 branch when you have different networks for Management and Public declared in your environment, to workaround it you have to add the following JSON block in your Havana environment

    "horizon": {
      "endpoint_type": "publicURL",
      "endpoint_scheme": "http"
    },

Note: This block won't be needed any more when the bug will be patched.

### Conclusion

The only things lacking from Rackspace private cloud solution is a bare metal provisioning tool but you'll find plenties around like Cobbler or Razor.   

It provides a really proven framework to deploy OpenStack which is really the most mature one compared to Stackforge or Crowbar from my point of view right now.

### Rackspace Private Cloud Links

* [Software homepage](http://www.rackspace.com/cloud/private)
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

[rpc-archi]: /images/posts/rpc-archi.png
[rpc-network-archi]: /images/posts/rpc-network-archi.png
[rpc-neutron]: /images/posts/rpc-neutron.png
[rpc-neutron-inside]: /images/posts/rpc-neutron-inside.png width=750px
[rpc-neutron-inside-2]: /images/posts/rpc-neutron-inside-2.png width=850px