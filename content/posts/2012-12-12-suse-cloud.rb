---
title: "Suse Cloud conference - part 1"
created_at: 2012-12-12 12:30:41 +0100
kind: article
published: true
tags: ['conference', 'openstack', 'linux']
---

*Julien Niedergang*, is a pre-sales SUSE engineer, curious about OpenStack, he presented SUSE strategy and solutions based on *Crowbar*, *Chef* and *OpenStack*.

<!-- more -->

### Look into the past

#### 1960-1980 Time sharing

Atomic bomb, end of lamps in computing. Bull in 1956 patents time sharing. Mainframes, computing is more and more necessary to achieve big projects. IBM 370 were essential for Apollo project. In 1980, big companies purchase their supercomputer and families get access to computing too.

#### 1990 Client Server
Internet expand to individual users. 

#### 2000 Grid and SaaS
In 2002, first VM used in production. First software provided as a service, Salesforce success.

#### 2005+ Cloud
Mostly a marketing concept, emerge as a technical solution but users don't care about the details right now. We could describe what we expect when we talk about cloud like this:

* ondemand Self-service
* Networking access
* Resource pool
* Elasticity
* Billing and metering

### Cloud vocabulary

* IaaS
	* Networking
	* Storage
	* Servers
	* Virtualization
	* OS

* PaaS
	* Middleware
	* Runtime

* SaaS
	* Data
	* Application

* Public Cloud
	* IaaS: Amazon EC2, Rackspace Cloud
	* PaaS: Google Apps, Windows Azure
	* SaaS: Salesforce.com, PeopleSoft,

* Private
	* IaaS: OpenStack
	* PaaS: Windows Azure, platform appliance

### OpenStack project

* OpenSource project created by RackSpace and Nasa in July 2010. It's now managed by a Foundation with a ~$10M close to Linux Foundation budget.
* 150 companies participating, SUSE is a platinum sponsor, *Alan Clark* board chairman.
* 24 members in the admin conseil: 8 platinum, 8 Gold, 8 elected by the community. No more then 2 person from the same company.
* 6 Releases: *Austin, Bexar, Cactus, Diablo, Essex, Folsom, Grizzly* soon.

#### OpenStack Mission
to produce the ubiquitous Open Source cloud computing platform that will meet the needs of public and private cloud providers regardless of size, by being **simple to implement** and **massively scalable**.

#### Components

* Identity - *Keystone*
* Compute - *Nova*
* Storage - *Swift*
* Images - *Glance*
* Block Storage - *Cinder*
* Network - *Quantum*
* Dashboard - *Horizon*

### SUSE Cloud

It's SUSE [offering](https://www.suse.com/products/suse-cloud/) in the Cloud space powered by OpenStack. They've added some technologies on top of it to simplify the deployment.

![][suse-cloud]

* *Admin Server*
	* Chef
	* Crowbar

* *Suse tools*
	* VM Mgmt: SUSE Manager
	* Image Tool: SUSE Studio

* *Partners*
	* Billing: Cloud Cruiser
	* Portal: RightScale
	* App Monitor: TBD
	* Security & Performance: TBD

They currently have a partnership with *Hedera Technologies*.

### Links

* [Official Documentation](https://www.suse.com/documentation/suse_cloud10/)
* [Download 1.0](http://download.novell.com/Download?buildid=W1JGPzPqUUU~&ref=suse) evaluation

[suse-cloud]: /images/posts/susecloud.png  "SUSE Cloud"