---
title: "OpenStack Cloud Architecture"
created_at: 2012-11-12 12:34:00 +0000
kind: article
published: true
tags: ['openstack']
---

Cheatsheet created from [Cybera](http://www.cybera.ca/tech-radar/lets-build-cloud-%E2%80%94-introduction?goback=%2Egde_3239106_member_182556535) blog.

<!-- more -->
            
Recommended Hardware
--------------------
* 2 x 10gb Nics
* 2 x CPU Cores
* 1 GB RAM
* 6 x 1 TB drives

[Partitionning of the first four drives]
|               Partition               |  Size  |    Type    |
|:-------------------------------------:|:------:|:----------:|
|              Partition 1              | 300 mb | Linux RAID |
|              Partition 2              | 20 gb  | Linux RAID |
|              Partition 3              | 900 gb | Linux RAID |  


[remaining two drives]  
|               Partition               |  Size  |    Type    |
|:-------------------------------------:|:------:|:----------:|
|              Partition 1              | 300 mb | Linux RAID |
|              Partition 2              | 20 gb  | Linux Swap |
|              Partition 3              | 900 gb | Linux RAID |  
  

Note: Similar partitions are grouped together to form RAID arrays. Grouping depends on node role (see below)

Recommended OS, Hypervisor
--------------------------
* Ubuntu 12.04 (de-facto OpenStack)
* KVM

Cloud Controller Node
---------------------
* Host all the non-compute OpenStack components:
    * nova-api
    * nova-cert
    * nova-consoleauth
    * nova-network
    * nova-objectstore
    * nova-scheduler
    * Keystone
    * Glance
    * Horizon
* They all use very little resources and can all comfortably fit on one server 

[RAID Configuration]
| RAID Device | RAID Type | Mount Point |               Partitions               |
|:-----------:|:---------:|:-----------:|:--------------------------------------:|
|   /dev/md0  |   RAID 1  |    /boot    | Disk 1 Partition 1, Disk 2 Partition 2 |
|   /dev/md1  |   RAID10  |    unused   |         D1P2, D2P2, D3P2, D4P2         |
|   /dev/md2  |   RAID10  |      /      |   D1P3, D2P3, D3P3, D4P3, D5P3, D6P3   |



Compute Node
------------
* Host nova-compute
* dedicated LVM partition named nova-volumes

[RAID Configuration]
| RAID Device | RAID Type |   Mount Point    |               Partitions               |
|:-----------:|:---------:|:----------------:|:--------------------------------------:|
|   /dev/md0  |   RAID 1  |      /boot       | Disk 1 Partition 1, Disk 2 Partition 2 |
|   /dev/md1  |   RAID10  |        /         |         D1P2, D2P2, D3P2, D4P2         |
|   /dev/md2  |   RAID10  | LVM Nova-volumes |   D1P3, D2P3, D3P3, D4P3, D5P3, D6P3   |

Network configuration example
-----------------------------

One 100 mb Nic dedicated to PXE, IPMI on only one switch, here is an example network configuration:
	
	auto lo
	iface lo inet loopback
	auto eth0
	iface eth0 inet static
	    address 192.168.255.1
	    netmask 255.255.255.0
	auto eth3
	iface eth3 inet manual
	    bond-master bond0
	auto eth2
	iface eth2 inet manual
	    bond-master bond0
	auto bond0
	iface bond0 inet manual
	    bond-slaves none
	    bond-mode 802.3ad
	    bond-miimon 100
	auto vlan422
	iface vlan422 inet static
	    address 10.0.0.2
	    netmask 255.255.255.0
	    gateway 10.0.0.1
	    dns-nameservers 8.8.8.8
	     dns-search private.edu.cybera.ca
	    vlan-raw-device bond0
	auto vlan423
	iface vlan423 inet static
	    address 192.168.1.1
	    netmask 255.255.255.0
	    vlan-raw-device bond0                   


Links
-----
* Puppet based deployment [example](https://github.com/jtopjian/)