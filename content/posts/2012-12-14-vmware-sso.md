---
title: "VMware Single Sign-On and vCenter 5.1 Deployment Deep Dive"
created_at: 2012-12-14 16:04:28 +0100
kind: article
published: true
tags: ['vmware', 'howto']
---

When *VMware* released version 5.1 of their cloud infrastructure suite namely *vCloud Suite*, end of August 2012, vCenter 5.1 integrated an advanced Single Sign-On mechanism to easily login to most components of the suite, let's review the technical background involved. *Justin King* is part of VMware technical marketing team, he presented the latest innovations with a particular focus on SSO.

<!-- more -->

### Summary of vCenter 5.1 Features

* ***Fully functional Web Client***
	* feature complete
	* all of the new technologies are only available in the web client
	* there is a slight learning curve (~1-2h)
* ***Object Tagging***
	* previously it was custom attributes wihch still exist
	* Tagging is simular with much more flexibility, we can place it on anything on the inventory: VM, Datastores, Networks, Hosts
* ***Single Sign-On***
	* Authentication services
* ***Performance Improvements***
	* not only from the client perspective but also at the database level
* ***HA*** for all vCenter Services
	* SSO, Inventory Service, Web Client, flexibility to scale-out or scale-up them

#### vSphere Web Client

Primary client for vSphere 5.1 environment, supported for IE, Firefox and Chrome on Windows and Mac, it's a Abobe Flash based solution (11.1+).  
300 concurrent sessions on the Web client eats around 25% of vCenter CPU while 100 session of the previous vSphere client eats around 50% of CPU resources. Database partinionned now, Clients Reads are offloaded to the Inventory Services, writes still done directly on vCenter.

* Platform independant
* Simplified Upgrades
* Tagging
* Saved Workflows
	* Minimize a workflow will automatically save it.
* Advanced search
	* Prefered way of finding inventory
	* Inventory list is an object type group used to return results
	* Saved search
* Object inventory
* Related Objects
* Common set of Tabs
	* Summary
	* Manage
	* Monitor

Plugins have to be re-engineered, HP already there, some Dell are also available as well as PureStorage. They are now server based plugin. So you can still use the legacy client if you still have unsupported plugins.

#### Tags vs Folders

An object cannot be in multiple folders, but with Tags, you can have multiple tags for objects. Custom attributes can still be managed from the legacy vSphere Client. You can view but cannot create them from the web client. You can choose to migrate them to Tags instead.

### vCenter Single Sign-On

**Goal**

* Less administrative overhead
* Fewer places where security issues may arise
* Fewer places to configure connectivity to corporate identity stores

![][sso-01]

ActiveDirectory, OpenLDAP, Local OS (win/linux), NIS supported. All permissions still handled within the solution. It gives much better auditing about who's accessing what.

![][sso-02]

SSO component can be seperated from the vCenter Server, SSO Database (very small, few changes, contains config & group ownership) is separated from vCenter Database. It isn't recommended to use local user database. SSO can connect to multiple Identity Sources. Based on industry standards

* WS-TRUST, WS-Security
* SAML 2.0

SSO is like an Island, multiple vCD, vCenter can all be on the same Island. If multiple vCenters uses the same SSO Island, you'll see them all after login to Web Sphere client. Linked mode isn't any more required. The way SSO is architected, you don't want to connect to SSO over the WAN, it will add delay. In a metropolitan area with high bandwidth we can share the SSO component to all of them to get an unified view. It's not for remote locations, use Linked mode in this use case. Linked Mode is still required for :

* Sharing Roles
* Sharing Permissions
* Sharing licensing

![][sso-03]

Session Timeout will ask for re-Authentication at the end of the configured delay.

* Ability to accept SAML 2.0 Tokens
* Should be able to open up a SAML 2.0 token and get identity/group information
* Register itself as a Solution user with SSO
* By Providing a certificate (its identity)

Today SSO supports the following products :

* vCenter
* VSM - vShield Manager
* vCD - vCloud Director (only provider side logins as of now)
* VDP - VMware Data Protection
* Log Browser
* vCO - vCenter Orchestrator
* Web Client
* Inventory Service
* SSO

Still unsupported:

* SRM
* vCops
* Partners
* Cross Domain with a Single SSO component, we use Standard LDAP.

#### Impact of SSO - How does it affect you ?

* Runtime
	* New notion of security domain
	* Users now managed by SSO, not vCenter
	* 2 admins: VI Admin & SSO Admin (only for SSO administration)
	* Active Directory Domain Discovery protocol is different, we use standard LDAP.
* Install/Upgrade
	* Need to install 4 moving parts now: vCenter, vCenter SSO, vCenter Inventory Service, vSphere Web Client
	* How to decide where to install these components ? supports Linux and Windows.
	* Simple install vs Custom Install
* Deployment
	* Multiple deployment options are possible now.
	* Which one should I choose ?

### Installation and deployment

* 5.1 on Windows have the following components : vCenter SSO, vCenter Inventory Service, vCenter, vCenter Web Client
* 5.1 Linux appliance contains all of them embedded.

#### Order of installation

1. Install SSO
2. vCenter Server Inventory
3. vCenter
4. vSphere Web Client

#### Upgrade

1. vCenter SSO
2. vSphere Web Client
3. vCenter Inventory Service
4. vCenter

Deployment scenario depends on customer type

#### Customer Profile 1

* Simple deployment
* A couple of vCenter
* Doesn't want a single pane of glass across VCs
* Existing vCenters able to handle load of hosts and VMs

=> Choose simple install, 4 components on the same server.

#### Customer Profile 2

* Has many vCenters
* Wants a single pane of glass
* may be using linked mode
* May be using vCenter Heartbeat

=> Choose itemized components: SSO, Inventory Service, vCenter Server, vSphere Client vSphere Web Client (tomcat server) on different machines. See various deployment models below.

For HA you can use one ***vCenter Server Heartbeat*** license to protect all components by deploying components in Pair
or SSO can be protected in a failover scenario with a Load Balancer, vCNS could be used for that but you also need to protect the 3 other services : vCenter, vSphere Web Client, vCenter Inventory Service.

![][sso-04]

<!-- There is a KB for running SSO on physical. -->

### Multisite SSO mode

![][sso-05]

This architecture removes the limitation of SSO over the WAN. When you install *New York*, SSO is the primary one, Fairfax SSO server is a multisite instance, where you can import the data from New York. By exporting Fairfax DB and re-importing in New York you'll get a multisite implementation. There isn't any auto-synchronisation feature implemented. Only required if you use Linked Mode.

#### things to wath out for

* Certificates
	* SSO will detect expired certificates and will fail if there are some
	* Housekeeping needed prior to installation to look and update them.
	* Default right now of auto generated certificates is 4 years.
* SSO Needs to create two database user accounts
	* DB Admin User
	* Regular DB operations user
	* Cannot use Windows authentication for SSO access since that would work only when single DB user is in play
	* DB are quite small
	* Can use same or different DB server as vCenter. It could even use SQL Server Express DB without limit on VM/Hosts
* AD Configuration
* SSO now handles all user identity management

### Links

* Current vSphere release is [5.1.0a Readme](http://www.vmware.com/files/pdf/vCenter-Server-510a-README.pdf)
* VMware SSO [resources](http://blogs.vmware.com/kb/tag/sso)

[sso-01]: /images/posts/sso-01.png
[sso-02]: /images/posts/sso-02.png
[sso-03]: /images/posts/sso-03.png
[sso-04]: /images/posts/sso-04.png
[sso-05]: /images/posts/sso-05.png