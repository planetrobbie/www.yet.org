---
title: "Mirantis OpenStack 7.0 - Reduced Footprint"
created_at: 2015-10-07 19:16:00 +0100
kind: article
published: true
tags: ['howto', 'openstack', 'mirantis', 'fuel']
---

Mirantis OpenStack 7.0 got released few days ago and brings OpenStack Kilo and [lots](https://docs.mirantis.com/openstack/fuel/fuel-7.0/release-notes.html) of innovation. I'm happy to share with you today a really nice feature, *Reduced Footprint* offers a way to deploy OpenStack on a small footprint as its name implies, two servers would be a good start. But three servers are still the bare minimum to achieve control plane HA.

Fuel will start by deploying a KVM node and then instantiate VMs to deploy OpenStack Controller within it. Fuel can also move itself to the same KVM hypervisor to free up one more physical node. In the end you'll have a controller and fuel running on one machine, and the other bare metal server will be used as a compute node. That's exactly the objective of this article so lets get started.

<!-- more -->

### Pre-requisites

If you don't have Mirantis Fuel installed, you can [download](https://software.mirantis.com/openstack-downloads/) the ISO and use your first physical server to install it. Consult the [documentation](https://docs.mirantis.com/openstack/fuel/fuel-7.0/user-guide.html#download-and-install-fuel) if you've never done it and need some help. It's trivial, you just need to boot on the ISO and wait until a configuration menu appears. Just make sure you don't have any other DHCP servers on the PXE network where Fuel will be connected to avoid any conflict.


### Prepare Fuel 7.0

Now that you have Fuel 7.0 ready, connect over SSH to activate the  [Reduced Footprint Feature](https://docs.mirantis.com/openstack/fuel/fuel-7.0/operations.html#using-the-reduced-footprint-feature).

	vi /etc/fuel/version.yaml

To add the following `advanced` line

	VERSION:
  	feature_groups:
    	- mirantis
    	- advanced

To activate the advanced mode, you need to restart Nailgun, the Fuel API. Enter the corresponding Docker Container

	dockerctl shell nailgun

And restart it

	supervisorctl restart nailgun

You should see

	nailgun: stopped
	nailgun: started

Now Exit the container
	
	exit

### Create a new OpenStack environment

Connect to the Fuel Web UI which should be available on `https://<fuel-IP>:8443` to create a new [OpenStack Environment](https://docs.mirantis.com/openstack/fuel/fuel-7.0/user-guide.html#create-env-ug). Choose *Neutron with tunneling segmentation* for the networking setup, if you choose *Neutron with VLAN segmentation* instead you'll have some additional steps to do, described in the [docs](https://docs.mirantis.com/openstack/fuel/fuel-7.0/operations.html#using-the-reduced-footprint-feature).

Power-on your second physical server, wait until it is discovered by Fuel. You can easily check that from the CLI

	# fuel nodes
	id | status   | name             | cluster | ip         | mac               | roles                            | pending_roles | online | group_id
	---|----------|------------------|---------|------------|-------------------|-----------------------	-----------|---------------|--------|---------
	4  | ready    | mos7-04.bulb.int | 1       | 10.20.0.74 | 00:50:56:b4:90:3a | cinder-vmware, 	controller, mongo |               | True   | 1       
	2  | ready    | mos7-03.bulb.int | 1       | 10.20.0.72 | 00:50:56:b4:e4:13 | cinder, 	compute                  |               | True   | 1       
	3  | ready    | mos7-01.bulb.int | 1       | 10.20.0.73 | 00:50:56:b4:23:4f | cinder-vmware, 	controller, mongo |               | True   | 1       
	5  | ready    | mos7-05.bulb.int | 1       | 10.20.0.75 | 00:50:56:b4:90:49 | cinder-vmware, 	controller, mongo |               | True   | 1       
	1  | ready    | mos7-02.bulb.int | 1       | 10.20.0.71 | 00:50:56:b4:cd:40 | cinder, 	compute                  |               | True   | 1       
	6  | discover | Untitled (16:c4) | None    | 10.20.0.76 | 00:50:56:b4:16:c4 	|                                  |               | True   | None    

Last node in that list, **Node ID 6** is the one I'll be using as a KVM node.

You'll also need your environment ID:

	# fuel env
	id | status      | name         | mode       | release_id | pending_release_id
	---|-------------|--------------|------------|------------|-------------------
	1  | operational | bulb_kilo    | ha_compact | 2          | None              
	2  | new         | bulb_reduced | ha_compact | 2          | None  

I'll be using the new **environment ID is 2**.

### Assign Virt Role and configure a VM

We'll stick with the FUEL CLI, as soon as your new node is discovered, you can assign a Virt role to it.

	# fuel --env-id=2 node set --node-id=6 --role=virt
	Nodes [6] with roles ['virt'] were added to environment 2

Configure a Virtual Machine on it by uploading its configuration in JSON format

	# fuel2 node create-vms-conf 6 --conf '{"id":1,"mem":8,"cpu":4}'

`6` correspond to the Node ID with the Virt Role.  
`id:1` is a VM identifier, need to be unique on that node.

You can then freely choose how much RAM and CPU you want to provide to this VM. For a controller I would recommend at least 8Gb of RAM.

Fuel2 is a new Fuel CLI which adds more ways to interact with Nailgun API, you can get a full list of arguments by calling its integrated help

	# fuel2 -h

This new Fuel Client use a different syntax

	# fuel [general flags] <entity> <action> [action flags]

`<Entity>` could be: env, network-group, network-template, node, task  
`<Action>` possible actions: list, add, create, update, delete, show, download, upload, label, spawn-vms, upgrade.

If you are like me, located in EMEA with different locale on your system, you have to know that it is sent to the remote system and could cause the following error

	locale.Error: unsupported locale setting

Make sure your system is setup not to send locale

	# cat /etc/ssh/ssh_config | grep LC
	SendEnv LANG LC_*

Or set the locales on your system as follow 

	LANG="en_US.UTF-8"
	C_COLLATE="en_US.UTF-8"
	C_CTYPE="UTF-8"
	C_MESSAGES="en_US.UTF-8"
	C_MONETARY="en_US.UTF-8"
	C_NUMERIC="en_US.UTF-8"
	C_TIME="en_US.UTF-8"
	C_ALL=

You can check your VM is there

	# fuel2 node list-vms-conf 6
	+----------+----------------------------------+
	| Field    | Value                            |
	+----------+----------------------------------+
	| vms_conf | {u'mem': 2, u'id': 1, u'cpu': 4} |
	+----------+----------------------------------+

`6` is the Node ID with the Virt Role.

Before launching the deployment, connect to the Fuel UI to update your OpenStack Environment Settings and the node disk and nics configuration.

### VM Provisioning

It's now time to provision both the KVM and the corresponding VM

	# fuel2 env spawn-vms 2

`2` is the Environment ID.

You can track the task progress from CLI

	# fuel2 task list
	+----+---------+----------------+---------+--------+----------+
	| id | status  | name           | cluster | result | progress |
	+----+---------+----------------+---------+--------+----------+
	| 66 | ready   | deploy         |       1 | -      |      100 |
	| 67 | ready   | check_networks |       1 | -      |      100 |
	| 70 | ready   | deployment     |       1 | -      |      100 |
	| 71 | running | spawn_vms      |       2 | -      |        0 |
	| 72 | running | provision      |       2 | -      |        0 |
	| 73 | running | deployment     |       2 | -      |        0 |
	+----+---------+----------------+---------+--------+----------+

get task details with the show command

	# fuel2 task show 71
	+----------+----------------------------------------------------+
	| Field    | Value                                              |
	+----------+----------------------------------------------------+
	| id       | 71                                                 |
	| uuid     | 57dd1270-70d8-4be9-a334-c9f036caac96               |
	| status   | ready                                              |
	| name     | spawn_vms                                          |
	| cluster  | 2                                                  |
	| result   | -                                                  |
	| progress | 100                                                |
	| message  | Deployment of environment 'bulb_reduced' is done.  |
	+----------+----------------------------------------------------+


*Astute*, Fuel Orchestrator, start by casting a [message](http://paste.openstack.org/show/474800/) to start Ubuntu installation on node-6. Once the OS Provisionning is done, it will run Puppet tasks to install/configure KVM on the host and spawn configured VMs. But to be able to deploy Ubuntu 14.04 on node-6, because it's a new environment, Fuel will generate a new OS Image build. You can track progress from Fuel Master Node:

	# tail -f /var/log/docker-logs/fuel-agent-env-2.log

Once finished you'll get a new shiny image within `/var/www/nailgun/targetimages/env_2_ubuntu_1404_amd64.img.gz`.

If this process fails, you have to make sure Fuel have access to the configured Ubuntu upstream repository, `archive.ubuntu.com` by default. If your lab don't have internet Access you'll have to have at least a Ubuntu 14.04 internal mirror to proceed. Since release MOS 6.1, Fuel ISO doesn't contain Ubuntu distribution anymore, which allows simpler [patching](https://docs.mirantis.com/openstack/fuel/fuel-7.0/operations.html#applying-patches) of slave node by relying on the upstream repository. You just need to run `apt-get update; apt-get upgrade` to patch your nodes.	

When the OS deployment task ends, you can switch to the Puppet log to see what is being configured on the slave node

	# tail -f /var/log/puppet.log

When you'll get 100 in progress like below

	# fuel2 task list
	+----+--------+----------------+---------+--------+----------+
	| id | status | name           | cluster | result | progress |
	+----+--------+----------------+---------+--------+----------+
	| 66 | ready  | deploy         |       1 | -      |      100 |
	| 67 | ready  | check_networks |       1 | -      |      100 |
	| 70 | ready  | deployment     |       1 | -      |      100 |
	| 78 | ready  | check_networks |       2 | -      |      100 |
	| 83 | ready  | spawn_vms      |       2 | -      |      100 |
	| 84 | ready  | provision      |       2 | -      |      100 |
	| 85 | ready  | deployment     |       2 | -      |      100 |
	+----+--------+----------------+---------+--------+----------+

You should get a similar Fuel Web UI screen

![][mos7-reducedfootprint-1]

After a bit, a new node will be discovered

![][mos7-reducedfootprint-2]

Click on it to get further details, you can confirm below it has 4 vCPU and 2GB of RAM as expected from the JSON we've provided earlier.

![][mos7-reducedfootprint-3]

Another nice feature of MOS 7.0 is the ability to change the hostname from node-7 to any FQDN just by clicking on the pencil circled in red above. You have to do this before deploying the node, after it's locked, the pencil just disappear.

If you run `fuel nodes` you'll also see the same new discovered node, `node-7`, its ID is 7.

### Assign Controller Role

Now we want to use this VM as a Controller, from the CLI run

	# fuel --env-id=2 node set --node-id=7 --role=controller
	Nodes [7] with roles ['controller'] were added to environment 2

If necessary, multiple node-id can be specified separated by commas, if you want a HA deployment. Here we are only deploying one, on node this VM Node ID 7 on Env ID 2:

Configure its Networking from the Fuel Web UI. A new [flexible networking](https://docs.mirantis.com/openstack/fuel/fuel-master/operations.html#using-networking-templates) feature is also available in MOS 7.0 but we'll talk about that in a future article. So from Fuel Web UI click on the little gear icon to access the following node configuration button. We'll leave node configuration as an exercice for the reader. Make sure to use the following ordering for the Nics: Admin (PXE), Public, Storage, Management, Private or you'll have to change the libvirt template at `/etc/puppet/modules/osnailyfacter/templates/vm_libvirt.erb`.

![][mos7-reducedfootprint-4]

### Assign Compute Role

We also don't details the steps to add a Compute node to your environment to allow your controller to control something ;) You can consult *Mirantis OpenStack [Operations Guide](https://docs.mirantis.com/openstack/fuel/fuel-7.0/operations.html#add-a-non-controller-node)* to review the steps involved. 

### Deployment

Once that's done you can launch the deployment, from `Fuel Web UI > Dashboard` click on `Deploy Changes`.

Lets consider we've added `node-8` as a compute node, you can also launch the deployment from Fuel CLI:

	# fuel --env 2 node --deploy --node-id=7,8

If your deployment terminates in error, investigate the issue. Then if you want to restart where you left off, don't do a `Reset your Environment` from Fuel Master Node Web UI, or it will kill the KVM VM running on the KVM host, instead run the above command again.

### Fuel Migration

You can now migrate the **Fuel Master Node** itself to the newly deployed KVM node by running the following command from Fuel:

	# fuel-migrate node-6
	Create VM fuel_master on 10.20.0.76
	Create partition table
	Create lvm volumes and file-systems
	Rebooting to begin the data sync process
	
	Broadcast message from root@fuel7.bulb.int
		(/dev/pts/11) at 15:35 ...
	
	The system is going down for reboot NOW!


`node-6` is the name of the KVM node where you want to migrate your **Fuel Master Node**. Use `fuel node` to get a list of your nodes, if you forgot it.

`fuel-migrate` will by default 

* log all of its actions within `/var/log/fuel-migrate.log`
* use `/etc/fuel/astute.yaml` as a baseline for configuring the Fuel VM
* create a VM named `fuel-master` with 2 vCPU, 2Gb RAM and 100g disk
* store the VM on the KVM host in `/var/lib/nova/fuel_master.img`
* partition the VM
	* root size is the same as source
	* 20% of the remaining space for var partition
	* 30% of the remaining space for varlibdocker
	* 2 x RAM size for swap
	* 100% of the remaining size for varlog
* connect the Fuel VM PXE network to `br-fw-admin` of the KVM node
* reboot and rsync disk partitions from Fuel Bare Metal to Fuel VM

But you can change all the above default values with the following args

`--fvm_disk_size="100g"` VM disk size  
`--fvm_name="fuel_master"` VM name  
`--fvm_ram="2048"` RAM allocation  
`--fvm_cpu="2"` vCPU allocation  
`--fm_reboot="yes` if you don't want to automatically reboot to start synchronisation set it to "no"  
`--admin_net_br="br-fw-admin"` change PXE network bridge connection from br-fw-admin to new bridge.  
`--other_net_bridges=eth1,,<bridge-name-on-kvm-host>` to create other interfaces for Fuel VM  
`--dkvm_folder="/var/lib/libvirt/images/"` to store the VM image elsewhere on the destination KVM host.  
`--migrate_log="/var/log/fuel-migrate.log"` where to log migration logs  
`--fuel_astute="/etc/fuel/astute.yaml"` to use another Fuel configuration file as a baseline  
`--admin_net_b_type` Additional data to put inside network interface block definition.  
`--os_swap="4096"` swap size  
`--os_root="9.78g"` root partition size  
`--os_var="20%"` var partition size  
`--os_varlibdocker="30%"` varlibdocker partition size  
`--os_varlog="100%"` varlog partition size  
`--del_vm="no"`  set it to "yes" to remove the destination virtual machine if it exists.  
`--max_worktime="7200"` Timeout for entire migration process in seconds. Default is 2h.

You'll find a trace of the choosen values of your Fuel migration within `/root/fuel-migrate.var`

If you look at your bare metal Fuel Master node console, you'll see during the migration

![][mos7-reducedfootprint-5]

As you can see, when the migration ends, the source Fuel Master Node will reboot and change its IP not to collision with the new Fuel VM which is now using the original one. You can still access the source master node, but on a new IP address as specified on the console screenshot above.

If everything finished successfully you should get the following message when SSHing to the Fuel VM on the orginal Fuel IP Address.

	                     Congratulation! You are on cloned Fuel now!

	    The migration tasks have completed. The clone should be up and functioning
	correctly. You should now check the new system and inspect the log stored in
	/var/log/fuel-migrate.log.
	
	    After the reboot of the Fuel master, it may require additional time before
	it becomes fully operational. Please allow at least 10 minutes for the system
	to become active.
	
	    The source Fuel master is still up in maintenance mode. Once you have
	verified that the new Fuel master is functioning correctly, you can shut down
	or wipe the original Fuel master. The source Fuel master can be reached by
	using ssh to 10.30.0.4. Should you want to wipe the disk for bootstraping,
	you may do so by running the following:
	
	# ssh 10.30.0.4 dd if=/dev/zero of=/dev/null count=1024 bs=1024 conv=fdatasync
	# ssh 10.30.0.4 reboot -f
	
	    To disable this message, run:
	
	# rm /etc/profile.d/c-msg.sh
	
	    If the new Fuel master is not functioning correctly, you may return the
	source Fuel master back into an operational state by running:
	
	# ssh 10.30.0.4 reboot && ssh -tt 10.30.0.3 virsh destroy fuel_master
	
	    This command will reboot the source Fuel master and remove the new
	Fuel master clone. To prevent IP conflict, this command should be as indicated.
	If you are performing this command over ssh, your session may hang and you may
	need to reestablish your ssh connection.

### Conclusion

MOS 7.0 reduced footprint feature is a convenient way to build out a small Infrastructure as a Service environment for up to medium sized Datacenters or for learning purposes.

All of the above steps can be achieved within VMs with nested virtualisation. Just make sure you expose hardware assisted virtualisation to the Guest OS. Good luck !

### Links		

* Mirantis OpenStack 7.0 [official documentation](https://docs.mirantis.com/openstack/fuel/fuel-7.0/#guides)
* Reduced footprint [documentation](https://docs.mirantis.com/openstack/fuel/fuel-7.0/operations.html#using-the-reduced-footprint-feature)


[mos7-reducedfootprint-1]: /images/posts/mos7-reducedfootprint-1.png width=750px
[mos7-reducedfootprint-2]: /images/posts/mos7-reducedfootprint-2.png width=350px
[mos7-reducedfootprint-3]: /images/posts/mos7-reducedfootprint-3.png width=550px
[mos7-reducedfootprint-4]: /images/posts/mos7-reducedfootprint-4.png width=350px
[mos7-reducedfootprint-5]: /images/posts/mos7-reducedfootprint-5.png width=450px