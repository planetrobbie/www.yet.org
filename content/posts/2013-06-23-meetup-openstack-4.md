---
title: "Meetup #4"
created_at: 2013-06-24 19:05:00 +0100
kind: article
published: false
tags: ['conference', 'openstack']
---

Fourth french OpenStack meetup in Paris with a fully booked amphitheater, amazing growth of the french community.

First meetup happened June 10, 2013 with 18 participants.

### OpenStack in production envt / Behind the scene

Presenters: Anne Sébastien Han (sebastien@enovance.com) and Razique Mahroua (razique.mahroua@enovance.com) both Cloud engineers and OpenStack contributors.

#### Upgrades

How to upgrade OpenStack from Cactus to Diablo to Essex to Folsom. Networking and User management changed a lot from the early version to the recent ones, it is challenging to upgrade. Keep in mind to keep a devt environment to check everything before changing anything on your production environment. There is always something that you cannot anticipate. We've migrated around 60 instances.

But right now and since Folsom it's much simpler but still not fully automated.

OpenStack provides two releases per year: 2013.1 et 2013.1.x, bugs are referenced at

	https://bugs.launchpad.net/<project-openstack>

You can get support from Mailing lists and IRC.

It's a good idea to communicate to the community on Launchpad if you find any bug, you just need an account on Launchpad. You can also contribute to define new Blueprints which will be implemented in following release of OpenStack.

If you have a modification to do, push it upstream or it could be overwritten when you'll upgrade. It's better then local patching.

#### Maintenance

To deactivate a compute node from taking new workloads

	sudo nova-manage service disable --host=<host> --service=<service>

On Xen you can do more and migrate running workloads.

	nova host-update <host> --maintenance enable

Or you can update the DB about where the instance is running, deactivate the instance and hard reboot your instance to start it over in the other host.

#### Monitoring

Sébastien Han explained he built a system based on OpenNMS and Dynamic DNS provisonning to monitor automatically new instances.

#### Tips & Best practices

Must have tools are:

* Supernova - multi environment management, if you manage multiple clouds.
* MySQL client - sometimes you'll need to check the DB content

To disallow termination of a specific VM:

	UPDATE SET disable_terminate ='1' FROM instances WHERE uuid ='<uuid>';

Partitionning schema

	/dev/sda0 / ext4 (local)
	/dev/sda1 /root ext4 (local)
	/dev/sda2 /home ext4 (local, nodev, nosuid)
	/dev/sda3 /usr ext4 (local, nodev)
	/dev/sda4 /tmp ext4 (local, nodev)
	/dev/sda5 /var ext4 (local, nodev, nosuid)

When you snapshot it goes to /var/lib/nova, so you need a really big /var

Don't forget to backup the database content. You could have 1 millions entries in Keystone DB, so you could use memcached if you don't need tracability or mysqldump regularly.

Grizzly uses PKI instead of UUID, it's possible to revoke them, it uses less network bandwidth. You need to index the token table.

### Ceph

Presenter: Loïc Dachary from Cloudwatt

Ceph is an Open Source storage system which use a pool of servers to store data. Ceph manipulate objects by distributing them, we do simple operation on them, it's quite simpler then POSIX. We only do GET / PUT / DELETE.

A Crush Map will be used by the client to compute where the object reside. It's not needed to ask anyone else. Each object will be stored multiple time, Ceph will auto repare objects that aren't redundant any more. When a disk dies the Crush Map will be published, client can get it to have an updated view of the world. Ceph constantly mutate objects, reparing the system all the time. Praxos algorithm is used to make sure all the monitor node have a consistent Crush Map.

LIBRADOS, is a low level library to manipulate Ceph to build up application that consume it.

Swift can be replaced by Ceph by using RADOSGW which is builton top of LIBRADOS.

RBD (Rados Block Device), could also be used for legacy stuff. /dev/rbd0 avec krbd (driver for physical machine). Or KVM could use a /dev/vdb with librdb (driver for virtualization, included in KVM) to present Ceph as disks. Block are now 4 Mb in size not any more 4k size like in the previous cases. OpenStack uses this library to consume Ceph Storage.

