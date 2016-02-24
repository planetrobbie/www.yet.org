---
title: "Mirantis OpenStack 7.0 - Networking Templates"
created_at: 2015-10-15 19:16:00 +0100
kind: article
published: false
tags: ['howto', 'openstack', 'mirantis', 'fuel']
---

In my [previous article](/2015/10/mos7-reducedfootprint/) about Mirantis OpenStack 7.0 reduced footprint, I promised to talk about another new functionnality of MOS 7.0, [Networking Templates](https://docs.mirantis.com/openstack/fuel/fuel-7.0/operations.html#using-networking-templates), so here am I. For quite some times, you had no other choice then connecting all of your deployed nodes to all networks, even if they didn't really need it. For example there isn't any reason why a Ceph storage node should be connected to the private network, or you may want to segregate different Ceph traffic on different networks. All of this and even more became possible with MOS 7.0 by using Networking Templates. This functionnality is only available from Fuel CLI or API, please note, as soon as you start using templates you can't use the Web UI to setup node networking any more, execpt if you remove your template. Lets details the process to configure your OpenStack networking environment using networking templates to benefit from the maximum flexibility.

<!-- more -->

### Template structure

Networking templates are written using [YAML](http://yaml.org/spec/1.2/spec.html) syntax, and named after your environment ID `network_template_<ENV_ID>.yaml`. A template contain five different sections and start by a `adv_net_template` section which will englobe four other section for each *nodegroup*, a nodegroup is a set of nodes, grouped by similar networks characteristics, for example they can be deployed in the same rack.

Each block within *adv_net_template* start by the *nodegroup* name. If a node isn't part of any nodegroup, it will inheritate the default section config instead.

	adv_net_template:
	  default:
	    nic_mapping:
	      default:
	        if1: eth0       # admin
	        if2: eth1       # public
	        if3: eth2       # management
	        if4: eth3       # private
	        if5: eth4       # storage

I presume all this seems quite obscure, so lets clarify all this further.

All nodes outside any nodegroups will be aliasing their interface eth0, eth1, eth2,.. respectively with `if1`, `if2`, .., except if we define a specific nic_mapping section for them using their nodename like this

		  node-33:
            if1: eth1
            if2: eth3
            if3: eth2
            if4: eth0
            if5: eth4

You can avoid to use aliasing if all nodes have the same set of Nics, you can then use their Nic name directly.

Within each nodegroup block, you'll then find the following sections:

* **network_assignments** - define mapping between endpoints (bridge) and network names
* **network_scheme** - Template bodies for every template listed under templates_for_node_role
* **templates_for_node_role** - define network connectivity of each role by assigning network templates to node roles.
* **nic_mapping** - define NIC aliasing

Here is an example of a `network_assignments` section.

		network_assignments:
          storage:
            ep: br-storage
          private:
            ep: br-prv
          public:
            ep: br-ex
          management:
            ep: br-mgmt
          fuelweb_admin:
            ep: br-fw-admin

Our storage network will be using the br-storage endpoint, private will be using br-prv, etc... It's the default configuration by the way. You can view this as bridge name aliasing.

Before talking about network_scheme lets review and example of `templates_for_node_role` which allows us to define networking connectivity of each Fuel role.

		templates_for_node_role:
		        controller:
		          - public
		          - private
		          - storage
		          - common
		        compute:
		          - common
		          - private
		          - storage
		        cinder:
		          - common
		          - storage
		        ceph-osd:
		          - common
		          - storage

Controller nodes will be connected to all four networks, plus PXE not specified above, while cinder nodes don't need public or private connectivity. ceph-osd only need to be connected to the common network and to the storage network. We could have created more granular network connection for our Ceph OSD, we'll talk about that laterXXX.

Now to the last section, which is the most complicated, this is where all the action happens, or I should have said where all templates are defined using three subsections: `transformations`, `endpoints` and `roles`. 

* **transformation** - describe our endpoint creation from the physical interface
* **endpoints** - list of all endpoints introduced by our YAML.
* **roles** - mapping between network roles and endpoints.

Which gives for the storage part

	network_scheme:
      storage:
        transformations:
          - action: add-br
            name: br-storage
          - action: add-port
            bridge: br-storage
            name: <% if5 %>
        endpoints:
          - br-storage
        roles:
          cinder/iscsi: br-storage
          swift/replication: br-storage
          ceph/replication: br-storage
          storage: br-storage

In reality it's not that complex to understand, the transformations section uses `add-br` to create a new bridge named br-storage, and a port on that bridge connected to `if5` which is an alias of eth4. Transformation are applied using the l23network puppet [module](https://github.com/stackforge/fuel-library/blob/master/deployment/puppet/l23network/README.md) so you could use all available transformation from that module in your YAML file.


###

Now that we've understood the general syntax lets use it to address some specific requirements.

If you have only 2x 10G interfaces on your compute nodes and want to create a bond where to put all networks including the PXE one XXX ...



### Adding Extra Admin network

When you have a multiple rack deployment, where each rack lives in its own L2 domain which doesn't span other rack, you'll need to use the nodegroup feature. But not only that, you'll also need to create extra admin networks for each rack that will allow Fuel to serve IP address in all of the L2 domain of each rack.

To do just that, you just need to edit '/etc/fuel/astute.yaml' with a section like this one

	EXTRA_ADMIN_NETWORKS:
		extra_net_30:
		    dhcp_gateway: 10.30.0.2
		    dhcp_pool_end: 10.30.0.254
		    dhcp_pool_start: 10.30.0.100
		    ipaddress: 10.20.0.2 # should be Fuel Master Node IP Address
		    netmask: 255.255.255.0
		extra_net_40:
		    dhcp_gateway: 10.40.0.2
		    dhcp_pool_end: 10.40.0.254
		    dhcp_pool_start: 10.40.0.100
		    ipaddress: 10.20.0.2 # should be Fuel Master Node IP Address
    		netmask: 255.255.255.0


### Conclusion



### Links		

* Mirantis OpenStack 7.0 [official documentation](https://docs.mirantis.com/openstack/fuel/fuel-7.0/#guides)
* Networking Templates [documentation](https://docs.mirantis.com/openstack/fuel/fuel-7.0/operations.html#using-networking-templates)
* Networking Templates [examples repository](https://github.com/stackforge/fuel-docs/tree/master/examples/network_templates)
* Puppet l23network [Module](https://github.com/stackforge/fuel-library/blob/master/deployment/puppet/l23network/README.md) 

[mos7-networkingtemplates-1]: /images/posts/mos7-networkingtemplates-1.png width=750px


BUGS
no example --- https://bugs.launchpad.net/fuel/+bug/1508317


Tips from email


- All networks in network configuration should have gateways.
When you add new nodegroup and download network_ENVID.yaml, some networks from default nodegroup will have 'gateway: null'. You SHOULD change it to your real network router IP and set 'meta/use_gateway' to true ('meta/use_gateway' can be changed in Fuel 7.0 only). So, all networks should have static routes to all networks.

- If you want to change ip range for some network, please make sure you set 'meta/notation' to 'ip_ranges', not to 'cidr'. (Fuel 7.0 only, 6.1 does not allow to set IP ranges for all networks, i.e. does not allow to change 'meta/notation').
If you leave 'cidr', then your new ip ranges will not apply (only CIDR will apply).

- You should use different CIDRs for different networks in nodegroups
Otherwise static routes from all-to-all won't work.