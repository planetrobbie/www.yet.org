---
title: "ISC DHCP server deployment with Ansible"
created_at: 2014-11-22 17:00:00 +0100
kind: article
published: true
tags: ['howto', 'ansible']
---

Over the last few weeks I built a new home lab based on the Supermicro [A1SAi-2750F](http://www.supermicro.com/products/motherboard/Atom/X10/A1SAi-2750F.cfm) motherboard. Instead of manually configuring the required infrastructure services like DNS, NTP, OpenVPN and DHCP, I'm using [Ansible](https://www.ansible.com) to do all of it, in an easy and repeatable fashion. As a reminder Ansible is a **YAML** based configuration management tool, it's **agentless**, use **SSH** as a communication medium. It's **simple** and **efficient**. Read our [intro article](/2014/07/ansible/) for more details. In this article I'll details how to install a [ISC DHCP](https://www.isc.org/downloads/dhcp/) server using Ansible. *ISC DHCP* is production-grade software that offers a complete solution for implementing DHCP servers, relay agents, and clients for small local networks to large enterprises.

<!-- more -->

### Requirements

On your management node, you'll need **Python 2.7**, **Ansible** and it's dependencies (*paramiko, PyYAML, jinja2, httplib2*). The target node, where we'll install the DHCP server, should be installed with a barebone Ubuntu 14.04 but any Debian based distribution should work too.

### DepOps ISC DHCP Role

When I said Ansible is efficient, I mean it. Just run the following command from your management node to get a DebOps Playbook for DHCPd :

  # ansible-galaxy install debops.dhcpd

[Ansible Galaxy](https://galaxy.ansible.com/) offers hundreds of reusable Roles for Ansible.  

By the way, [DebOps](http://debops.org/) team is offering lots of Ansible Playbook to the community. I'm grateful to the DepOps team. For example they offer Roles to Install and Configure :

* Java, Golang, NodeJS, PHP, Ruby
* ElasticSearch, Redis, Mysql, Postgresql
* GitLab
* LXC, KVM, OpenVZ
* nginx
* iptables, SSHd, NFS, Samba, NTP, Rsyslog
* and many more stuff.

### Variables

Before applying the Playbook to your target node, you need to tune it to your need by using a YAML variable file, **vars-dhcpd.yml**, mine look like this :

    ---
  
    dhcpd_authoritative: True
    dhcpd_interfaces: [ eth0 ]
    ansible_domain: bulb.int
    
    # where to ask for DNS Server / dhcpd_dns_servers
    ansible_default_ipv4.address: 192.168.2.1
    
    dhcpd_shared_networks:
      - name: 'ls-bulb-net'
        comment: "Remote shared network"
        subnets: '{{ dhcpd_subnets_local }}'
        options: |
          default-lease-time 600;
          max-lease-time 900;
    
    dhcpd_subnets_local:
     - subnet: '192.168.2.0'
       netmask: '255.255.255.0'
       routers: [ '192.168.2.1' ]
       pools:
         - comment: "ls-web pool"
           range: '192.168.2.100 192.168.2.199'
    
     - subnet: '192.168.3.0'
       netmask: '255.255.255.0'
       routers: '192.168.3.1'
       options: |
         default-lease-time 300;
         max-lease-time 7200;
       pools:
         - comment: "ls-db pool"
           range: '192.168.3.100 192.168.3.199'

Consult the dhcpd server [documentation](http://www.bctes.com/dhcpd.conf.5.html) to get a better understanding of the overall configuration parameters to update this file according to your needs.

`dhcpd_authoritative` authoritative servers respond with DHCPNAK when getting requests for address he knows nothing about. Otherwise he will remain silent.  
`dhcpd_shared_networks` inform the DHCP server that some IP subnets actually share the same physical network.  
`subnet` required for  every  subnet  which will be served, and for every subnet to which the dhcp server is connected. If a range section is present, it will enable your server to serve addresses.  
`pools` The pool declaration can be used to specify a pool of addresses that will be treated differently than another pool of addresses, even on the same network segment or subnet.

### Playbook

To apply the `debops.dhcpd` role to your target node. Just create a Playbook named `infra.yml`

    ---
    # This playbook just apply debops.dhcpd Role to a target node. 
    - name: Infrastructure Services [DHCP server]
      hosts: target-node
      
      vars_files:
        - vars-dhcpd.yml
    
      roles:
         - debops.dhcpd

### Inventory

To allow Ansible to connect to your target-node, update your `/etc/ansible/hosts` inventory file

    [target-node]
    <IP ADDRESS>

This node should be SSH accessible as root or you'll have to specify the user and/or private key to use 

    [target-node]
    <IP ADDRESS> ansible_ssh_user=<USERNAME> ansible_ssh_private_key_file=<PRIVATE KEY PATH>

Note: It's not recommended to put variables in your inventory file, to better comply with Ansible best practice place this in a filename named after your node name (target-node here) in the `/etc/ansible/host_vars/` directory. If you always use the same `username/private key` pair, you can also edit `/etc/ansible/ansible.cfg` to update the corresponding variables `remote_user` and `private_key_file`.

### Run the Playbook

You are now ready to run your Ansible Playbook :

    # ansible-playbook infra.yml

You should now have a fully operational DHCP server.  

### Summary

We've seen how easy Ansible allows us to configure Infrastructure services like a DHCP server.  

It's done in 4 easy steps :

* install an Ansible Galaxy Role
* Tune the Role to your need by default value in a YAML variable file
* Create a Playbook to apply the role and your variable file to your target node
* Run the Playbook

### Links

* [DebOps documenation](http://docs.debops.org/en/latest/)
* [DebOps Git Repository](https://github.com/debops)
* [DebOps ISC DHCP Role](https://github.com/debops/ansible-dhcpd)
* [DebOps dnsmasq Role](https://github.com/debops/ansible-dnsmasq) - another DHCP server alternative.