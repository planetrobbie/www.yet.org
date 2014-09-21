---
title: "NSX vSphere troubleshooting"
created_at: 2014-09-15 12:00:00 +0100
kind: article
published: true
tags: ['howto', 'nsx']
---

Last week we reviewed all the tips & tricks to troubleshoot *Open vSwitch* and *OpenStack Neutron*. *NSX vSphere* (NSX-v) is a different beast, mostly because it leverage *VMware Distributed Switch* (VDS) instead of *Open vSwitch*. I spent the last few days gathering all the CLI to troubleshoot it. So I'm pleased to share my findings with all of you.

<!-- more -->

### NSX vSphere Web UI

Before jumping into the marvelous world of command lines, as a starter, we'll check the state of the environment from the *vSphere Web Client UI*.

Authenticate to your web client, and click on `Network & Security > Installation > Management`. 

![][nsxv-controller-status]

You should see a green status for your three controllers.

Next click on `Network & Security > Installation > Host Preparation` and open up each cluster.

![][nsxv-clusters-status]

All the nodes are also green.

Now click on `Network & Security > Installation > Logical Network Preparation` and open up each cluster

![][nsxv-preparation-status]

Each compute node should have a Virtual Tunnel Endpoint (VTEP) vmkernel interface (vmk3 here) with an IP Address assigned to it.

Don't worry if you get any errors, this article is meant to help you troubleshoot the root cause.

### Transport Network

If VXLAN Connectivity isn't operational, I mean if a VM on a VXLAN cannot ping another one on the same logical switch the most common reason is a misconfiguration on the transport network. To check that, SSH to a Compute node and type :

	ping ++netstack=vxlan -d -s 1572 -I vmk3 1.2.3.4

`++netstack=vxlan` instruct the ESXi host to use the VXLAN TCP/IP stack.  
`-d` set Don’t Fragment bit on IPv4 packet  
`-s 1572` set packet size to 1572 to check if MTU is correctly setup up to 1600  
`-II` VXLAN vmkernel interface name  
`1.2.3.4` Destination ESXi host IP Address  

If the ping fails, launch another one without the don't fragment/size argument set

	ping ++netstack=vxlan -I vmk3 1.2.3.4

If this one succeed, it means your MTU isn't correctly set to at least 1600 on your transport network.

If both fails it's a VLAN ID or Uplink misconfiguration. Before going any further you have to make sure that these pings works.

If both succeed, but you still don't have connectivity on the virtual wire, I'll show you, in the Compute node controller connectivity section, how to investigate that using `net-vdl2 -l`.

Note: If you don't know the name of your VXLAN vmkernel you can easily check it, by looking at the configuration of your VDS.

![][nsxv-vds]

But you've also seen that information in the Logical Network Preparation UI above.

### Controller

You can get the IP Address of your Controller by clicking on the VM named `NSX_Controller_<ID>` in the *vSphere Web Client*.

![][nsxv-controller-vm]

To investigate controller issues, SSH to one of your controller VM to use the CLI (login: admin, password: the one set at deployment time).

#### status

	# show control-cluster status
	
	Type                Status                                       Since
	--------------------------------------------------------------------------------
	Join status:        Join complete                                09/14 14:08:46
	Majority status:    Connected to cluster majority                09/18 08:45:16
	Restart status:     This controller can be safely restarted      09/18 08:45:06
	Cluster ID:         b20ddc88-cd62-49ad-b120-572c23108520
	Node UUID:          b20ddc88-cd62-49ad-b120-572c23108520
	
	Role                Configured status   Active status
	--------------------------------------------------------------------------------
	api_provider        enabled             activated
	persistence_server  enabled             activated
	switch_manager      enabled             activated
	logical_manager     enabled             activated
	directory_server    enabled             activated

List all the nodes in the cluster.

	# show control-cluster startup-nodes
	
	192.168.110.201, 192.168.110.202, 192.168.110.203

