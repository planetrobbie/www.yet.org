---
title: "Mirantis OpenStack Cheatsheet"
created_at: 2015-12-06 23:00:00 +0100
kind: article
published: false
tags: ['cheatsheet', 'openstack', 'mirantis', 'fuel']
---

OpenStack is evolving at a rapid pace and for those of you that were here in the early beginning, you may have lost track of the new kids on the block. OpenStack CLI tools is one of them, and is a common client which does many things. In this article I'll not only review this one but will gather all the toolkit at our disposal from the command line to drive Mirantis OpenStack. Please fasten your seat belts ;)

<!-- more -->

### Launching instances

First gather all the required information: keypair, flavor, image, network and security group.

	$ nova keypair-list
	$ openstack keypair list
	+------+-------------------------------------------------+
	| Name | Fingerprint                                     |
	+------+-------------------------------------------------+
	| rack | a9:36:6c:23:71:de:f7:c5:8b:89:5d:72:9d:3e:b3:96 |
	+------+-------------------------------------------------+

	$ nova flavor-list
	$ openstack flavor list
	+--------------------------------------+-----------+-----------+------+-----------+------+-------+-------------+-----------+
	| ID                                   | Name      | Memory_MB | Disk | Ephemeral | Swap | VCPUs | RXTX_Factor | Is_Public |
	+--------------------------------------+-----------+-----------+------+-----------+------+-------+-------------+-----------+
	| 1                                    | m1.tiny   | 512       | 1    | 0         |      | 1     | 1.0         | True      |
	| 2                                    | m1.small  | 2048      | 20   | 0         |      | 1     | 1.0         | True      |
	| 3                                    | m1.medium | 4096      | 40   | 0         |      | 2     | 1.0         | True      |
	| 4                                    | m1.large  | 8192      | 80   | 0         |      | 4     | 1.0         | True      |
	| 4a0a065f-f4ee-45b5-9cdf-934d38e0c254 | m1.micro  | 64        | 0    | 0         |      | 1     | 1.0         | True      |
	| 5                                    | m1.xlarge | 16384     | 160  | 0         |      | 8     | 1.0         | True      |
	+--------------------------------------+-----------+-----------+------+-----------+------+-------+-------------+-----------+

	$ nova image-list
	$ openstack image list
	+--------------------------------------+--------------+--------+--------+
	| ID                                   | Name         | Status | Server |
	+--------------------------------------+--------------+--------+--------+
	| 3c15ec11-e3c5-4f6d-84ff-c84c09a23462 | TestVM       | ACTIVE |        |
	| 1449e398-9218-45ba-8064-22164322e3b1 | TestVM-VMDK  | ACTIVE |        |
	| 0acbc275-2d70-4aaa-8994-d7f0ffb9d88d | Ubuntu-12.04 | ACTIVE |        |
	+--------------------------------------+--------------+--------+--------+

	$ neutron net-list
	$ openstack network list
	+--------------------------------------+-----------+-----------------------------------------------------+
	| id                                   | name      | subnets                                             |
	+--------------------------------------+-----------+-----------------------------------------------------+
	| 19ddae66-3e70-4a19-bee5-4ae6123ac3f4 | mynet     | 06623c06-6218-4e5e-9af0-0ae4222e69bf 13.0.1.0/24    |
	|                                      |           | 70f4a48c-4eb9-45cf-a4f5-0d2edf6ea9d3 13.0.0.0/24    |
	|                                      |           | e618fc07-111b-43e3-9cd9-31b47b7f9f86 13.0.2.0/24    |
	| 80fbeee3-407d-4579-986e-cca0e4fa8445 | net04     | 97b84270-b251-46f2-9f53-ee691745a03e 12.0.0.0/24    |
	| fb60da82-e11c-4a3e-af33-d8d23364dfa4 | net04_ext | f4bb2f7f-a276-471a-ba51-d7823a00055a 192.168.1.0/24 |
	+--------------------------------------+-----------+-----------------------------------------------------+

If you aren't using Neutron but Nova-network, replace the above command by

	$ nova net-list
	+--------------------------------------+-------------+-------------+
	| ID                                   | Label       | CIDR        |
	+--------------------------------------+-------------+-------------+
	| d22988f2-37be-4b42-b67b-6c927f7c164f | novanetwork | 12.0.0.0/24 |
	+--------------------------------------+-------------+-------------+

	$ nova secgroup-list
	$ openstack security group list
	+--------------------------------------+---------+------------------------+
	| Id                                   | Name    | Description            |
	+--------------------------------------+---------+------------------------+
	| 352206dc-9442-40ea-ae79-7d8e671ca81d | default | Default security group |
	| cc97b314-fa09-4c23-aa0d-0ecfe20fd5e9 | open    |                        |
	+--------------------------------------+---------+------------------------+

