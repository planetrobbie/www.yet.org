---
title: "Automating OpenStack with Private Chef at DreamHost"
created_at: 2012-11-08 19:01:00 +0100
kind: article
published: true
tags: ['devops', 'openstack', 'chef', 'automation', 'webinar']
---

Notes following up a webinar with *Matt Ray* from *[Opscode](http://www.opscode.com/)* and *Carl Perry*, Cloud Architect at [Dreamhost](http://www.dreamhost.com/).

<!-- more -->

### Presenters
* Matt Ray - Senior Technical Evangelist @ [Opscode](http://www.opscode.com)
* Carl Perry - Cloud Architect @ [DreamHost](http://www.dreamhost.com)
* 42 slides should be available on the [mailing list](http://groups.google.com/group/opscode-chef-openstack) Chef for OpenStack soon

### OpenStack Mission Statement
* Apache 2 license
* provides all the feature to run Private or Public Cloud regardless of size
* massively scalable
* compatibility with Amazon or other clouds
* HP CLoud, RackSpace are using it but let's talk about DreamHost today

### Why OpenStack
* Control: Open source, no vendor lock in. (Apache 2 license)
* Flexibility: Modular design integrates legacy and 3rd party technology
* Emerging Industry Standard: more then 180 technology leaders back it and major cloud built on it 
* Proven
* Compatible and Connected: Enables portability

### OpenStack Components

#### Nova
* VMs runs on top of
	* KVM
	* Xen
	* LHC
	* Hyper-V
	* and more
	
#### Cinder (used to be called nova-volume)
* Block storage for the VM
* similar to EBS from Amazon
* drivers for Nexenta, NetApp, ...

#### Quantum
* new project released with Folsom
* SDN technology
* sits on the network layer handles management and configuration of the VM networking
* DreamHost use Nicira

#### Glance
* Image Registry
* Source of the VMs that runs under Nova

#### Keystone
* Common authentication layer
* check for crendentials and provides token that are passed around
* could be token-based, AWS, LDAP or other forms

#### Swift
* Original Rackspace Cloud Files object store that came from RackSpace
* DreamHost use [Ceph](http://www.inktank.com) instead

#### Horizon
* self-service role-based web interface for users and administrators
* provision cloud based resources

### Ceph
* Saige Weil PhD project now spined off to Inktank
* Next generation distributed storage 
* runs on commodity hardware
* Raw Block, RESTful object storage service, Filesystem (in pre-release)

#### Ceph Components
* Ceph Monitor: Maintain map of current cluster health
* Ceph OSD: Manages a single physical storage volume (1 OSD per hard drive but 1 OSD per RAID volume could be done too)
	* Everything is broken in 4 MB objects
* Ceph RESTful RADOS Gateway: Provides SWIFT or S3 compatible RESTful Object Storage API
* Ceph Metadata Server: Provides distributed POSIX layer for filesystem (only needed for POSIX Filesystem service)
* Components all run in user space (no kernel modifications required)

#### DreamObjects - DreamHost Ceph offering
* Nics will be upgraded to 10G to avoid Nic bonding to gain management simplicity
* 3 replicas per object at DreamObjects
* it is all the time consistent !!! Each write is acknowledged.

![][DreamObjects]  

### DreamCompute
* KVM used
* Ceph for all the storage
* frontend storage network isn't exposed to customers

![][DreamCompute]

#### Chef manages the overall infrastructure
* Automation platform
* to define and build infrastructure
* a lot of complexity of applications configuration are abstracted
* massive scalability

#### how it works
* Infrastructure is code
* Everything is tracked in version control
* Chef works with node (abstraction of a server)
* We tell the end node what it should do, the machine will configure itself
* It reduce management complexity, the centralized server doesn't do much
* Anything an admin do as a Resource to back it, it's an abstraction. It's not necessary to know all the details to deploy components
* Chef gives you a **declarative interface** to Resources

#### Recipes and Cookbooks
* Recipes are a list of Resource to use
* Cookbooks contain recipes, templates, files, custom resources, etc
* Code re-use and modularity
* More than 700 already on <http://community.opscode.com>

![][Recipes]              

#### Ruby!
* Really good 3rd generation [Programming language](http://www.ruby-lang.com)
* Instead of learning a dedicated language let's use an existing have

#### Search
* Search for nodes with Roles
* Find Configuration Data
	* IP addresses
	* Hostname
	
![][Search]  

![][SearchTemplate]  

* OpenStack requires searching over thousands of machines, things come and go so search **dynamically** change the behaviour of the infrastructure
* Chef can help in the following ways 

![][HowChefHelp]

* Windows is also supported, so Hyper-V instances will be manageable too in an OpenStack cloud
* Continuous deployment becomes possible
* Disaster Recovery becomes easy


#### Chef Community
* Apache License v2 (same as OpenStack)
* You can embed the code to your application
* 170+ Corporate contributors
	* DreamHost, Dell, HP, Rackspace, VMware, SUSE, 37signals, Kickstarter, Simple and many more
* Plugin for every Cloud

#### Opscode
* The Leader in cloud infrastructure automation
* Founded by one of the original architect of Amazon EC2
* Fully open source, hosted version free for up to 5 nodes

#### OpenStack and Chef
* A lot of organisation are using Chef for OpenStack
* to reduce the fragmentation let's release a centrally managed version of it
* Cookbooks for each of major components
* [Documentation](http://15.185.230.54/)  
* [Knife OpenStack](https://rubygems.org/gems/knife-openstack)

#### Sponsors
* Intel
* Rackspace (drives Alamo)
* HP

#### Roadmap
* Essex is currently supported
* Folsom work in progress
* KVM and LXC
* MySQL, Postgres maybe later on
* Ubuntu
* RedHat SUSE on roadmap
* HA Configuration
* Quantum (Nicira, Open vSwitch) will be added to the Cookbooks soon
* Cinder

#### Chef at DreamHost
* DreamObjects compete with Rackspace Cloud Files and Amazon S3
* Chef is used for configuring all of DreamObjects
* Manual cluster deployment of 40 nodes took 4 days
* Chef automated cluster deployment now in just 2 hours
* Adding a new rack of OSD nodes ? rack, cable, install OS 1 day Chef add package to nodes in 45 minutes 
* <http://github.com/Dreamhost> should contain all of their source after lawyer approve it
* XFS is used at DreamHost
* **[Nephology](https://github.com/edolnx/nephology-server-perl)** for Bare Metal provisionning (internal DreamHost tool, should be open sourced soon)

#### DreamCompute
* Lot's of components to provide the compute service
* Nicira NVP is used to segregate customers
* All managed by Chef
* Folsom in deployment
	* Started from Essex Chef OpenStack cookbooks
	* Adapted and extended
	* Pushing changes back upstream with Matt Ray

#### Devstack
* Project devstack a set of installation script for setting up OpenStack on devt station
* DreamHost will pull from git and use git and chef for their build environment

#### Private Chef
* [Private Chef](http://www.opscode.com/private-chef/) used at DreamHost
* [Ruby](http://www.ruby-lang.com) on the client side no performance problem
* Open Source implementation does have limitation
* 10.000 of nodes in the next several months without issues on Private Chef
* Access Control is a huge improvement in Private Chef

### Q&A
* Cookbooks aren't verified by Opscode, runs at root, so you should read the cookbooks before running them
* Postgres support will be merged in time
* Ceph for Database or High IO application ? no good answer for that, it depend on how you built the infrastructure: SSD+10G Networking should be fine
* DreamObjects use Enterprise SAS Drive of 3TB each for all of their OSD, a lot of interest of building an SSD cluster for high performance
* Chef has a concept of an encrypted databag to store confidential information, protected by a key file
* Knife OpenStack could be used to create OpenStack instances put the Chef client in it to manage it from Chef
* Chef infrastructure: 4 x Chef Servers load balanced, 2 replicated DB in the backend
* Hosted Chef does have the same interface/experience as Private Chef but Trial Licenses available at sales@opscode.com
* HA for OpenStack Services: possible but not implemented at DreamHost (see bullet below)
* Running inside of VMware for now (cheating) for HA for OpenStack Management VMs
* CloudStack is well supported for API but no Cookbooks yet
* Largest known Ceph Infrastructure: DreamObject cluster 1.5 year in existence before launching the service
* DreamCompute is 3 times as large as DreamObject
* Ceph should'nt be used to replicate objects across high latency links, new feature will appear in following versions
* Chef client on switches running Linux (Arista, Cumulus) should be configured soon with Chef too
* Juju came well after Chef, Chef OpenStack cookbooks available for 2 years now. Juju only for Ubuntu, licensing doesn't allow easy sharing with other environment
* How to monitor OpenStack, RackSpace version has their monitor solution embedded
* Chef for OpenStack do not have monitoring built to the system
* Ceph handle checksum for bit rot, it will delete the object and pull out new replica
* 12 Disk per Node should evolve to 16 Disk but need to check if it will be ok with 10G Network connection
* Cloud Compute everything backed by Ceph no Ephemeral storage, better for end users. Terminate an instance won't destroy its content
* Dream Compute can move all of the VMs running to another node to perform maintenance on the node
* Switches used at DreamHost: Arista Networks and Cumulus Networks
* 3x Replication, Single Volume per Disk


### Chef for OpenStack Links
* [Documentation](http://15.185.230.54/)
* [Documentation repository](http://github.com/mattray/openstack-chef-docs) based on RST+Sphinx
* [OpenStack Chef Repository: Roles, environments and data bags](http://github.com/opscode/openstack-chef-repo)
* [Opscode Cookbooks](http://github.com/opscode-cookbooks): keystone, glance, nova, horizon, swift, quantum, cinder.
* [Rackspace Cloud Builder Cookbooks](https://github.com/rcbops/chef-cookbooks)
* [Knife OpenStack plugin](http://github.com/opscode/knife-openstack) 
* [Group](http://groups.google.com/group/opscode-chef-openstack)
* [IRC Channel](http://community.opscode.com/chat/openstack-chef) #openstack-chef on irc.freenode.net

[DreamCompute]: /images/posts/dreamcompute.png "Logical Diagram of DreamCompute" width=700px
[DreamObjects]: /images/posts//dreamobjects.png "Logical Diagram of DreamObjects" width=700px
[Recipes]: /images/posts/recipes.png "Chef Recipes" width=400px
[Search]: /images/posts/search.png "Search example" width=400px
[SearchTemplate]: /images/posts/search-template.png "Search Template example" width=700px
[HowChefHelp]: /images/posts/how-chef-help.png "How Chef can help ?" width=800px