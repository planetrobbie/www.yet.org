---
title: "Building out Storage as a Service with OpenStack Cloud"
created_at: 2012-12-13 18:07:00 +0100
kind: article
published: true
tags: ['webinar', 'openstack', 'storage']
---

*Greg Elkinbard* built on demand IaaS and PaaS layer at *Mirantis* customer, he has 20 years of experience and is Senior Technical Director at *Mirantis*. Today he is comparing storage technologies in the context of delivering a storage as a service offering. He was assisted by *David Fishman* in charge of Marketing at *Mirantis*. Let's dive-in.

<!-- more -->

![][mirantis]

### OpenStack : quick background

It is a leading Open Source IaaS solution with a great deal of adoption, 6000 members of the foundation in 87 countries as of today, it's the widest available Open Source Cloud solution, it competes with *Amazon EC2*, *ATT Cloud* and *VMware* or *Citrix* on the software front.

#### What is OpenStack ?

An Open Source community focused on building a software platform for private and private cloud, core projects includes: *Nova, Swift, Glance, Keystone, Horizon, Quantum and Cinder* all released with an [*Apache 2.0 License*](http://www.apache.org/licenses/LICENSE-2.0.html).

#### OpenStack Capabilities

Key problems that OpenStack solves:

* VMs on demand
	* Provisoning
	* Snapshotting
* Multi-tenancy
	* quotas for different users
	* user can be associated with multiple tenants
* Volumes
* Object storage for VM images and arbitrary files (like Amazon S3)

### Cloud Storage - understanding capabilities

Three storage tiers to fill different storage needs

#### Ephemeral Storage

* tied to the lifecycle of individual VM
* Guest boot volume
* typically all that is needed for small guests
* types:
	* local storage:
		* low latency
		* low cost
		* longer live migration
		* no guest H/A
	* shared storage (NAS or SAN)
		* higher cost
		* more features
		* thin provisionning
		* faster migration
		* standby H/A
		* not managed by OpenStack

####  Ephemeral storage - New in Folsom

* Optional Secondary Drive
	* Unformatted volume
	* removed when VM is deleted
* Boot from Volume (Cinder)
	* Experimental
	* Manual steps required
	* Better support should be provided with Grizzly (Q2 2013)
	* Persistent or ephemeral lifecycle
	* Shared storage managed by OpenStack

![][staas-01]

#### Persistent Storage

Cinder provides Block Storage on demand by creating on the fly iSCSI

* Block Storage Service
	* Create iSCSI volumes on demand
	* Expandable: plug-in storage drivers
	* Snapshots and basic security ACLs
* Basic Service: Linux box with LVM and iSCSI target package
* Advanced Services to complement Cinder: Nexenta, NetApp, Ceph
	* Thin provisioning
	* Native Snapshot support
	* Builtin H/A

Grizzly innovations coming soon enough :

* Metering
* Quotas
* Cloning
* Backup
* Volume Scheduling (QoS)

#### Architecting persistent storage

![][staas-02]

Volumes are presented as an iSCSI target, Nova then executes utilities to mount it.

#### OpenStack Object Storage (project "Swift")

* RESTful API
* Simple but Scalable Service (6+ PB at currenlty in production at RackSpace)
* limited Geo replication
* Architecture
	* DHT with anti-entropy services
	* proxy Servers
	* Object Servers
* Swift matches most of the S3 functionnality and has S3 API shim as well as native API
* By comparison, AWS EC2's "S3" service also offers
	* Support for region
	* Large Object handling
	* Payment transfer bucket API, to transfer payment to other tiers.

### OpenStack Object Storage Hardware

* Basic Hardware: Linux box with XFS
* Lowest possible cost per Gigabytes, you can get a generic community server with a great disk density possible like 8 to 12 drives.
* For Swift, proxy servers are typically built with bigger hardware
	* Account/Containers need higher IOPS
	* get a better io subsystem on proxies
	* co-locate account and container rings with proxies
* Alternative Object Stores
	* Nexenta enhanced Swift
	* Ceph RadosGW
	* Gluster UFO (Unified File and Object)

### Storage platforms: Cloud vs Legacy

* NAS and Scale Out NAS, around forever
* SAN (EMC, Brocade, ...)
* Shared filesystems (on top of a SAN or network independant entity)
* Object Storage (newest storage tier, Non-POSIX compliant)

#### NAS

* Large NAS arrays or tightly coupled clusters like:
	* [Isilon](http://en.wikipedia.org/wiki/EMC_Isilon) (acquired by *EMC* in 2010)
	* [Ibrix](http://en.wikipedia.org/wiki/IBRIX_Fusion) (acquired by *HP* in 2009 and integrated to X9000 series storage sytems)
	* [BlueArc](http://en.wikipedia.org/wiki/BlueArc) (acquired by *Hitachi Data Sytems* in 2011)
	* [SONAS](http://www-03.ibm.com/systems/storage/network/sonas/) from *IBM*
	* [OnTap GX](http://www.tech.proact.co.uk/netapp/netapp_data_ontap_gx.htm) from *NetApp*, built by merging OnTap with *Spinnaker* acquired technology, released in 2006.
* They all present a global namespace to the entire enterprise.
* Relatively expensive and centralized
* Cloud models takes a different approach
	* tenants do not need a lot of storage
	* no global namespace across tenants
	* Instead of large storage arrays, offer many smaller ones (give each tenant its own pool of storage)

#### SAN

* Dedicated Storage network
	* FC or iSCSI
	* Tighly coupled collection storage switches, storage arrays and storage management software
* Centralized and relatively high-cost
* Cloud model is different
	* Guest do not need a lot of individual storage
	* Instead of large arrays, give each guest its own storage (across a pool of smaller arrays)

#### Shared Filesystems

* Often a complement to SAN & replacement for NAS
* Legacy: Veritas, CXFS, GPFS
	* Limited scalability
	* Relatively high cost
* Open Source alternative
	* **Lustre**, **Gluster** and **Ceph**
	* Designed to large scale
	* Much lower costs
	* Higher aggregate performance

#### Object Storage

* Non-Posix compliant
* HTTP based APIs (e.g. REST)
* Relaxed consistency
* [EMC Atmos](http://www.emc.com/storage/atmos/atmos.htm) was one of the early systems
	* Now a lot of vendors provide a REST interface to legacy storage arrays
* OpenStack Swift
	* Higher scalability
	* Lower cost
	* Simplified customization

### Open Source Options - Key Storage Technologies

* ***Gluster***: Distributed network file system, shared nothing, focus on robustness
* ***Lustre***: Parallel large scale distributed file system, focus on IO throughput great for HPC
* ***Ceph***: built on top of RADOS
* ***Swift***: is the default Open Stack Cloud object store

#### Gluster

* Distributed Metadata Management.
* Stackable translators provide different access methods.
	* native
	* NFS
	* Object
	* HDFS
* Good midsize/medium performance, replication based data protection.
* OpenStack integration into ephemeral storage tier and as a Swift replacement.
* Good as guest shared file system for PaaS deployements, because of the ease of deployment.

#### Lustre

* One of the original distributed based focused on HPC market
* Metadata operation slow and limited scalability but huge read and write performance
* **Network equivalent of RAID-0**, great speed but not data protection
* Metadata performance is an issue
* Currently no OpenStack integration but still really usefull project when you need rapid rate
* could be great for video streaming.

#### Ceph

* Distributed object store
* Different access methods
	* Distributed FS
	* Object Store
	* API
	* Block Store
* Good perf, scalability, reliability, sophisticated failure domain isolation
* Well integrated with OpenStack
	* Glance Image Store Connector
	* Cinder connector
		* Persistent storage tier
		* Ephemeral storage tier, using boot from volume
	* Full replacement for Swift

#### Swift

* Distributed object storage
* DHT based, lightweight distributed meta data
* Rest or Soap API only
* Designed for HA and Reliability
* Mid level IO performance
* Default object storage for OpenStack
* Very very high scalability
* Default object storage for OpenStack

Comparison of storage technologies

![][staas-03]

As you can see above Ceph is the most flexible solution but still require some improvement before being qualified as production ready on the Ceph FS front. It is for Block and Object storage already.

### Storage as a Service - Opportunities and Architecture for OpenStack Cloud

Multi-tenant service which

1. Presents storage via a well-defined set of remotly accessible APIs
2. Abstract the actual storage implementation
3. Can be a foundation for more specialized functions: DR, backup, document sharing, etc.

#### Using StaaS

* Access methods
	* Block
	* File
	* Object
* OpenStack is a good platform for StaaS
	* Powerful set of components
	* Enhancements within easy reach

#### Object Services

This is what Swift was built to do

![][staas-04]

#### Access Methods: File Services

* Cloud Drive
* Multi tenant NAS

#### Use Case: using Swift as a cloud drive

Swift: backend store

* Commercial or Open Source front end clients
	* Commercial: [Gladinet](https://www.gladinet.com) (most advanced), [Cloudberry](http://www.cloudberrylab.com/), [ExpanDrive](http://www.expandrive.com/), [Webdrive](http://www.southrivertech.com/products/webdrive/index.html?masthead)
	* Open: [Cyberduck](http://cyberduck.ch/) (leading one for Mac & Windows), [Sparkleshare](http://sparkleshare.org/), [Syncany](http://www.syncany.org/)
* Removable drive or Windows Explorer like UI
* Use cases
	Backup to the cloud
	* share pictures, docs, ...

#### Use case: Multi-tenant NAS

* Physical hosts or virtual guests
* OpenStack can be extended to manage NAS storage pools, creates or partitions storage on demand
	* Virtual Storage array
		* Quantum creates network segregation
		* Nova compute provides a pool for Virtual NAS heads
		* Local drives or Cinder provide back end storage
	* Physical storage array
		* Quantum creates network
		* Cinder partitions and manages physical storage arrays
		* Secure separation requires internal virtualization support in storage array, as in NetApp Virtual Filer

#### Multi tenant iSCSI SAN

Cinder already act as a SAN for the virtual guest for VMs but could be expanded to bare metal nodes

* Quantum can be used to partition the network
* Use OpenStack Cinder to provision the storage and set ACLs

#### Key Takeways

* OpenStack and its 3 storage tiers
	* Ephemeral
	* Persistent
	* Object Stores
* Open Source solution solve key storage needs at lower cost
* Storage as a service can be implemented with OpenStack

### Q&A

#### what's a Virtual Storage appliance

It is a way to present storage from a virtualized host which is using the underlying storage as a repository for data but could present it using different kind of mechanism like CIFS, NFS or iSCSI.

#### Comparison with Symmetrix

Consider if you do need low  latency or any significant SLA, if you do not you can move to a cheaper option like StaaS.

#### Pros and Cons about adding NAS as a service to Cinder

*Mirantis* see a great deal of demand for this so they support both block and NAS based storage. It may not happen in Grizlly, there is still a lot of community debate, it's maybe better to provide this as a separate implementation.

#### Physical platforms required for each technolgy: Ceph, Gluster, ?

You can implement all of them on the cheap hardware box with some optimization in some cases. Ceph support a separate logging tier which could benefit from SSD, Gluster expect highest network capabilities. Luster can utilize the largest hardware specs, no performance bottlenecks in read/write IO path.

#### Should we think of Cinder supporting both ephemeral and persistent storage ?

Depends on the policy and application requirements.

#### Geo replication ?

Container based replication is around for quite around, by default Swift comes with async replication, but SLA is significantly less then what you'll get from block storage frame.

#### Is it possible to have user quotas in Swift

It seems possible, it is going to be integrated with [Ceilometer](http://fr.wikipedia.org/wiki/EMC_Symmetrix) soon

#### Swift or Ceph ?

Ceph adoption is a question for *Inktank*. It does have a growing adoption but it is not monitored by *Mirantis*. Rackspace uses Swift with more then 6 PB+ of storage. They solve kind of different problems. Ceph isn't the store for multi Petabytes system, most deployment are smaller, but high performance and great placement control, and fault tolerance. In Swift you can only deal with Zones.

#### Shared ephemeral storage for instances ?

Ceph FS isn't yet ready for production, Luster doesn't have a connector for OpenStack. NFS could be used, with many many different frames. You don't have to have a single cluster. You can use both Ceph, NFS and Gluster. I would try Ceph and Gluster they have the advantage of coming with built in fault tolerance. NFS isn't a default feature but Enterprise NFS makers could sell it to you.

### Links

* Mirantis corporate [web site](http://www.mirantis.com/)
* [Slides](http://bit.ly/mirantis-StaaS) of this presentation.

[mirantis]: /images/icons/mirantis.png
[staas-01]: /images/posts/staas-01.png "Architecting Ephemeral Storage"
[staas-02]: /images/posts/staas-02.png "Architecting Persistent Storage"
[staas-03]: /images/posts/staas-03.png "staas 03"
[staas-04]: /images/posts/staas-04.png "staas 04"