You can now launch an instance

	$ nova boot --flavor m1.tiny --image TestVM --nic net-id=80fbeee3-407d-4579-986e-cca0e4fa8445 \
	            --security-group open --key-name rack instance-01
	$ openstack server create --flavor m1.tiny --image TestVM --nic net-id=80fbeee3-407d-4579-986e-cca0e4fa8445 \
	            --security-group open --key-name rack instance-01
	+--------------------------------------+-----------------------------------------------+
	| Property                             | Value                                         |
	+--------------------------------------+-----------------------------------------------+
	| OS-DCF:diskConfig                    | MANUAL                                        |
	| OS-EXT-AZ:availability_zone          | nova                                          |
	| OS-EXT-SRV-ATTR:host                 | -                                             |
	| OS-EXT-SRV-ATTR:hypervisor_hostname  | -                                             |
	| OS-EXT-SRV-ATTR:instance_name        | instance-0000000b                             |
	| OS-EXT-STS:power_state               | 0                                             |
	| OS-EXT-STS:task_state                | scheduling                                    |
	| OS-EXT-STS:vm_state                  | building                                      |
	| OS-SRV-USG:launched_at               | -                                             |
	| OS-SRV-USG:terminated_at             | -                                             |
	| accessIPv4                           |                                               |
	| accessIPv6                           |                                               |
	| adminPass                            | u6q2vQL5xrHF                                  |
	| config_drive                         |                                               |
	| created                              | 2015-11-27T15:11:16Z                          |
	| flavor                               | m1.tiny (1)                                   |
	| hostId                               |                                               |
	| id                                   | f05a479c-1291-4b97-9130-20ab36f47e25          |
	| image                                | TestVM (f8101757-42bf-48cb-bace-2c92b1d02d01) |
	| key_name                             | test                                          |
	| metadata                             | {}                                            |
	| name                                 | instance-01                                   |
	| os-extended-volumes:volumes_attached | []                                            |
	| progress                             | 0                                             |
	| security_groups                      | open                                          |
	| status                               | BUILD                                         |
	| tenant_id                            | 0f3a2d2bf68b4393a8a35b131ea179ae              |
	| updated                              | 2015-11-27T15:11:20Z                          |
	| user_id                              | be89190acf1b407281ab2ae7e8326204              |
	+--------------------------------------+-----------------------------------------------+

Check its status

	$ nova list
	$ openstack server list
	+--------------------------------------+-------------+--------+------------+-------------+-------------------------------------+
	| ID                                   | Name        | Status | Task State | Power State | Networks                            |
	+--------------------------------------+-------------+--------+------------+-------------+-------------------------------------+
	| ffd522a6-e101-4465-ae11-2e931c47ba22 | instance-01 | BUILD  | spawning   | NOSTATE     |                                     |
	| 2662680d-49fe-4571-8837-b3675605de31 | ku-1        | ACTIVE | -          | Running     | novanetwork=12.0.0.2, 192.168.1.136 |
	| 9cab07f7-4263-4066-a009-add50ab803e0 | ku-2        | ACTIVE | -          | Running     | novanetwork=12.0.0.3, 192.168.1.139 |
	+--------------------------------------+-------------+--------+------------+-------------+-------------------------------------+