List the implemented role on your controller, the `Not Configured` for api_provider is normal, it's the NSX-Manager who's published the NSX-v API.

	# show control-cluster roles

	                          Listen-IP  Master?    Last-Changed  Count
	api_provider         Not configured      Yes  09/18 08:45:17      6
	persistence_server              N/A      Yes  09/18 08:45:17      5
	switch_manager            127.0.0.1      Yes  09/18 08:45:17      6
	logical_manager                 N/A      Yes  09/18 08:45:17      6
	directory_server                N/A      Yes  09/18 08:45:17      6

List current connections to your controller.

	# show control-cluster connections

	role                port            listening open conns
	--------------------------------------------------------
	api_provider        api/443         Y         1
	--------------------------------------------------------
	persistence_server  server/2878     Y         2
	                    client/2888     Y         3
	                    election/3888   Y         0
	--------------------------------------------------------
	switch_manager      ovsmgmt/6632    Y         0
	                    openflow/6633   Y         0
	--------------------------------------------------------
	system              cluster/7777    Y         2

Get Controller Statistics

	# show control-cluster core stats

	role                port            listening open conns
	--------------------------------------------------------
	api_provider        api/443         Y         1
	--------------------------------------------------------
	persistence_server  server/2878     Y         2
	                    client/2888     Y         3
	                    election/3888   Y         0
	--------------------------------------------------------
	switch_manager      ovsmgmt/6632    Y         0
	                    openflow/6633   Y         0
	--------------------------------------------------------
	system              cluster/7777    Y         2


#### Controller networking 

	# show network interface
	
	Interface       Address/Netmask     MTU     Admin-Status  Link-Status
	breth0          192.168.110.201/24  1500    UP            UP
	eth0                                1500    UP            UP

	# show network default-gateway
	# show network dns-servers

NTP is mandatory, so make sure it's correctly configured

	# show network ntp-servers
	# show network ntp-status

To troubleshoot controller networking you can also use

	traceroute <ip_address or dns_name>
	ping <ip address> or ping interface addr <alternate_src_ip> <ip_address>
	watch network interface breth0 traffic

#### L2 networking troubleshooting

First make sure to connect on the master controller of the virtual network you want to troubleshoot. You can then use the following commands

	# show control-cluster logical-switches vni 5001
	VNI      Controller      BUM-Replication ARP-Proxy Connections VTEPs
	5001     192.168.110.201 Enabled         Enabled   0           0

You'll find below many more commands you can use on the master Controller for your Virtual Network (VNI = 5001 here).

	# show control-cluster logical-switches connection-table 5001
	# show control-cluster logical-switches vtep-table 5001
	# show control-cluster logical-switches mac-table 5001
	# show control-cluster logical-switches arp-table 5001
	# show control-cluster logical-switches joined-vni <ip>
	# show control-cluster logical-switches vtep-records <ip>
	# show control-cluster logical-switches mac-records <ip>
	# show control-cluster logical-switches arp-records <ip>

#### L3 networking troubleshooting

First you can list all of your logical routers

	# show control-cluster logical-routers instance all
	LR-Id      LR-Name            Hosts[]         Edge-Connection Service-Controller
	1460487509 default+edge-1     192.168.110.51                  192.168.110.201
	                              192.168.110.52
	                              192.168.210.52
	                              192.168.210.51
	                              192.168.210.57
	                              192.168.210.56

You can then use the LR-Id above to get interface details on one instance

	# show control-cluster logical-routers interface-summary 1460487509
	Interface                        Type   Id           IP[]
	570d45550000000b                 vlan   100
	570d45550000000c                 vxlan  5004         10.10.10.1/24
	570d45550000000a                 vxlan  5000


Use the Interface name to get even more details on VXLAN 5004 LIF for example
	
	# show control-cluster logical-routers interface 1460487509 570d45550000000c
	Interface-Name:   570d45550000000c
	Logical-Router-Id:1460487509
	Id:               5004
	Type:             vxlan
	IP:               10.10.10.1/24
	DVS-UUID:         1cec0e50-029c-a921-b6d8-d0fc73e57969
	                  ee660e50-e861-6d04-b4d8-1d462df952bc
	Mac:              02:50:56:8e:21:35
	Mtu:              1500
	Multicast-IP:     0.0.0.1
	Designated-IP:
	Is-Sedimented:    false
	Bridge-Id:
	Bridge-Name:

