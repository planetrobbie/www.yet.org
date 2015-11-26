---
title: "Mirantis OpenStack 7.0 - Node Groups"
created_at: 2015-11-25 10:58:00 +0100
kind: article
published: true
tags: ['howto', 'openstack', 'mirantis', 'fuel']
---

In large datacenters it's common for each rack to live in its own broadcast domain. Fuel allows to deploy nodes on different networks by leveraging its *Node Groups* functionnality. In this article we'll details the required steps to make this possible using *Mirantis OpenStack 7.0* and we'll also review Node Groups support improvements coming in MOS 8.0.

<!-- more -->

### Terminology

In such a large scale architecture, its often required to associate each rack with its own list of logical networks. So we can leverage the *Node Groups* functionnality of Fuel to create as much network declaration as we require for the following logical networks:

* public
* management
* storage
* fuelweb_admin

Each *Node Group* belong to an OpenStack Environment that can support multiple of them. Each node will then be assigned to a specific *Node Group* depending on its network connectivity.

### CLI

Upon installation, Fuel create a default *Node Group*
	
	# fuel nodegroup
	id | cluster | name   
	---|---------|--------
	1  | 1       | default
	5  | 5       | default


Stay tuned, I'll share more *Node Groups* CLI commands at the end of this article.

### Fuel DHCP configuration

By default Fuel will only provides IP addresses on its directly connected PXE network. You need to define the other remote PXE networks in the `/etc/fuel/astute.yaml` configuration file.

To declare another one, edit that configuration file

	# vi /etc/fuel/astute.yaml

Add a sections for each of them like this:

	"EXTRA_ADMIN_NETWORKS":
	  "rack-1":
	    "dhcp_gateway": "172.16.0.1"
	    "dhcp_pool_end": "172.16.0.254"
	    "dhcp_pool_start": "172.16.0.10"
	    "ipaddress": "10.20.0.70"
	    "netmask": "255.255.255.0"
	  "rack-2":
	    "dhcp_gateway": "172.16.10.1"
	    "dhcp_pool_end": "172.16.10.254"
	    "dhcp_pool_start": "172.16.10.10"
	    "ipaddress": "10.20.0.70"
	    "netmask": "255.255.255.0"

`ipaddress` above is the one from Fuel.

For this file to be taken into account, you now need to restart the cobbler container
	
	# dockerctl restart cobbler

Note: a bug has been created to correct our MOS 7.0 Operations guide which still refers to editing `/etc/cobbler/dnsmasq.template` within the cobbler container. In fact with MOS 7.0 this file will be created by Puppet based on the content of `/etc/fuel/astute.yaml`. You can check its content now, it should contain the newly created networks:

	# dockerctl shell cobbler
	# cat /etc/cobbler/dnsmasq.template

In this example, the added lines are

	#Net rack-1 start
	dhcp-range=rack-1,172.16.0.10,172.16.0.254,255.255.255.0,120m
	dhcp-option=net:rack-1,option:router,172.16.0.1
	dhcp-boot=net:rack-1,pxelinux.0,boothost,10.20.0.70
	#Net rack-1 end
	
	#Net rack-2 start
	dhcp-range=rack-2,172.16.10.10,172.16.10.254,255.255.255.0,120m
	dhcp-option=net:rack-2,option:router,172.16.10.1
	dhcp-boot=net:rack-2,pxelinux.0,boothost,10.20.0.70
	#Net rack-2 end


### Node Groups creation

As we've said in the introduction, each *Node Group* is associated with an OpenStack Environment, so if you don't know your environment ID start by checking it.

	# fuel env
	id | status      | name         | mode       | release_id | pending_release_id
	---|-------------|--------------|------------|------------|-------------------
	1  | operational | bulb_kilo    | ha_compact | 2          | None              
	5  | operational | bulb_reduced | ha_compact | 2          | None             	

For the remaining of this article, I'll be using environment ID 1,

Now create a new *Node Group* in your environment with a meaningful name: 

	fuel --env 1 nodegroup --create --name "rack-1"

### Networks configuration

