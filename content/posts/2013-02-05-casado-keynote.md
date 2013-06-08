---
title: "vCNS"
created_at: 2013-02-05 10:00:00 +0100
kind: article
published: false
tags: ['training', 'nicira', 'network virtualisation']
---

# Martin Casado Introduction.

When we talk about virtualization, we are lying a little bit. It's very important to know what's this lie is. We have to work with 3 decades of madness. We have decoupled VM from the compute but we haven't decoupled them to the physical network. Look at the addressing, the default gateway, the subnet, ... it comes from the physical world. Resulting in :

* Slow provisionning
* limited placement
* Mobility is limited
* Hardware dependent
* Operationaly intensive


The basic concept of network virtualization is the same as the compute one, a thin layer of software that sits in between. Virtual network will look exactly the same for a VM. Ig you have this virtual network a lot of the previous problems will disapear. You can move a VM anywhere you want. The physical won't go away but we are agnostic. It's not about protocols: STT, VXLAN, at the end of the day it's about the virtual abstraction. We want to support any physical network.

A customer should only care about virtual networks. Networking guys are the masters of complexity, a lot of their value came from owning this complexity. A software function that does this won't be easy to bring to them. We have to be really carefull when we bring this dialog. I built a rocket ship, I went to Venus, let me show you how beautiful it is there.

<!-- more -->

What is the product we are building. vCNS and Nicira are different beats. The high level vision is simple, one product at the end of the day, Any Cloud:

* Multi CMS
* Mutl Hypervisor
* Multi Fabric

Our Vehicule of Change is the Virtual Network Abstraction :

* It is not protocols: protocol are mechanism, we will support any protocol if there is sufficient demand from the field (VXLAN, STT, BGP, EVPN, OSPF, ...). You must become adept at positioning vis a vis protocol X
* It is not SDN: SDN is a mechanism, in it's current form is so diluted as to be meaningless (SDN -> N)

### Competitive landscape:

#### Open Source

Two year horizon, we've got tremendous opportunity, anything at scale need something serious. Nicira is the only non open source bits. Dreamhost have Nicira which is the only non open source peace in their architecture. It will continue to be a problem. Understand the contribution we've done to the Open Source World: Open vSwitch, OpenStack Quantum, 

#### Proprietary Fabrics

1 year horizon, Architecture battle will be software against hardware. We've seen such battles, software wins. This war will get ugly.

#### Status quo

Now. People are really confortable the way they do things today.

### Why we will win

There are plenties of traps. Let's focus on the following

#### We have the Strategic High ground

We own more virtual ports then Cisco physical ports. If we can implement virtual networking there we win. We own: ESX, VCD, Open vSwitch, Quantum, ...

#### We will Amass the Elven, Dwarf and Undead Horde

Already have many partners in NetX. We already have an ecosystems of dozens partners delivering services on top of our virtual networking world.

#### We will win through software

Float like a butterfly, punch the competition in the face. We aren't tied to Asics. Software has a 5+ decade long history of eating hardware.

#### We are Wayyyy Ahead

First product to market, most customer traction, most advanced technology.

### Q&A

### How do customers will deal with as much flexibility



![][image-01]































#### Major components :