To get the routing table of your logical router

	# show control-cluster logical-routers routes 1460487509

#### Bridging

To get more information on a all bridge instance hosted on your logical router

	# show control-cluster logical-routers bridges <lr-id> all
	LR-Id       Bridge-Id   Host            Active
	1460487509  1           192.168.110.52  true

And now the Mac address on them

	# show control-cluster logical-routers bridge-mac <lr-id> all
	LR-Id       Bridge-Id   Mac               Vlan-Id Vxlan-Id Port-Id   Source
	1460487509  1           00:50:56:ae:9b:be 0       5000     50331650  vxlan

### Compute Nodes

In the introduction we've seen how to send ping on the transport network. But from a SSH connection to an ESXi node, we can use many more troubleshooting commands. This section will details most of them.

#### VMs

Get a list of all VMs on the compute node

	# esxcfg-vswitch -l
	Switch Name      Num Ports   Used Ports  Configured Ports  MTU     Uplinks
	vSwitch0         1536        1           128               1500
	
	  PortGroup Name        VLAN ID  Used Ports  Uplinks
	  VM Network            0        0
	
	DVS Name         Num Ports   Used Ports  Configured Ports  MTU     Uplinks
	Mgmt_Edge_VDS    1536        13          512               1600    vmnic1,vmnic0
	
	  DVPort ID           In Use      Client
	  897                 1           vmnic0
	  767                 1           vmk2
	  639                 1           vmk1
	  510                 1           vmk0
	  895                 0
	  905                 1           vmk3
	  907                 1           vmnic1
	  506                 1           NSX_Controller_c6aea614-0dc7-40fd-b646-0230608d4709.eth0
	  497                 1           dr-4-bridging-0.eth0
	  127                 1           br-sv-01a.eth0



#### VMkernel Port

	# esxcfg-vmknic -l
	Interface  Port Group/DVPort   IP Family IP Address                              Netmask         	Broadcast       MAC Address       MTU     TSO MSS   Enabled Type
	vmk0       510                 IPv4      192.168.110.52                          255.255.255.0   192.168.	110.255 00:50:56:09:08:3c 1500    65535     true    STATIC
	vmk1       639                 IPv4      10.10.20.52                             255.255.255.0   10.10.20	.255    00:50:56:64:f0:9b 1500    65535     true    STATIC
	vmk2       767                 IPv4      10.10.30.52                             255.255.255.0   10.10.30	.255    00:50:56:65:67:8e 1500    65535     true    STATIC
	vmk3       905                 IPv4      192.168.150.52                          255.255.255.0   192.168.	150.255 00:50:56:6e:5e:e3 1600    65535     true    STATIC

#### ARP Table

	# esxcli network ip neighbor list
	Neighbor         Mac Address        Vmknic    Expiry  State  Type
	---------------  -----------------  ------  --------  -----  -------
	192.168.110.202  00:50:56:8e:52:25  vmk0     674 sec         Unknown
	192.168.110.42   00:50:56:09:45:60  vmk0    1196 sec         Unknown
	192.168.110.10   00:50:56:03:00:2a  vmk0    1199 sec         Unknown
	192.168.110.203  00:50:56:8e:7a:a4  vmk0     457 sec         Unknown
	192.168.110.201  00:50:56:8e:ea:bd  vmk0     792 sec         Unknown
	192.168.110.22   00:50:56:09:11:07  vmk0    1146 sec         Unknown
	10.10.20.60      00:50:56:27:49:6b  vmk1     506 sec         Unknown

#### Controller connectivity

To check Controller connectivity from ESXi (VDL= Virtual Distributed Layer 2)

	net-vdl2 -l
	XXX

Or

	# esxcli network vswitch dvs vmware vxlan network list –vds-name <vds name>