and
	
	$ nova show ffd522a6-e101-4465-ae11-2e931c47ba22
	$ openstack server show ffd522a6-e101-4465-ae11-2e931c47ba22
	+--------------------------------------+----------------------------------------------------------+
	| Property                             | Value                                                    |
	+--------------------------------------+----------------------------------------------------------+
	| OS-DCF:diskConfig                    | MANUAL                                                   |
	| OS-EXT-AZ:availability_zone          | nova                                                     |
	| OS-EXT-SRV-ATTR:host                 | node-2.bulb.int                                          |
	| OS-EXT-SRV-ATTR:hypervisor_hostname  | node-2.bulb.int                                          |
	| OS-EXT-SRV-ATTR:instance_name        | instance-00000017                                        |
	| OS-EXT-STS:power_state               | 1                                                        |
	| OS-EXT-STS:task_state                | -                                                        |
	| OS-EXT-STS:vm_state                  | active                                                   |
	| OS-SRV-USG:launched_at               | 2015-11-27T15:19:25.000000                               |
	| OS-SRV-USG:terminated_at             | -                                                        |
	| accessIPv4                           |                                                          |
	| accessIPv6                           |                                                          |
	| config_drive                         |                                                          |
	| created                              | 2015-11-27T15:18:59Z                                     |
	| flavor                               | m1.tiny (1)                                              |
	| hostId                               | 2d458c9f668895ef99941fcbb9da9e756840d9c8acf31fcd9b736add |
	| id                                   | ffd522a6-e101-4465-ae11-2e931c47ba22                     |
	| image                                | TestVM (3c15ec11-e3c5-4f6d-84ff-c84c09a23462)            |
	| key_name                             | rack                                                     |
	| metadata                             | {}                                                       |
	| name                                 | instance-01                                              |
	| novanetwork network                  | 12.0.0.4                                                 |
	| os-extended-volumes:volumes_attached | []                                                       |
	| progress                             | 0                                                        |
	| security_groups                      | open                                                     |
	| status                               | ACTIVE                                                   |
	| tenant_id                            | e30ef295f5484dcabc79fc0e5cdd8d97                         |
	| updated                              | 2015-11-27T15:19:26Z                                     |
	| user_id                              | 50f02c8d50b9408d91a40716cc6b89f5                         |
	+--------------------------------------+----------------------------------------------------------+

### VNC Console access

	$ nova get-vnc-console instance-01 novnc
	$ openstack console url show 93fb6795-c04e-4906-9bdc-b9670740d931
	+-------+-------------------------------------------------------------------------------------+
	| Type  | Url                                                                                 |
	+-------+-------------------------------------------------------------------------------------+
	| novnc | https://kilo.bulb.int:6080/vnc_auto.html?token=3152fa19-0130-49ae-9903-3174835017ef |
	+-------+-------------------------------------------------------------------------------------+

### Floating IP

#### To create a floating IP

	$ neutron floatingip-create net04_ext
	$ openstack ip floating create net04_ext
	Created a new floatingip:
	+---------------------+--------------------------------------+
	| Field               | Value                                |
	+---------------------+--------------------------------------+
	| fixed_ip_address    |                                      |
	| floating_ip_address | 192.168.1.155                        |
	| floating_network_id | fb60da82-e11c-4a3e-af33-d8d23364dfa4 |
	| id                  | 488c296b-d918-4e08-945b-b6af50f41ed9 |
	| port_id             |                                      |
	| router_id           |                                      |
	| status              | DOWN                                 |
	| tenant_id           | 0f3a2d2bf68b4393a8a35b131ea179ae     |
	+---------------------+--------------------------------------+

#### To associate it

	$ nova floating-ip-associate instance-01 192.168.1.155
	$ openstack ip floating add 192.168.1.155 instance-01
	XXX

### Instances Migration

There are two reason why you would want to evacuate OpenStack Instances from compute nodes. The node could require some maintenance operations to change hard disk, add RAM, ... or the node could have failed.

We'll review the operations to recover in both cases.

#### Evacuation when host is up

You can put a host in maintenance mode using 

	# nova-manage service disable --host=<HOST_UUID> --service=nova-compute

And then evacuate live instances

	$ nova host-evacuate-live --target-host=<HOSTNAME> <HOST_TO_EVACUATE>

`--target-host=<HOSTNAME>` if not specified the scheduler will choose the best host.

#### Evacuation when host is down

In a catastrophic scenario where a compute host is down, start by listing the instances that reside on your failed node

	$ nova list --host node-2.bulb.int
	$ server list --host node-1.bulb.int
	+--------------------------------------+------+--------+------------+-------------+-------------------------------------+
	| ID                                   | Name | Status | Task State | Power State | 	Networks                        |
	+--------------------------------------+------+--------+------------+-------------+-------------------------------------+
	| 2662680d-49fe-4571-8837-b3675605de31 | ku-1 | ACTIVE | -          | Running     | novanetwork=12.0.0.2, 192.168.1.136 |
	+--------------------------------------+------+--------+------------+-------------+-------------------------------------+