Write Performance is lowered a lot, it's not an asynchronous replication, it's synchronous so perf could be reduced multiple time. On the other side, read performance is increased because client could read from multiple source at the same time.

### OpenStack translation.

Presenter: François Bureau from Cloudwatt

Objective is to translate to 38 different languages. Translation uses Transifex, it's an online community platform for translation heavily integrated with Github.

You just need to go to Transifex.com in the OpenStack group and create an account. Your inscription need to be validated. If it take too much time you can ping on #openstack-fr IRC channel.

Today french translation reached 28%, IBM contributed a lot to Glance, Nova and Quantum for Folsom. Horizon and docs aren't done yet, it's a lot of work.

Priorities:

* Finish translation, Quantum still need 164 strings, Cinder 162, nova 328 strings...
* Attack Horizon translation.

### Neutron (Quantum)

Presenter: Emilien Macchi (eNovance) and Edouard Thuleau (Cloudwatt)

Quantum just got renamed to Neutron because of copyrights issues.

#### What's new in current release ?

Grizzly is the current release, it's a version that bring a lot of networking features.

##### Full support of namespaces
To decouple physical from virtual networks to allow overlapping IP. All OpenStack network feature could use namespaces like floating IPs.

##### LB as a Service
A lot of cloud providers offers such LBaaS features. The basic implementation of  this OpenStack feature uses HAproxy driver. It's not production ready, will be in the next one. Cisco or F5 could plug to Neutron to offer scalable load balancing. Current release HTTP and HTTPs, next one should support more protocols.

##### L3 scalability
There is two types of agent:

L3 Agent is doing the interconnect between internet and private world (NAT). It could be installed on multiple node. It will host virtual router. It's not yet possible to implement this agent in HA. Feature will be added in the next release.

##### DHCP scalability + HA

* DHCP Agent - this one scales and is HA.

##### Havana

* Modular L2 (ML2)
* Firewall as a Service - improve security of VMs will be based on OVS and IPtables.
* API QoS Support
* Bandwidth usage metering (differentiating WAN/LAN traffic)
* VPN as a Service - IPsec support in the first release, site-2-site, single site to multiple site. (HP could contribute a lot)
* New LBaaS drivers
* Multi-Host

##### L2 improvements (contributed by Cloudwatt, Orange and eNovance)

Today scalability isn't yet possible in the Open Source world. It's their objective to push back the limit of the Open Source solution.

* Modular L2 (ML2) - to allow different technologies to work in conjunction : GRE, Linux Bridge, VXLAN. To mix all of them.
* Tunneling partial mesh - objective it to improve Network Virtualisation, OVS and Linux Bridge aren't optimal yet.
* L2 population

##### Network metering (demo & code contributed by eNovance)

A label will be created like net2vm, it will be associated to a virtual network, it's possible to choose if you want to meter egress or ingress.

The demo used a devstack, a custom script to display the traffic and the following commands (approx, fonts were really small)

	quantum metering-label-create net2private
	quantum metering-label-rule-create <LABEL_ID> 10.0.0.0/24
	quantum metering-label-association-create <LABEL_ID> <ROUTER_ID>
	quantum metering-label-list
	quantum router list

#### Q&A

* Rabitmq could get the traffic to pipe it to Ceilomeiter.
* 3.8, 3.9, 3.10 Linux Kernel support multicast.
* Neutron will have a global view of all the Mac address and populate rules in the OVS.
* Havana will only monitor Level 3 traffic.

###  French User community

Presenter: Jonathan Le Lous from AlterWay (jonathan.lelous@gmail.com) and contributer at April, Erwan Gallen (main organiser erwan.gallen@cloudwatt.com)

4 workshops:

* Support structure - regroup french users to devt it locally
* Events - Meetup (also in Rhones Alpes) regular tech events. Datacenter Dynamics. OpenStack days (3 already). International summit (6000 personne but too early for Paris)
* Docs/communication

### Links

Slides will be available on the eNovance slideshare