If you see a controller down message above, you can fix it by restarting `netcpa` like this

	/etc/init.d/netcpa restart

To check ESXi controller connections

	esxcli network ip connection list| grep tcp | grep 1234
	XXX

#### Logical Router

First get a list of running distributed router (VDR) instance
	
	net-vdr --instance -l
	XXX


Dump all the Lifs for a VDR instance
	
	net-vdr --lif -l <vdrName>

Check routing status

	net-vdr -R -l default+edge-4

ARP information
	
	net-vdr --nbr -l default+edge6

Designated instance statistics
	
	net-vdr --di —stats

#### Bridging

Dump bridge info
	
	net-vdr --bridge -l <vdrName>

Lists MAC table, learnt on both VXLAN and VLAN sides 

	net-vdr -b --mac default+edge-1 

Dump statistics
	net-vdr -b --stats default+edge-1

#### Packet Capture

vSphere 5 offers a new command, `pktcap-uw` to capture packet at different level of the processing.

![][nsxv-pktcap]

You can get look at all possibilities
	
	pktcap-uw -h |more

As you can see on the diagram above, we can now capture traffic at the `vmnic`, `vmknic`, 'vnic' level. 

Let see how it works from the outside world to the VM. I'm not going to include the ouput of the command here, I advice you to try on your hosts instead. By the way I also advice to save the output to a file in pcap format with `-o ./save.pcap`, you'll then be able to open it from Wireshark.

####  UPlink/vmnic

You can open up the DVUplinks section of your VDS to get the name of your uplink interface. Here we'll be using `vmnic0`. So to capture packets received on this uplink, use

	pktcap-uw --uplink vmnic0

By default it will only capture received traffic (RX), to capture packets sent on the uplink to the outside world use the `--capture` argument like this

	pktcap-uw --uplink vmnic0 --capture UplinkSnd

We'll details all the filtering options at the end of this section, but in the meantime you can for example filter out only **ICMP** packet received on a specific destination by using `--proto 0x01` and `--destip <ip>`

	pktcap-uw –uplink vmnic0 –proto 0x01 –dstip <IP>

Or to capture ICMP Packets that are sent on vmnic0 from an IP Address 192.168.25.113

	pktcap-uw --uplink vmnic0 --capture UplinkSnd –proto 0x01 --srcip 192.168.25.113

You can also capture **ARP** packets

	pktcap-uw --uplink vmnic0 –ethtype 0x0806 

#### vmknic - Virtual Adapters

Capture packets reaching vmknic adapter is also possible, just use `--vmk` argument.

	pktcap-uw --vmk vmk0 

#### Switchport

To capture on a specific switchport, you first have to get the ID of the port. Launch

	# esxtop

Type `n`, to get a list of all the ports with the corresponding attachment. Take note of Port ID of the port you're interested in and use a `--switchport` argument like this

	pktcap-uw –switchport <port-id> –-proto 0x01 

#### Traffic direction

For `–switchport`, `–vmk`, `–uplink`, `–dvfilter`, direction of traffic is specified using `--dir 0` for inbound and `--dir 1` for outbound but inbound is assumed.

	0- Rx (Default)
	1- Tx

So don't be surprised, pktcap-uw doesn't work like tcpdump and by default only capture the received (RX) traffic. Don't forget to change that if necessary by specifying `--dir 1`, it will switch the capture to the Transmit (Tx) direction.

#### Argument and Filtering Options