Now try to find a host that can receive the orphaned instances
	
	$ nova hypervisor-list
	$ openstack hypervisor list
	+----+---------------------+-------+---------+
	| ID | Hypervisor hostname | State | Status  |
	+----+---------------------+-------+---------+
	| 1  | domain-c7(lab)      | up    | enabled |
	| 2  | node-1.bulb.int     | up    | enabled |
	| 3  | node-2.bulb.int     | down  | enabled |
	+----+---------------------+-------+---------+
	
As you can see above `node-2.bulb.int` is really down, which is important to check before launching any evacuation command or you'll get some error messages.

As soon as you've indentified a receiving host, you can then evacuate instances there.

	$ nova evacuate 2662680d-49fe-4571-8837-b3675605de31 node-1.bulb.int

In the above scenario, the instance will be rebuilt from the original image or volume, but preserve its ID, name, uuid, IP, etc...

If you have shared storage, prefer the following command that will preserve the user disk data

	$ nova evacuate 2662680d-49fe-4571-8837-b3675605de31 node-1.bulb.int --on-shared-storage

Because you haven't specified a password using `--password` argument, you should get a generated one in the following output

	+-----------+--------------+
	| Property  | Value        |
	+-----------+--------------+
	| adminPass | gKB8xG5gWgxJ |
	+-----------+--------------+

You should now be able to ssh to your instance by targeting the same floating IP

	ssh -l ubuntu 192.168.1.136
	ubuntu@ku-1:~$

### Live migration

OpenStack support live migration of instances with almost no instance downtime using `nova live-migration` instead of `nova migrate` which shuts down instance first.

Start by identifying a host with enough capacity

	$ nova host-describe node-2.bulb.int
	$ openstack host show node-2.bulb.int
	+-----------------+------------+-----+-----------+---------+
	| HOST            | PROJECT    | cpu | memory_mb | disk_gb |
	+-----------------+------------+-----+-----------+---------+
	| node-2.bulb.int | (total)    | 4   | 3953      | 20      |
	| node-2.bulb.int | (used_now) | 0   | 512       | 0       |
	| node-2.bulb.int | (used_max) | 0   | 0         | 0       |
	+-----------------+------------+-----+-----------+---------+

	$ nova live-migration 2662680d-49fe-4571-8837-b3675605de31 node-2.bulb.int

`--block-migrate` required if you don't have shared storage and if VM has local ephemeral storage.

If you don't have shared storage and don't trust the block migration above, you have to rely on the following command instead:

	$ nova migrate 2662680d-49fe-4571-8837-b3675605de31

In this simple scenario you cannot choose the receiving host.

### Install the OpenStack CLI clients

The general formula to install Python clients is

	$ sudo pip install python-PROJECTclient

For example:

	$ sudo pip install python-openstackclient
	$ sudo pip install python-novaclient
	$ nova --version
	2.35.0
	$ openstack --version
	openstack 1.9.0

`--upgrade` required if older version already installed

Current list of OpenStack project that have CLI tools: barbican, 

Note: If you don't have PIP installed on your machine run
	
	apt-get install python-dev python-pip

	or

	easy_install pip

### SSL API Endpoints

By default Mirantis OpenStack will use in its generated Openrc file an unsecure HTTP based URL. If you want to switch over to a secure one instead, find the public secure URL for Keystone endpoint

	$ openstack catalog list | grep 5000

Now edit your `openrc` file and update the corresponding line 

	export OS_AUTH_URL='http://10.0.1.2:5000/v2.0/'

With

	export OS_AUTH_URL='https://kilo.bulb.int:5000/v2.0/'

`--insecure` is required if your SSL Self Signed Certificate cannot be verified.S

### Start/Stop OpenStack Services

#### List services

Mirantis OpenStack manage some services using Pacemaker, so before trying to start/stop any of them check if they are managed by it with

	# services=$(curl http://git.openstack.org/cgit/openstack/governance/plain/reference/projects.yaml | \
	  egrep -v 'Security|Documentation|Infrastructure' | \
	  perl -n -e'/^(\w+):$/ && print "openstack-",lc $1,".*\$|",lc $1,".*\$|"')

