---
title: "Deploy OpenStack IceHouse using Ansible"
created_at: 2014-08-14 12:00:00 +0100
kind: article
published: false
tags: ['howto', 'openstack', 'ansible', 'devops']
---

It's now time to give [Ansible](http://www.ansible.com/) a chance to enter the battleground of OpenStack deployer tool. We'll use Ansible 1.7 and [Blue Box](https://www.bluebox.net/) playbooks to achieve that goal.

<!-- more -->

If you don't have Ansible already installed, consult our [previous article](/2014/07/ansible/) or the [official documentation](http://docs.ansible.com/intro_installation.html). You'll see it's quite easy.

Ansible by itself doesn't install the Operating system on Bare Metal. But Ansible author, Michael DeHaan, developped Cobbler a PXE solution [back](http://www.ansible.com/blog/2013/12/08/the-origins-of-ansible) when working for Red Hat. So you can use this tool or any other tools like MAAS, Razor to install at least four Ubuntu 12.04 servers.

This lab will be leveraging an OpenStack cloud, I'll deploy OpenStack IceHouse on top of OpenStack.

### Ursula repository

Ursula, the Ansible playbooks from Blue Box for operating OpenStack is the first thing we need. Clone this repository into your Ansible admin node

	git clone git@github.com:blueboxgroup/ursula.git

### Nova client

Installing OpenStack on OpenStack using Ursula require Nova client, install it.

	pip install git+https://github.com/openstack/python-novaclient.git

### OpenRC

Now you need to get your OpenStack API access RC file from Horizon dashboard, it should look like this

	$ cat $HOME/.stackrc

	#!/bin/bash

	# With the addition of Keystone, to use an openstack cloud you should
	# authenticate against keystone, which returns a **Token** and **Service
	# Catalog**.  The catalog contains the endpoint for all services the
	# user/tenant has access to - including nova, glance, keystone, swift.
	#
	# *NOTE*: Using the 2.0 *auth api* does not mean that compute api is 2.0.  We
	# will use the 1.1 *compute api*
	export OS_AUTH_URL=<REPLACE WITH YOUR AUTH URL>
	
	# With the addition of Keystone we have standardized on the term **tenant**
	# as the entity that owns the resources.
	export OS_TENANT_ID=<REPLACE WITH YOUR ID>
	export OS_TENANT_NAME="<REPLACE WITH YOUR TENANT NAME>"
	
	# In addition to the owning entity (tenant), openstack stores the entity
	# performing the action as the **user**.
	export OS_USERNAME="<REPLACE WITH YOUR OS USERNAME>"
	
	# With Keystone you pass the keystone password.
	echo "Please enter your OpenStack Password: "
	read -sr OS_PASSWORD_INPUT
	export OS_PASSWORD=$OS_PASSWORD_INPUT

### Image and Network ID

Depending on your OpenStack environment, you'll need to update the `ursula/test/common` file with your Image and Network ID as shown below

	export ANSIBLE_SSH_ARGS="${SSH_ARGS}"
	export ANSIBLE_VAR_DEFAULTS_FILE="${ROOT}/envs/test/defaults.yml"
	export IMAGE_ID=${IMAGE_ID:=b12b987a-c526-466a-9baa-fa32f98f46cd}
	export NET_ID=${NET_ID:=704ffb97-9123-410f-9430-678304e61021}

### Target Hosts

As we've said earlier, you need at least four Ubuntu 12.04 servers allowing SSH access without password. Use the example environment `ursula/envs/example` which you can copy anywhere outside the repository. Edit the `hosts` file to dispatch hosts in the different groups.

	[db]
	db.yet.org
	db2.yet.org
	
	[db_arbiter]
	compute.yet.org
	
	[controller]
	controller.yet.org
	
	[compute]
	compute.yet.org
	
	[network]
	neutron.yet.org