`-o save.pcap` to save capture to a file in pcap format  
`-c 25` capture only 25 packets  
`–-vxlan <segment id>` to specify VXLAN VNI of flow  
`--vlan <VLANID>` filter for VLAN ID  
`–-ip <x.x.x.x>` filter for SRC or DST   
`--srcmac <xx:xx:xx:xx:xx>` filter for source mac address  
`--dstmac <xx:xx:xx:xx:xx>` filter for source mac address  
`--srcip <x.x.x.x[/<range>]>` filter for source IP  
`--dstip <x.x.x.x[/<range>]>` filter for destination IP  
`--dstport <DSTPORT>` to specify a TCP destination Port  
`--srcport <SRCPORT>` to specify a TCP source Port  
`--tcpport <PORT>` filter for source or destination Port  
`--proto 0x<IPPROTYPE>` filter on hexadecimal protocol id: 0x01 for ICMP, 0x06 for TCP, 0x11 for UDP.list [here](http://en.wikipedia.org/wiki/List_of_IP_protocol_numbers)  
`--ethtype 0x<ETHTYPE>` filter on ethernet type, 0x0806 for ARP  

#### Decoding capture

We've shown you how to save the captured packets to a file, to get a quick overview of the kind of traffic passing by, you can decode the pcap using tcpdump like this

	tcpdump -r save.pcap

But using Wireshark will give you a better vision of the traffic, with all the details.

#### Tracing

If you are interested in seeing even more details on the processing of the packet through the ESXi TCP/IP stack, just add `--trace` argument to see packet traversing the ESXi network stack. Looks for Drop message that indicate something went wrong in the processing.

#### Drops

When things don't work as you expect, one really usefull command is

	pktcap-uw --capture Drop 

You should see here some errors like `VLAN Mismatch` or something else that will give you a hint about why traffic isn't flowing as you would expect.

#### DVFilter

This command captures packets as seen by the dvfilter (before the filtering happens)
	
	pktcap-uw --capture PreDVFilter --dvfilterName <filter name>

This command captures packets after being subject to the dvfilter.

	pktcap-uw --capture PostDVFilter --dvfilterName <filter name>   

#### Capture point XXX

You can get a list of all possible capture point with `-A` XXX

	pktcap-uw -A

In summary here is the list of all the possibilities

`PortOutput` show traffic delivered from the vSwitch to the Guest when used with switch port or to the physical adapter if used with a physical adapter  
`VdrRxLeaf` - Capture packets at the receive leaf I/O chain of a dynamic router in VMware NSX. Use this capture point together with the --lifID option  
`VdrRxTerminal` - Capture packets at the receive terminal I/O chain of a dynamic router in VMware NSX. Use this capture point together with the --lifID option  
`VdrTxLeaf` - Capture packets at the transmit leaf I/O chain of a dynamic router in VMware NSX. Use this capture point together with the --lifID option  
`VdrTxTerminal` - Capture packets at the transmit terminal I/O chain of a dynamic router in VMware NSX. Use this capture point together with the --lifID option  
`

#### ctrl-c vs ctrl-d

Never press `crtl-d` to interupt a running packet capture or you'll be left with a background process still running. If you've done it you can kill it like this

	kill $(lsof |grep pktcap-uw |awk '{print $1}'| sort -u)

Then check it was killed
	
	lsof |grep pktcap-uw |awk '{print $1}'| sort -u  

### Logs

Controller Logs

Check ESXi connectivity issues from the Controller

	show log cloudnet/cloudnet_java-vnet-controller.<start-time-stamp>.log


### Todo

Section TBD :

* NSX Edge CLI
* Expand Logs Section

### Conclusion

This article is a work in progress. I hope you'll accelerate your troubleshooting session by having a great understanding of all the internals. 

### Links

* [nsx-compendium](http://networkinferno.net/nsx-compendium)

[nsxv-controller-status]: /images/posts/nsxv-controller-status.png "NSX-v vSphere Web Client - Controller Status"
[nsxv-clusters-status]: /images/posts/nsxv-clusters-status.png "NSX-v vSphere Web Client - Cluster Status" width=850
[nsxv-preparation-status]: /images/posts/nsxv-preparation-status.png
[nsxv-controller-vm]: /images/posts/nsxv-controller-vm.png "NSX-v vSphere Web Client - Controller VM IP"
[nsxv-controller-clistatus]: /images/posts/nsxv-controller-clistatus.png "NSX-v CLI - Controller Status"
[nsxv-vds]: /images/posts/nsxv-vds.png "Distributed Switch"
[nsxv-pktcap]: /images/posts/nsxv-pktcap.png "Packet Capture"