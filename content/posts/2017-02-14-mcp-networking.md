---
title: "MCP Cookbook - Open vSwitch Networking"
created_at: 2017-02-14 15:00:00 +0100
kind: article
published: true
tags: ['cookbook', 'openstack', 'mcp', 'networking', 'ovs', 'salt']
---

As we've already seen in our [previous articles](/tags/salt/) *Mirantis Cloud Platform (MCP)* is really flexible and can tackle lots of different use cases. Last time we've looked at [using Ceph](/2017/01/mcp-ceph/) as the OpenStack storage backend. Today we are reviewing different ways to leverage Neutron Open vSwitch ML2 plugin instead of the standard OpenContrail SDN solution to offer networking as a service to our users.

<!-- more -->

### Introduction

To model Open vSwitch Networking in MCP, we first have to choose between different options. What kind of segmentation we'll be using for our tenant networks, `VxLAN` or `VLAN` ? Do we want to use distributed routers (`DVR`) for East-West routing, and also to directly access floating IPs on Compute ?

Let see how we can achieve all of this and more from our model.

### VxLAN or VLAN segmentation ?

Specifying which network segmentation will be used is as simple as specifying it in a single configuration line.

#### VxLAN segmentation:

    #!yaml
    # vi classes/cluster/xxx/openstack/init.yml
    parameters:
      _param:
        neutron_tenant_network_types: "flat,vxlan"

Notes:

* In the remaining of the article, replace `xxx` by the cluster name you choosed when you've generated your model.
* If you use VxLAN make sure the data network MTU is set to at least 1550, we'll see this later.

#### VLAN segmentation:

Instead set

    #!yaml
        neutron_tenant_network_types: "flat,vlan"  

If you need to auto assign `VLANs` ID to your tenant network, you also have to specify a `VLAN` ID range

    #!yaml
        neutron_tenant_vlan_range: "1200:1900"

MCP will then configure these VLANs in `/etc/neutron/plugins/ml2/ml2_conf.ini`, we'll explain bridge mappings in the next chapter but they will be assigned to physnet2 like this

    #!yaml
    network_vlan_ranges = physnet1,physnet2:1200:1900

So if a tenant then ask for a network, `VLAN` segmented, an ID within the 1200-1900 pool will be automatically selected, traffic will go thru the bridge associated with `physnet2` (`br-prv`). When an external provider network will be created with a VLAN outside of this range, the traffic will then go thru `physnet1` (`br-floating`) which allow all VLANs (nothing set), it's an easy way to differentiate tenant networks and external networks traffic paths.

#### both VxLAN and VLAN segmentation

It's also possible to allow both `VxLAN` and `VLAN` tenant network types with

    #!yaml
        neutron_tenant_network_types: "flat,vlan,vxlan"

In this situation the ordering matters, if `VLAN` is first, neutron will first consume all available `VLAN` ID from the allocated Pool (`network_vlan_ranges`) before creating any VxLAN backed network. If it were opposite it would instead create VxLAN backed tenant networks by default.

#### about neutron VRRP HA routers

Neutron HA router VRRP heartbeat will be exchanged on a tenant network created using the `VLAN` or `VxLAN`. In the case above, if you use both, the first one in the list will be choosen. If you want otherwise it's possible to specify it in `l3_ha_network_type` but this isn't parametrized in neutron salt formula yet, so easiest way is to use a good ordering above instead. You also have to know that even if you remove all HA routers of your project, the ha network will stay behind waiting for new routers to be instantiated, but you won't see these networks, only cloud admin can.

But lets talk again about these routers later on.

### Distributed Virtual Router (DVR) ?

Still in `openstack/init.yml`, you can specify if you want to use `DVR` or not, with the following parameters.