* Automation : [*Opscode*](http://www.opscode.com/)
* Cloud Management system : [*OpenStack*](http://www.openstack.org/)
* Network Virtualization : [*Nicira*](http://nicira.com/)

There is currently a lot of confusion in the SDN space. *Nicira* creates a complete network construct in software that support both physical and virtual workloads completly decoupled.

* Non Disruptive deployment
* Decoupled from topology
* Hardware independence
* Backwards compatibility

*SDN* is not *Network Virtualization*, SDN is looking at the different table space within the networking devices while *Network Virtualization* decouple virtual networking from physical one.

Distributed Forwarding State is already well handled but the issues comes from manual configuration State like VLANs, ACLs, ...

Network Virtualization creates an abstraction to leave the physical network to do what he does best, forwarding packets. Nicira does what VMware have done to the compute.

To give you an example, *Rackspace* does currently have 65.000 logical ports in production.

### Chef - Automation

*Stathy Toulomis*, Solutions Architect at *Opscode* presented an high level overview of *Chef*.

#### Operation complexity, why Chef becomes more pervasive

![][nicira-chef-02]

Chef is an automation platform for developers & systems engineers to continuously define, build and manage infrastructures. *Chef* use ***Recipes*** and ***Cookbooks*** that describe infrastructure as Code.

*Chef* enables people to easily build & manage complex & dynamic applications at massive scale. The Goal is to reconstruct the business from code and backups.

#### Infrastructure as code

* A configuration management system (DSL)
* A library for configuration management
* A community, contributing to library and expertise
* A systems integration platform (API)

Recipes are a collection of resources like Networking, Files, Directories, Symlinks, Mounts, ...

Cookbooks contains recipes, logical grouping, hundreds already available on the [OpsCode Community](http:community.opscode.com).

As you can see in the following line, by searching you can easily and dynamically configure a load balancer pool.

	pool_members = search('node','role:webserver')

### Nicira OpenStack Cloud demo

Nicira wrote a custom interface that talks to the *OpenStack* API. It enable them to deploy many VM instances from a self-service portal. Users can be part of multiple projects

#### Deploy a server

Within a few seconds you can get a running virtual server.

![][nicira-chef-03a]

#### Volumes

OpenStack provides iSCSI volume as a service.

![][nicira-chef-03b]

#### Network Tabs

Nicira enable you to create an unlimited number of virtual networks.

![nicira-chef-04a]

It couldn't be easier to create a new network

![][nicira-chef-04b]

When you deploy a new virtual machine, you can connect it to this newly created network. You never have to call anybody in the networking team, it's all done automatically thru the self service portal.

![][nicira-chef-04c]

#### Security Profile

You can configure ACLs to control traffic to your VMs

![][nicira-chef-05a]

You can also apply a security profile to a Network without picking up the phone to call security team, it's all on demand.

![][nicira-chef-05b]

#### Labs

*Nicira* Cloud used for training and onboarding new employees by packaging an overall environment containing multiple VMs to enable employees to deploy a training lab in a single click. 

![][nicira-chef-06a]

As you can see below, The lab is now in a privisionning state

![][nicira-chef-06b]

#### Chef

Used to build up the infrastructure, bootstrapping a new node could now be done without user interaction, without any human errors. The monitoring of the platform is possible with [Ganglia](http://ganglia.sourceforge.net).

![][nicira-chef-07]

### Q&A

#### Which hypervisor is currenlty used at *Nicira*
*KVM* used as the underline hypervisor but VMware will be supported soon.

#### What relationship exists between OpenStack, *Nicira* and *OpsCode* ?
There is no tight integration between *OpsCode*, *Nicira*, *OpenStack* or *CloudStack*. But integration is possible via *Quantum* in the OpenStack world.

#### Which cloud management platform are supported ?
*Nicira* NVP is independant from the cloud management platform. *Nicira* expose an API that can be used by any cloud management platform.

#### How a newly deployed VM knows which recipe to apply.
Nicira uses Chef to build the physical infrastructure, right now the VMs themselves aren't using Chef yet.

#### What's required in the physical networking world for Nicira to work ?
IP connectivity only.

#### How does Chef differs from other tools like attrium Orchestrator, Palets
Chef has an intimate understanding of the platform that it needs to configure, it's not a process modeling tool.

#### Which virtual switch are supported ?
Cisco 1000V isn't supported, but VMware VDS and OpenSwitch are supported.

### Contacts

To get more information about *Nicira* or *OpsCode* :

* nicira-info@vmware.com
* sales@opscode.com

[nicira-chef-01]: /images/posts/nicira-chef-01.png "nicira chef" width=700px
[nicira-chef-02]: /images/posts/nicira-chef-02.png "nicira chef" width=700px
[nicira-chef-03a]: /images/posts/nicira-chef-03a.png "nicira chef" width=700px
[nicira-chef-03b]: /images/posts/nicira-chef-03b.png "nicira chef" width=700px
[nicira-chef-04a]: /images/posts/nicira-chef-04a.png "nicira chef" width=700px
[nicira-chef-04b]: /images/posts/nicira-chef-04b.png "nicira chef"
[nicira-chef-04c]: /images/posts/nicira-chef-04c.png "nicira chef" width=700px
[nicira-chef-05a]: /images/posts/nicira-chef-05a.png "nicira chef" width=700px
[nicira-chef-05b]: /images/posts/nicira-chef-05b.png "nicira chef" width=700px
[nicira-chef-06a]: /images/posts/nicira-chef-06a.png "nicira chef" width=700px
[nicira-chef-06b]: /images/posts/nicira-chef-06b.png "nicira chef" width=700px
[nicira-chef-07]: /images/posts/nicira-chef-07.png "nicira chef" width=700px