While using the Multirack capabilities of Mirantis OpenStack 7.0, it is necessary to use the Command Line Interface. Mirantis Engineering team is currently working on adding UI support for Multirack deployments, see this [blueprint](https://github.com/openstack/fuel-specs/blob/master/specs/8.0/multirack-in-fuel-ui.rst) for details.

Start by downloading the corresponding OpenStack environment Network settings

	# fuel --env 1 network --download

This command create a file named `/root/network_1.yaml`, let see how to customize it.

#### Global settings

Nailgun auto-assigns belows VIPs based on networks CIDR/range, so changing them manually won't take any effect. You can safely leave them as is.

* *management_vip* - 2nd IP of the management CIDR
* *management_vrouter_vip* - 1st IP of the management CIDR
* *public_vip* - 2nd IP of the public CIDR

*floating_ranges* configuration, which should be a chunk of the public CIDR can be modified from the Fuel UI, so you may not need to change that line in the yaml file.

In my environment the corresponding lines look like this:

	management_vip: 10.0.3.2
	management_vrouter_vip: 10.0.3.1

	floating_ranges:
  	- - 192.168.1.151
      - 192.168.1.159

	public_vip: 192.168.1.141

#### Node Group networks section

For each created *Node Group* you need to edit the corresponding sections with valid information for *cidr, gateway* and *ip_ranges* for each logical network.

To find each section, you can search for the corresponding *group_id* that you'll get by running `fuel nodegroup` on Fuel Master Node.

Here is an example section for the public logical network

	- cidr: 172.16.1.0/24
  	  gateway: 172.16.1.1
  	  group_id: 7
  	  id: 26
  	  ip_ranges:
  	  - - 172.16.1.5
  	    - 172.16.1.126
  	  meta:
  	    cidr: 172.16.0.0/24
  	    configurable: true
  	    floating_range_var: floating_ranges
  	    ip_range:
  	    - 172.16.0.2
  	    - 172.16.0.126
  	    map_priority: 1
  	    name: public
  	    notation: ip_ranges
  	    render_addr_mask: public
  	    render_type: null
  	    use_gateway: true
  	    vips:
  	    - haproxy
  	    - vrouter
  	    vlan_start: null
  	  name: public
  	  vlan_start: null


All networks now **require a gateway**. When you download `network_1.yaml` for the first time after the *Node Group* creation, some networks will have `gateway: null` and `use_gateway: false`. You need to change it to your real network router IP and set `meta/use_gateway` to `true` ('meta/use_gateway' can only be changed in Fuel 7.0). As soon as you use *Node Group* to distribute compute nodes to different broadcast domains, all networks require static routes to all networks.

Note:

* If you change ip range for some network, please make sure you also set *meta/notation* to *ip_ranges*, not to *cidr*. (Fuel 7.0 only, 6.1 does not allow to change *meta/notation*).
* Within the meta section of each block, you should only modify *use_gateway* and *notation* fields, you shouldn't require to modify anything else.
* You should use different CIDRs for different networks in *Node Groups*. Otherwise static routes from all-to-all won't work.

#### Backup configuration file

Before uploading it, make a copy of it, if you re-download it could overwrite your modifications.

	# cp network_1.yaml network_1.yaml.new

#### Upload new configuration

Upload the new setup

	# fuel --env 1 network --upload

#### Check current applied Network Configuration

Re-download it to check if it got applied, errors won't be reported, so we better check if Fuel imported the setup

	# fuel --env 1 network --download

The content of `network_1.yaml` should be the one you expect, if not check your syntax again and restart the upload/download process.

### DHCP Relaying.

As soon as you want to deploy nodes on a remote network, you'll require a DHCP relay sitting on it to relay DHCP requests from your nodes to the Fuel Master Node.

A while back I shared that I'm setting up my [Bulb](/2014/11/bulb/) lab infrastructure using Ansible, so I'll also use it to setup the required DHCP relay, consult the DebOps [documentation](http://docs.debops.org/en/latest/ansible/roles/ansible-dhcpd/docs/defaults.html#isc-dhcp-relay-configuration) if you have any questions on that section. You can also read my [intro article](/2014/07/ansible/) or the one that details how to setup a [DHCP server](/2014/11/ansible-dhcpd/) using Ansible DebOps Galaxy Role.

Install Ansible and its dependencies.

Update your Ansible Inventory with the node you plan to use for your DHCP relay, we'll name it dcrouter.

	# vi /etc/ansible/hosts
	...
	[dcrouter]
	192.168.1.254
	...

Then install the DepOps DHCPd role:

	# ansible-galaxy install debops.dhcpd

Create a YAML file with the required configuration

	# vi vars-dcrouter-dhcpd.yml
	---

	dhcpd_mode: 'relay'
	dhcpd_relay_servers: [ '192.168.1.70' ]
	dhcpd_relay_interfaces: [ 'eth5' ]

	ansible_domain: bulb.int

	# where to ask for DNS Server / dhcpd_dns_servers
	ansible_default_ipv4.address: 192.168.1.221

Make sure to update the following settings above

`dhcpd_relay_servers` to your Fuel Master Node IP address.  
`dhcpd_relay_interfaces` to the interface on the Remote PXE network. If you use a vSphere VM as your DHCP relay server, make sure you set Promiscuous mode ON for the Port Group associated with the remote PXE network.  
`ansible_domain` to your domain name  

Now create a Playbook to assign the DHCPd DebOps Ansible role to your host:

	# vi bulb-dcrouter.yml
    ---
	# This playbook deploys a DC router for Fuel Lab. 
	- name: Infrastructure Services [Routing, DHCP Relay]
	  hosts: dcrouter

	  vars_files:
	    - vars-dcrouter-dhcpd.yml
	
	  roles:
	     - debops.dhcpd

Terminate this process by running the Playbook to configure your node.

	 # ansible-playbook bulb-dcrouter.yml

You should now have a fully operational DHCP Relay server. You'll find the DHCP server configuration within `/etc/default/isc-dhcp-relay`.

To see wether or not your Fuel Master Node receive and offer an IP address to your booted nodes consult the `/var/log/docker-logs/dnsmasq.log` log file.

Note: make sure the return packet, directed to the remote PXE network IP Range, will travel back using the same interface. It could be an issue if your Fuel node have multiple NiC with a default gateway on another network. In this situation you'll need to add a static route to your Remote PXE Network directed to the router where the requests are coming from:

	# route add -net 172.16.0.0/24 gw 10.20.0.254 metric 1

If you don't want to setup a permanent DHCP relay using our above Ansible method, you can use instead the following CLI command to start a dhcp-helper process:

	# dhcp-helper -s <IP-of-fuel-master> -i <IP-of-DHCP-NIC>

`-s` specifies the system to which packets are relayed, so is set to the IP address of the Fuel Master node.  
`-i `specifies the local interface where DHCP packets arrive, so is set to the IP address of the NIC that is connected to your DHCP network.  

### Assign Nodes to Node Group

Now that you have all the required configuration in place, you can boot your first node. *Fuel* should then automatically assign the node to the correct *Node Group* based on its assigned DHCP IP Address but you can enforce such an assignement.

Check Node IDs

	# fuel nodes

Assign any of them to specific *Node Group*

	# fuel nodegroup --env 1 --assign --node <list-of-node-ids> --group <nodegroup-id>

Note: If you get the following error message when assigning a node to a nodegroup:

	500 Server Error: Internal Server Error ('NoneType' object has no attribute 'network_config')

It's because you forgot to first add the node to your environment, adding a node not in an environment to a *Node Group* is a bad request. The error message is already [patched](https://bugs.launchpad.net/fuel/+bug/1508398) to give a better explanation. It should soon look like:

	Cannot assign node group <ID> to node <ID> Node is not allocated to cluster.

### Environment deployment

Once you've booted all your nodes and assigned the corresponding roles. You can deploy your OpenStack environment and check that everything looks good.

Good luck !

### Node Group Fuel CLI Cheatsheet

You can perform other *Node Groups* functions from Fuel CLI.

Here is a cheatsheet of the different operations you can perform:

#### List all node groups
	
	# fuel nodegroup
	id | cluster | name   
	---|---------|--------
	1  | 1       | default
	5  | 5       | default
	6  | 6       | default

#### Filter by Environment

	# fuel --env <ENV_ID> nodegroup

#### Create Node Groups

	# fuel --env <env_id> nodegroup --create --name "group 1"

#### Delete Node Groups

	# fuel --env <env_id> nodegroup --delete --group <group1_id>,<group2_id>,<group3_id>

#### Assign Node to Node Groups

	# fuel --env <env_id> nodegroup --assign --node <node1_id>,<node2_id>,<node3_id> --group <group_id>

### Limitations

* *Node Group* feature require to use an encapsulation protocol on the data network.
* A gateway must be defined for each logical network when the cluster has multiple *Node Groups*.
* All controllers must be members of the default *Node Group*; if they are not, the HAProxy VIP and Floating IP won't work[will be fixed in MOS 8.0 see below].
* Setting up additional PXE network is still a manual process. Mirantis Engineering is working on automating that part too.

### MOS 8.0

The manual editing process described above for `/etc/fuel/astute.yaml` won't be any more required in Mirantis OpenStack 8.0. Fuel will do the modification automatically when adding and configuring new Node Groups within `network_ENV.yaml`.

MOS 8.0 will have a dnsmasq configuration directory, `/etc/dnsmasq.d/` and will automatically dump the admin networks configuration in `/etc/hiera/networks.yaml` within the mcollective container as soon as you'll upload a modified `/root/network_ENV.yaml` configuration file.

It will also create new dnsmasq configuration file in `/etc/dnsmasq.d/` for each admin network ip range. You can split admin networks into IP ranges, and Fuel will create a separate config file for each IP range.

So briefly the new MOS 8.0 for Node Groups will look like this:

1. setup the physical network
1. setup the required DHCP relays
1. create a new OpenStack Environment
1. create a new Node Groups within that Environment for every rack
1. download network_ENV.yaml
1. update network_ENV.yaml to specify gateways, ip_ranges, and switch notations to ip_ranges
1. upload network_ENV.yaml
1. check fuel task to make sure network configuration is correct and accepted by Nailgun.
1. if you see ready for the tasks. You can continue on by assigning nodes to roles and deploy OpenStack.

MOS 8.0 will alternatively offer UI support for *Node Groups* which will allow the deployment engineer to do most of the required tasks from the Fuel UI without relying on Fuel CLI for all operations except for the configuration of additional fuelweb_admin network. This feature request enhancement is currently still being reviewed by Mirantis Engineering team.

One last thing, it will be possible in that release to deploy Controller in non default *Node Groups*, management and vrouter VIP will then be associated with the correct network. That's great if you want your Fuel Master Node and your controller deployed on different racks for example.

### Conclusion

*Node Groups* offers lots of flexibility to deploy compute nodes on different broadcast domain and is relatively simple to configure. It is also compatible with Mirantis Contrail Fuel Plugin which is often used on large scale deployments.

I'd like to thank *Aleksandr Didenko* and *Andrew Woodward* from Mirantis for their great support !!! Thanks guys.

I hope this article was usefull. Any questions, comments please contact me on [LinkedIn](http://fr.linkedin.com/in/planetrobbie).

Thanks.

### Links		

* Configuring Multiple Cluster Network [documentation](https://docs.mirantis.com/openstack/fuel/fuel-7.0/operations.html#configuring-multiple-cluster-networks)
* Implementation Multiple Cluster Networks [documentation](https://docs.mirantis.com/openstack/fuel/fuel-7.0/reference-architecture.html#mcn-arch)
* network-1.yaml [reference page](https://docs.mirantis.com/openstack/fuel/fuel-7.0/file-ref.html#network-1-yaml-ref)
* Multirack Fuel UI [Blueprint](https://github.com/openstack/fuel-specs/blob/master/specs/8.0/multirack-in-fuel-ui.rst)