|_param|Non DVR|DVR east-west <br> network nodes for north-south|DVR east-west <br> floating IP on compute|
|:-:|:-:|:-:|:-:|
|neutron_control_dvr|False|True|True|
|neutron_gateway_dvr|False|True|True
|neutron_compute_dvr|False|True|True|
|neutron_gateway_agent_mode|legacy|dvr_snat|dvr_snat|
|neutron_compute_agent_mode|legacy|dvr|dvr|
|neutron_compute_external_access|False|False|True|

All DVR use cases will set `router_distributed` to True in `neutron.conf` so all tenant routers will be DVR based by default.

So as an example if you want DVR for both east-west and floating IPs with VxLAN segmentation and L3 HA routers, you should have in your `openstack/init.yml`

    #!yaml

    _param:
      neutron_tenant_network_types: "flat,vxlan"
      neutron_control_dvr: True
      neutron_gateway_dvr: True
      neutron_compute_dvr: True
      neutron_gateway_agent_mode: dvr_snat
      neutron_compute_agent_mode: dvr
      neutron_compute_external_access: True
      neutron_l3_ha: True
      neutron_global_physnet_mtu: 9000
      neutron_external_mtu: 9000

By having `neutron_compute_external_access` set as True a bridge mapping (`physnet1`) to `br-floating` will be created on compute to allow them to access public network for instance floating IPs. North-South traffic of instances with floating IPs can then avoid to go thru network nodes.

<!-- Image of 4 different use cases with flows -->

If you use DVR keep in mind that they are incompatible with advanced services (LBaaS, FWaaS, VPNaaS), IPv6 and L3 HA routers but work is under way to add more support.

### other settings

When the neutron salt state will be run on our `neutron-servers`, the following additional settings set in `openstack/init.yml` can also be applied to its configuration files.

|_param|meaning|/etc/neutron/...|conf param|default|
|:-:|:-:|
|`neutron_l3_ha`|use VRRP for router HA ?|neutron.conf|l3_ha|False|
|`neutron_global_physnet_mtu`|MTU of the underlying physical network|`neutron.conf`|`global_physnet_mtu`|1500|
|`neutron_external_mtu`|MTU associated with external network (`physnet1`)|`plugins/ml2/ml2_conf.ini`|`physical_network_mtus`|1500|

### Neutron Bridge mappings

A bridge mapping is a comma-separated list of <physical_network>:<bridge> tuples defining provider bridges that connect to physical interfaces used for tagged (`VLAN`) and untagged (flat) traffic.

Depending on the segmentation you've choosen, `VxLAN` or `VLAN` different mappings will be configured by our [salt-formula-neutron]() in `/etc/neutron/plugins/ml2/openvswitch_agent.ini`. As you'l see below as soon as you use `VLAN` tenant network type, a `physnet2` mapping will be configured to `br-prv`.

|VxLAN|centralized|DVR east-west|DVR for all|
|:-:|:-:|:-:|:-:|
|*Network nodes*|physnet1:br-floating|||
|*Compute nodes*|empty||physnet1:br-floating|

|VLAN|centralized|DVR for all|
|:-:|:-:|:-:|:-:|
|*Network Nodes*|physnet1:br-floating,physnet2:br-prv||
|*Compute Nodes*|physnet2:br-prv|physnet1:br-floating,physnet2:br-prv|

`br-floating` is a provider OVS bridge, created by admin, connected to the external/public network and mapped to physnet1.  
`br-prv` is a provider OVS bridge, created by admin, connected to the data network (VLAN segmented), it will be automatically connected to the integration bridge (`br-int`) where all guests are connected. It's the tenant traffic bridge, mapped to physnet2.

But you don't have to care too much about these mappings, they are managed by the [neutron salt formula](http://github.com/salt-formulas/salt-formula-neutron) based on the value of `neutron_tenant_network_types` and `neutron_control_dvr` as described in the above table.

### Linux Networking > Bonds and Bridges settings

