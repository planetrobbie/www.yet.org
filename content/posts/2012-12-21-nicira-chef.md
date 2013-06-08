---
title: "Nicira + Opscode Chef: The Journey to an OpenStack Cloud"
created_at: 2012-12-21 18:32:00 +0100
kind: article
published: true
tags: ['webinar', 'chef', 'nicira', 'automation', 'devops', 'openstack']
---

*Nicira* and *OpsCode* partnered to build an OpenStack cloud at VMware. In this webinar we'll have the opportunity to get some insight about it. It allows their team to build location independant labs in 50 seconds, provisionned from a self service portal. Principal driver: cost, agility and speed.

<!-- more -->

![][nicira-chef-01]

Operational Efficiency and business velocity were going down due to the inherent complexity of their infrastructure but after the implementation of cloud automation tricks, it all inversed.

*Duffie* and *Tim* works at Nicira, *Duffie* is a Network and system administrator, worked at *Juniper*, majority of his time were responding to infrastructure issues and R&D requests. He was the one way to go for anything to happen. He then become a Cloud Architect, he is now a Hero to R&D, he believe it was his best carreer move. He now care about delivering a service to the R&D team.

*Tim* is the R&D build manager, with plenties of physical servers under his desk, after cloud he is now called "Server Hugger". He needed isolation, security, performance, reliability and availability. It's exactly what *Nicira NVP* offers. He actually was able to become a lover of the cloud. His build capability gone way up, much faster at doing build right now.

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