Following services aren't managed by Pacemaker

	# initctl list | grep -oE $services | grep start
	cinder-volume start/running, process 16418
	nova-cert start/running, process 27741
	cinder-api start/running, process 12774
	heat-api-cfn start/running, process 8849
	nova-objectstore start/running, process 26314
	heat-api-cloudwatch start/running, process 9790
	nova-api start/running, process 11258
	nova-consoleauth start/running, process 26547
	nova-conductor start/running, process 11739
	glance-registry start/running, process 11037
	nova-scheduler start/running, process 11507
	neutron-server start/running, process 10722
	cinder-backup start/running, process 16896
	fuel-rabbit-fence start/running, process 3981
	glance-api start/running, process 13366
	cinder-scheduler start/running, process 13029
	nova-novncproxy start/running, process 26194
	murano-api start/running, process 14563
	heat-api start/running, process 13146
	murano-engine start/running, process 14276

But are instead managed with `initctl`, while the following services are managed by Pacemaker

	# initctl list | grep -oE $services | grep stop
	neutron-dhcp-agent stop/waiting
	neutron-ovs-cleanup stop/waiting
	nova-spicehtml5proxy stop/waiting
	heat-engine stop/waiting
	keystone stop/waiting
	neutron-metadata-agent stop/waiting
	neutron-l3-agent stop/waiting
	neutron-plugin-openvswitch-agent stop/waiting
	nova-xenvncproxy stop/waiting

#### Restart non HA OpenStack services on Controllers

	# initctl restart heat-api-cloudwatch
	# initctl restart heat-api-cfn
	# initctl restart heat-api
	# initctl restart cinder-api
	# initctl restart cinder-scheduler
	# initctl restart nova-objectstore
	# initctl restart nova-cert
	# initctl restart nova-api
	# initctl restart nova-consoleauth
	# initctl restart nova-conductor
	# initctl restart nova-scheduler
	# initctl restart nova-novncproxy
	# initctl restart neutron-server

#### Restart non HA  OpenStack services on Compute

	# initctl restart neutron-plugin-openvswitch-agent
	# initctl restart nova-compute

#### Restart HA-OpenStack services on Controllers

	# crm resource restart p_heat-engine
	# crm resource restart p_neutron-plugin-openvswitch-agent
	# crm resource restart p_neutron-dhcp-agent
	# crm resource restart p_neutron-metadata-agent
	# crm resource restart p_neutron-l3-agent

Optionally if you also run ceilometer in your environment

	# pcs resource disable p_ceilometer-agent-central --wait \
      && pcs resource enable p_ceilometer-agent-central --wait

### Patching Fuel

To patch your Fuel Master Node, first makes sure you have access to the configured repositories at least thru a proxy. If necessary add the following environment variables.

	http_proxy="http://<PROXY-IP>:<PROXY-PORT>"; export http_proxy

save the data to `/var/backup/fuel/` with

	#  dockerctl backup

update Fuel

	# yum update
	# docker load -i /var/www/nailgun/docker/images/fuel-images.tar
	# dockerctl destroy all
	# dockerctl start all
	# puppet apply -dv /etc/puppet/modules/nailgun/examples/host-only.pp

### Patching slave nodes

To patch nodes that are deployed from Fuel, download the following [script](https://raw.githubusercontent.com/Mirantis/tools-sustaining/master/scripts/mos_apply_mu.py) and run it

    python mos_apply_mu.py --env-id=1 --user=<FUEL_USER> --pass=<FUEL_PASSWORD> \
                           --update --master-ip="<FUEL-IP>"

`--user` is admin by default  
`--master-ip` will be taken from astute.yaml if not present  
`--check` will give you the current status of your update  
 `--mos-proposed`   Enable proposed updates repository, by default only mos-updates is enabled  
 `--mos-security`   Enable security updates repository  

### Force HTTPS access on FUel

	# vi /etc/fuel/astute.yaml

to add

	SSL:

		force_https: true


### Logging Monitoring and Alerting Fuel Plugin

#### restart LMA Collector on Controllers

	controller# pcs resource disable lma_collector; pcs resource enable lma

#### restart LMA collector on non Controller nodes

	node-4# initctl restart lma_collector

### RabbitMQ

#### List non empty queues

	controller# rabbitmqctl list_queues | grep -v 0$

#### Clear messages from queues

	controller# rabbitmqadmin --username=nova --password=<PASSWORD> purge queue name=<QUEUE_NAME>

`<PASSWORD>` is available withing `/etc/fuel/astute.yaml`


### Conclusion

Lots of commands, all quite usefull and sometimes hard to memorize.

### Links		

* Official OpenStack [CLI Cheatsheet](http://docs.openstack.org/user-guide/cli_cheat_sheet.html)