We've just added mapping to Open vSwitch bridges, they need to exist on our nodes or neutron won't be happy. So lets configure them by specifying Pillar data that will be consumed by our [salt-formula-linux](http://github.com/salt-formulas/salt-formula-linux) for their creation on network and compute nodes.

Pillar data for compute and gateways needs to be specified respectively in `classes/cluster/xxx/openstack/compute.yml` and `classes/cluster/xxx/openstack/gateways.yml`.

|Network requirements|VxLAN|||VLAN||
|:-:|:-:|:-:|:-:|:-:|:-:|
|*routing*|centralized|`DVR`<br>east-west|`DVR` for all|centralized|`DVR` for all|
|*network nodes*|`br-floating`<br>`br-mesh`<br>(port on `br-floating`)|||`br-floating`<br>`br-prv`<br>(connected to `br-floating`)||
|*compute nodes*|`br-mesh`<br>(linux bridge)||`br-floating`<br>`br-mesh`|`br-prv`|`br-floating`<br>`br-prv`<br>(connected to `br-floating`)|

`br-mgmt` is also required on all nodes for Openstack and other management traffic.

Lets decompose the different requirement in the next few sections.

#### br-floating

This Open vSwitch bridge is required in all of our use cases. It can easily be created from this YAML Pillar data snippet that should be present in both `gateways.yml` and also `compute.yml` if you want your floating IPs to be directly accessible (`DVR` for all)

    #!yaml
    parameters:
      linux:
        network:
          bridges: openvswitch
          interfaces:
            br-floating:
              enabled: true
              type: ovs_bridge

It will be useless without any connectivity, so we have to have also a bond with some physical interfaces connected to the public network associated with it. VLAN tagging will be managed on by Neutron API.

    #!yaml
            primary_second_nic:
              name: ${_param:primary_second_nic}
              enabled: true
              type: slave
              mtu: 9000
              master: bond0
            primary_first_nic:
              name: ${_param:primary_first_nic}
              enabled: true
              type: slave
              mtu: 9000
              master: bond0
            bond0:
              enabled: true
              proto: manual
              ovs_bridge: br-floating
              ovs_type: OVSPort
              type: bond
              use_interfaces:
              - ${_param:primary_second_nic}
              - ${_param:primary_first_nic}
              slaves: ${_param:primary_second_nic} ${_param:primary_first_nic}
              mode: 4
            mtu: 9000

You can replace LACP (mode 4), by `active-backup` if you prefer.

#### Nics names

You may wonder where these `primary_first_nic` and `primary_second_nic` are defined ? We've parameterized these Nic names to avoid to repeat ourselves. Each nodes define its nics into `classes/cluster/xxx/infra/config.yml` like this

    #!yaml
    # vi classes/cluster/xxx/infra/config.yml
    classes:
      - system.reclass.storage.system.openstack_gateway_cluster
      ...
      parameters:
        reclass:
          storage:
            node:
              ...
              openstack_gateway_node01:
                params:
                  primary_first_nic: enp3s0f0
                  primary_second_nic: enp3s0f1


More parameters for each of our nodes are defined in Mirantis system repo.

For example a cluster of three gateways (`gtw01,gtw02,gtw03`) are already defined in `system.reclass.storage.system.openstack_gateway_cluster` so you just need to define their nics `${_param:primary_xxx_nic}` as shown above, the rest will be inherited. It's the purpose of *[Reclass](/2016/10/reclass/)* itself, to abstract away the complexity from the cloud admin.

#### br-mesh | br-prv

Apart from the `br-floating`, our network and compute nodes also require a connectivity to our data network, using `br-mesh` (`VxLAN`) or `br-prv` (`VLAN`) for tenant traffic.

##### br-mesh on compute

On compute, if you've selected `VxLAN`, you have to create a `br-mesh` linux bridge to handle encapsulated traffic, bind a `tenant-address` and associate a VLAN subinterface of our bond to it.

    #!yaml
    # vi classes/cluster/xxx/openstack/compute.yml
    parameters
      linux:
        network:
          interface:
            ...
            br-mesh:
              enabled: true
              type: bridge
              address: ${_param:tenant_address}
              netmask: <DATA_NETWORK_NETMASK>
              mtu: 9000
              use_interfaces:
              - <BOND>.<VLAN_ID>

##### br-mesh on network nodes

On Network nodes, `br-mesh` is an OVS internal ports of `br-floating` with tag and ip addresses
    
    #!yaml
            br-mesh:
              enabled: true
              type: ovs_port
              bridge: br-floating
              proto: static
              ovs_options: tag=<DATA_NETWORK_VLAN_ID>
              address: ${_param:tenant_address}
              netmask: <DATA_NETWORK_NETMASK>

##### br-prv on compute

For VLAN segmentation, you need to create instead a `br-priv` OVS Bridge and connect a bond to it. VLANs will be managed by Neutron API.

    #!yaml
    # vi classes/cluster/xxx/openstack/compute.yml
    parameters:
      linux:
        network:
          bridge: openvswitch
          interface:
            bond0:
              enabled: true
              proto: manual
              ovs_bridge: br-prv
              ovs_type: OVSPort
              type: bond
              use_interfaces:
              - ${_param:primary_second_nic} ${_param:primary_first_nic}
              slaves: ${_param:primary_first_nic}
              mode: 4
              mtu: 9000
            br-prv:
              enabled: true
              type: ovs_bridge

##### br-prv on network nodes
    
On network nodes, `br-prv` is a OVS Bridge connected to `br-floating`.

    #!yaml
    # vi classes/cluster/xxx/openstack/gateway.yml
    parameters:
      linux:
        network:
          bridge: openvswitch
          interface:
            ...
            br-prv:
              enabled: true
              type: ovs_bridge
            floating-to-prv:
              enabled: true
              type: ovs_port
              port_type: patch
              bridge: br-floating
              peer: prv-to-floating
            prv-to-floating:
              enabled: true
              type: ovs_port
              port_type: patch
              bridge: br-prv
              peer: floating-to-prv

#### br-mgmt

Lastly `br-mgmt` is also required on all nodes for Openstack and other management traffic, by the way it isn't specific to our Open vSwitch ML2 plugin, It's also required for OpenContrail plugin.

##### br-mgmt on compute

On compute node it's a linux bridge connected to a bond subinterface

    #!yaml
    # vi classes/cluster/xxx/openstack/gateway.yml
    parameters:
      linux:
        network:
          bridge: openvswitch
            interface:
              bond0.<MGMT_NETWORK_VLAN_ID>:
                enabled: true
                type: vlan
                proto: manual
                mtu: 9000
                use_interfaces:
                - bond0
              br-mesh:
                enabled: true
                type: bridge
                address: ${_param:tenant_address}
                netmask: <MGMT_NETWORK_NETMASK>
                mtu: 9000
                use_interfaces:
                - bond0.<MGMT_NETWORK_VLAN_ID>

##### br-mgmt on network-nodes
        
On network nodes, it's an OVS internal ports of` br-floating` with tag and ip addresses 

    #!yaml
    # vi classes/cluster/xxx/openstack/gateway.yml
    parameters:
      linux:
        network:
          bridge: openvswitch
          interface:
            ...
            br-mgmt:
              enabled: true
              type: ovs_port
              bridge: br-floating
              proto: static
              ovs_options: tag=<MGMT_NETWORK_VLAN_ID>
              address: ${_param:single_address}
              netmask: <MGMT_NETWORK_NETMASK>

### Putting all this together !!!

At this stage you may be a bit lost, my explanation is a bit fragmented. But there is an easy way to see all the piece together. You can look at an non DVR/VxLAN model example, look at the [gateway.yml](https://github.com/TimurNurlygayanov/mk24qa-salt-models/blob/vxlan_nondvr/classes/cluster/mk24_qa_baremetal_vlan_dvr/openstack/gateway.yml) and [compute.yml](https://github.com/TimurNurlygayanov/mk24qa-salt-models/blob/vxlan_nondvr/classes/cluster/mk24_qa_baremetal_vlan_dvr/openstack/compute.yml) files. I hope you see the big picture by now.

### Changing hostname

If you have a specific nomenclature to name your nodes (vms or bare metal), you can update your model. For example to change network nodes hostname

    #!yaml
    # vi classes/cluster/xxx/init.yml
    openstack_gateway_node01_hostname: fr-pa-gtw01
    openstack_gateway_node02_hostname: fr-pa-gtw02
    openstack_gateway_node03_hostname: fr-pa-gtw03

It will also be reflected in the node salt-minion ID. Let me explain how, our [salt-formula-salt](https://github.com/salt-formulas/salt-formula-salt/) configure salt minion on our nodes, and use this [template](https://github.com/salt-formulas/salt-formula-salt/blob/master/salt/files/minion.conf) as a baseline to configure it. This template set `{{ system.name }}.{{ system.domain }}` as the ID. If you look more closely in the template, you'll find this line

    {%- from "linux/map.jinja" import system with context %}

Now look at [linux/map.jinja](https://github.com/salt-formulas/salt-formula-linux/blob/master/linux/map.jinja), you'll find this

    {% set system = salt['grains.filter_by']({
        ...
    }, grain='os_family', merge=salt['pillar.get']('linux:system')) %}

Which merge our `linux:system` Pillar data into system which is then imported in our template. So `{{ system.name }}` in our template, refer to Pillar data `linux:system:name`. Which in turn is defined in the generated Reclass node configuration when [reclass.storage](https://github.com/salt-formulas/salt-formula-reclass/tree/master/reclass/storage) state is run and create the node based on this [template](https://github.com/salt-formulas/salt-formula-reclass/blob/master/reclass/files/node.yml) and gateway cluster node declaration in `classes/system/reclass/system/storage/openstack_gateway_cluster.yml` which associate `openstack_gateway_node0x_hostname` to `reclass:storage:node:name`.

Here is an example of a generated gateway node YAML where you'll see that `linux:system:name` Pillar data is set to our hostname as expected. This is exactly as we said earlier what gets injected in our salt-minion template, and used as the node ID.

    #!yaml
    # vi /srv/salt/reclass/nodes/_generated/fr-pa-gtw01.yet.org.yml
    classes:
      - cluster.int.openstack.gateway
    parameters:
      _param:
        linux_system_codename: trusty
        salt_master_host: 10.0.0.120
        single_address: 192.168.1.120
        tenant_address: 192.168.12.120
      linux:
        system:
          name: fr-pa-gtw01
          domain: yet.org
          cluster: default
          environment: prd

Ok, I've lost you :( two options from there, you can forget all of this and just trust me, or read my article on [Salt Formula](/2016/09/salt-formulas/) to understand how `map.jinja` works and then the next article on [Using Salt with Reclass](/2016/10/reclass/) to put everything together.

### Neutron CLI - cheatsheet

#### Neutron agent

    # neutron agent-list
    # neutron agent-show

Restarting agents

    gw# service neutron-l3-agent restart
    cmp# service neutron-dhcp-agent restart
    cmp# service neutron-openvswitch-agent restart

#### Neutron router

Get a list of virtual routers

    # neutron router-list

You'll get router ID, name external_gateway_info (network_id/snat?/subnet_id/ip), is it distributed and highly available ?

If you need more information about a router, like in which availability zone it is located, tenant_id, is it up ?

    # neutron router-show mirantis-router

List all ports of a router

    # neutron router-port-list mirantis-router

For HA router you can get the list of active/passive neutron gateways

    # neutron l3-agent-list-hosting-router mirantis-router

List routers on a agent

    # neutron router-list-on-l3-agent

Add/Remove HA from an existing router

    # neutron router-update mirantis-router-nonha --admin_state_up=False
    # neutron router-update mirantis-router-nonha --ha=<False|True>
    # neutron router-update mirantis-router-nonha --admin_state_up=True

#### Neutron DHCP

    # neutron net-list-on-dhcp-agent

### L3 HA neutron routers

What you have to know about Neutron router high availability using VRRP/Keepalived

* Traffic will always go thru a single l3-agent
* It's incompatible with `DVR`
* Doesn't address l3-agent failure, rely on ha network to determine failure.
* The failover process only retains the state of network connections for instances with a floating IP address.

While we talk about virtual routers using VRRP for HA, keep in mind that a single ha network will be created per tenant. Each HA router will be assigned a 8 bit virtual router ID (VRID), so a maximum of 255 HA routers can be created per tenant. This VRID will also be used to assign a virtual IP  to each router in the 169.254.0.0/24 CIDR by default, if a router have a VRID of 4, it wil get 169.254.0.4, only the master will have it but it's not going to be used as a gateway by anyone but at least it will be unique.

On top of that each instance of the VRRP router, running on an l3 agent, will be listening on the ha tenant network. It will get assigned an IP address within the l3_ha_net_cidr, 169.254.192.0/18 by default.

All router gets assigned the same VRRP priority (50), so when an election occurs the one with the lowest IP will always win and become master.

#### reverting to automatic l3 agent failover

If you don't like any of these limitations, you can always revert back to non L3 HA routers by default, by setting up

    #!yaml
    # vi classes/cluster/int/openstack/init.yml
    neutron_l3_ha: False

Then by changing the following hardcoded line in your the template configuration file of the neutron salt formula, you'll then get the original mechanism instead, lets hope a pull request will be merged to avoid this hack in the futur.
    
    #!yaml
    cfg01# vi /srv/salt/env/prd/neutron/files/mitaka/neutron-server.conf.Debian
    allow_automatic_l3agent_failover = true

Lastly, even when you set the `neutron_l3_ha` to False, you'll still be able to create L3 HA routers from the CLI

    # neutron router-create my-ha-router --ha=true

#### Forcing a failover

Find the active gateways and set its ha interface down

    ctl# neutron l3-agent-list-hosting-router mirantis-router
    active-gw# ip netns exec qrouter-4c8c40dc-fd02-443a-a2c9-29afd8592b61 ifconfig ha-3e051b01-80 down

You can also enter the namespace like this

    # ip netns exec qrouter-4c8c40dc-fd02-443a-a2c9-29afd8592b61 /bin/bash

All subsequent commands will be ran in the corresponding namespace

    # ifconfig ha-3e051b01-80 down

You can observe failover events in a network node in

    /var/lib/neutron/ha_confs/<ROUTER_ID>/neutron-keepalived-state-change.log

### Conclusion

[Linux](http://github.com/salt-formulas/salt-formula-linux) and [neutron](http://github.com/salt-formulas/salt-formula-neutron) salt formulas, combined with MCP Modelling allows to deploy a large spectre of use cases without a great deal of effort which I find pretty nice. Open vSwitch networking is complicated enough, Mirantis Cloud Platform abstract away the complexity of OVS Networking by allowing you to deploy well tested, reference architectures with few lines of yaml, to avoid to spend too much time builbing out your own stuff or troubleshooting corner cases.

### Links
* [salt-formula-linux](https://github.com/salt-formulas/salt-formula-linux)
* [salt-formula-neutron](https://github.com/salt-formulas/salt-formula-neutron)
* [OpenStack Networking troubleshooting](http://docs.openstack.org/ops-guide/ops-network-troubleshooting.html)
* [HA using VRRP with Open vSwitch](http://docs.openstack.org/kilo/networking-guide/scenario_l3ha_ovs.html)
