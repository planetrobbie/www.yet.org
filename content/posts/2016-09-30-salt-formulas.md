---
title: "Salt Formulas"
created_at: 2016-09-30 19:00:00 +0100
kind: article
published: true
tags: ['salt', 'howto', 'devops']
---

Always reinventing the wheel doesn't pay off most of the time, so telling [Salt](/2016/09/salt/) what to do by creating [Salt States](https://docs.saltstack.com/en/latest/ref/states/all/salt.states.cmd.html) again and again to install application components isn't really efficient. Instead [Salt Formulas](https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html) brings convention and a bit of magic, and offer reusable bundles which package altogether all the necessary piece to automate a specific task, like deploying [etcd](https://coreos.com/etcd/), a distributed key value store cluster, which we will take as an example in this article.

<!-- more -->

![][saltformulas-sucrose]

Formulas have the objective of being simple enough, avoid repetition, and prevent you from having multiple places to update when changes comes. They should also be applicable to existing configuration. They pretty much reach these objectives but it's somewhat difficult to understand how they work and the magic behind it. Like [Ruby On Rails](http://rubyonrails.org/), most of Formulas construct lies behind conventions so let's details all of this to clarify everything.

First of all a Salt Formula live in its own [git repository](https://github.com/saltstack-formulas/) which should look like this

    foo-formula
    |-- foo/
    |   |-- map.jinja
    |   |-- init.sls
    |   `-- bar.sls
    |-- CHANGELOG.rst
    |-- LICENSE
    |-- pillar.example
    |-- README.rst
    `-- VERSION
    
They are mostly composed of State File (init.sls, bar.sls) which describe the end state of the system (declarative), plus added bonus to make it easily reusable. Salt Formulas are similar to Chef [Cookbooks](https://supermarket.chef.io/cookbooks/) or Ansible [Roles](https://galaxy.ansible.com/).

As of today, you'll find around a hundred formulas on the official github [formula repository](https://github.com/saltstack-formulas).

Lets details the different files and functions, starting with the most important one, **map.jinja**, where the magic happens.

### map.jinja

The **map.jinja** is the important piece, it sets data based on `os_family` grain and merges [Pillar](https://docs.saltstack.com/en/latest/topics/pillar/) data in. It's a great place to centralize variables to avoid repetition. 

    {% set server = salt['grains.filter_by']({
        'Debian': {
            'pkgs': ['etcd', 'python-etcd'],
            'services': ['etcd']
        },
        'RedHat': {
            'pkgs': [],
            'services': []
        },
    }, merge=salt['pillar.get']('etcd:server')) %}

`First Line` set the **server** variable to **grains.filter_by** which match on **os_family**, our formula will work on *Debian* and *RedHat* but other OSs could be added. On a Ubuntu machine server.services will be set to etcd. Redhat section is not yet filled out :/  
`Line 2-9` a bunch of assignment which depend on what's in the os_family [grain](https://docs.saltstack.com/en/latest/topics/grains/).  
`Last Line` is a bit confusing, this will merge all the data from the Pillar **etcd.server** yaml section into the **server** variable. Pillar data will overwrite **map.jinja** assignment.

To use map.jinja into a State file, just import it
    
    {% from "etcd/map.jinja" import server with context %}

This will import the Jinja template with context, meaning that variable will come over, **server** will contain values for **pkgs** and **services** with all the Pillar data merged into it.

You can then use the imported data in your State file

    #!yaml
    etcd_packages:
      pkg.installed:
      - names: {{ server.pkgs }}

We don't need to use [Grains](https://docs.saltstack.com/en/latest/topics/grains/index.html) any more in your State, all the data available is already pre-calculated based on `os_family` in the map.jinja. You see the magic in action here ;)

You can also access Pillar data, which should lives in a file '/srv/pillar/etcd.sls` with the same name as the formula, like this

    {{ server.engine }}

or to create conditional block in your template based on it

    {% if server.get('engine', 'systemd') %}

`engine` is the key looked at, it should be declared in your pillar file within the etc.server yaml section  
`systemd` default value returned if key doesn't exist in our server variable, meaning if it hasn't been defined in map.jinja or our Pillar.

### Pillar.example

At the root directory of each formula a [pillar.example](https://github.com/saltstack-formulas/iptables-formula/blob/master/pillar.example) file should give an overview of how to use Pillar data to customize how the Formula States will perform.

### Pillar data

Lets now look more closely at how to use [Pillar](https://docs.saltstack.com/en/latest/topics/pillar/) data with formulas.

#### top file

Pillar gets assigned to minion in the `/srv/pillar/top.sls` file. So to assign a `/srv/pillar/etcd.sls` Pillar data file to 3 minions.

    #!yaml
    base:
      'saltstack-m01,saltstack-m02,saltstack-m03':
        - etcd
        - match: list

I'm using a List match, for an etcd cluster I need at least 3 nodes. More information on Salt minion matching is available in my [About SaltStack](/2016/09/salt/) article.

#### pillar file 

Now lets have a look at our Pillar content saved as `/srv/pillar/etcd.sls`

    #!yaml
    linux:
      system:
        name: {{ grains['fqdn'] }}
    etcd:
      server:
        enabled: true
        bind:
          host: {{ grains['ipv4'][1] }}
        token: $(uuidgen)
        members:
        - host: 172.16.52.101
          name: saltstack-m01
          port: 4001
        - host: 172.16.52.102
          name: saltstack-m02
          port: 4001
        - host: 172.16.52.103
          name: saltstack-m03
          port: 4001

Above you can override anything that exist in the **map.jinja** file with a single line of code. If you want to overrides services, just add the following line at the end

    #!yaml
        services: etcd-new-srvs-name

Data from Pillar have precedence over map.jinja variables.

All of the above data will then be available to the formula State file as

    {{ server.bind.host }}

So Pillar are a really simple way to inject stuff into any formulas and even override some of their default settings.

### README.rst

Should give an overview in [restructured text](https://en.wikipedia.org/wiki/ReStructuredText) of the way the Formula can be used and what it does.

### CHANGELOG.rst

Each new version should have a line in that file which describe the deltas

### VERSION

Should contain the currently released version of the particular formula. Could be a git repository tag which will become the package version as well, when formula will be packaged as debian pkg.

Formula are versioned according to [Semantic Versioning](http://semver.org)

### Convention and best practices

The etcd formula example is taken out of the tcp cloud [repository](https://github.com/tcpcloud/salt-formula-etcd/), they are currently maintaining [OpenStack-Salt](http://docs.openstack.org/developer/openstack-salt/). This formula isn't 100% compliant with Salt Formulas conventions, it should have embedded the Pillar data into a lookup key so the map.jinja merge line should have been

    }, merge=salt['pillar.get']('etcd:lookup')) %}

and the corresponding `/srv/pillar/etcd.sls` file

    #!yaml
    linux:
      system:
        name: {{ grains['fqdn'] }}
    etcd:
      lookup:
        enabled: true
        bind:
          host: {{ grains['ipv4'][1] }}
        token: $(uuidgen)
        members:
        - host: 172.16.52.101
          name: saltstack-m01
          port: 4001
        - host: 172.16.52.102
          name: saltstack-m02
          port: 4001
        - host: 172.16.52.103
          name: saltstack-m03
          port: 4001

It would also have prevented the confusion between server the map variable and server the section of the YAML file !!! But it's really just a convention.

### Formula installation

All of this looks great but how can we then install the above etcd formula on our Salt Master. You have different options.

#### Filesystem storage

You can install the formula files to your master by cloning your forked repository

    mkdir /srv/formulas
    cd /srv/formulas
    git clone https://github.com/planetrobbie/salt-formula-etcd/

    Cloning into 'salt-formula-etcd'...
    remote: Counting objects: 100, done.
    remote: Compressing objects: 100% (49/49), done.
    remote: Total 100 (delta 20), reused 0 (delta 0), pack-reused 49
    Receiving objects: 100% (100/100), 21.58 KiB | 0 bytes/s, done.
    Resolving deltas: 100% (25/25), done.
    Checking connectivity... done.

Now you just have to add the corresponding formula directory in the Salt Master `/etc/salt/master` configuration file

    #!yaml
    file_roots:
      base:
        - /srv/salt
        - /srv/formulas/salt-formula-etcd

And restart your master

    service salt-master restart

It's done :)

#### git storage backend

Another option would be to use [gitfs](https://docs.saltstack.com/en/latest/topics/tutorials/gitfs.html#tutorial-gitfs) to connect to your forked directory instead of cloning it locally by adding the following line in your `/etc/salt/master` configuration file

    #!yaml
    fileserver_backend:
      - root
      - git

    gitfs_remotes:
      - https://github.com/<git username>/salt-formula-etcd.git

But for this to work, you need to install the dependency, **pygit2** is the default provider if no other one, like [Dulwich](https://www.dulwich.io/) or [GitPython](https://github.com/gitpython-developers/GitPython) are configured in `gitfs_provider` in the above file.
    
So install this dependency

    apt-get install python-pygit2

or for GitPython

    apt-get install python-git

or for Dulwich

    apt-get install python-dulwich

You should not connect your master directly to a 3rd party git repository or clone it directly, fork it instead to make sure you keep control over repository updates. It explain why we've put `<git username>` in the URL above, git repository should be yours.

### Applying to your minions

We have everything in place, our formula `/srv/formulas/salt-formula-etcd`, our Pillar top file `/srv/pillar/top.sls` and Pillar data file `/srv/pillar/etcd.sls`. The last required bits is to assign our formula to our minion within `/srv/salt/top.sls` which then contain

    #!yaml
    base:
      'saltstack-m01,saltstack-m02,saltstack-m03':
        - match: list
        - hostfile
        - etcd

`hostfile` state will update the hostfile of each node, it contains, it's necessary or etcd won't be able to start

    #!yaml
    updating hostfile:
      host.present:
        - ip: {{ grains['ipv4'][1] }}
        - names:
          - {{ pillar.linux.system.name }}

`grains['ipv4'][1]` IP Address of the minion  
`pillar.linux.system.name` hostname of your minion declared in the etcd.sls Pillar file.  


It's now time to apply our formula to our node, it is as simple as

    salt '*' state.apply

And will converge the formula state to our three minion. After few minutes you should have a fully operational etcd cluster. You can easily repeat this pattern each time you need such a cluster or everything else that has been described in Salt Formulas. Great isn't it !!!

If you don't believe me, check your cluster status by SSHing to one of your minion and running

    etcdctl cluster-health 
    member 970c12c81e0cde8 is healthy: got healthy result from http://172.16.52.103:4001
    member 4caf2f327f93ec8f is healthy: got healthy result from http://172.16.52.101:4001
    member d59d70c40eed3cba is healthy: got healthy result from http://172.16.52.102:4001

Try to [store/retrieve](https://coreos.com/etcd/docs/latest/getting-started-with-etcd.html) keys/values

    etcdctl set /version 1.0
    etcdctl get /version
    etcdctl rm /version

You can also store data into it using salt, refer to the [documentation](https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.etcd_mod.html) to see how to declare your cluster to Salt. etcd can also be [used](https://docs.saltstack.com/en/latest/ref/pillar/all/salt.pillar.etcd_pillar.html) as a repository for Pillar data and other stuff !!!

### Writing your own Formula

Instead of starting from a blank page, use this [template](https://github.com/saltstack-formulas/template-formula). Then think about what is OS dependant and what might need to be expanded, don't forget to set some variable to allow users to change it without giving them a ton of work. Put youself in the shoes of your formula users.

You can contribute back by asking one of the members over [irc](http://webchat.freenode.net/?channels=salt) to create a repository under the saltstack github organisation, then fork it, and do a pull request to merge your stuff back in. Congrat you've published your first Salt Formula, make sure to maintain it too ;)

To help you build your next formula, in the next chapter, I share the main Jinja2 design patterns with some examples.

### Jinja2 patterns

[Jinja2](http://jinja.pocoo.org/docs/dev/), the default Salt templating engine ([renderer](https://docs.saltstack.com/en/latest/ref/renderers/all/salt.renderers.jinja.html)), can do a lot, not to repeat what's described in [understanding Jinja](https://docs.saltstack.com/en/latest/topics/jinja/) lets focus on the patterns that improve your formulas.

#### filter_by 

As we've said earlier, **[filter_by](https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.grains.html#salt.modules.grains.filter_by)** match on the **os_family** grain by default, but it can be changed by passing another grain as argument, see the function signature

    salt.modules.grains.filter_by(lookup_dict, grain='os_family', merge=None, default='default', base=None)

`lookup_dict` dictionary, keyed by a grain, current developement release ([Carbon](https://docs.saltstack.com/en/develop/topics/releases/version_numbers.html)) allows to use globbing for the dictionary keys.  
`grain` name of a grain to match. Could be a list in the Carbon release. will return the **lookup_dict** value for a first found item in the list matching one of the lookup_dict keys.  
`merge` dictionary to merge with the results of the grain selection from lookup_dict  
`default` default lookup_dict's key used if the grain does not exists or if the grain value has no match on lookup_dict. If unspecified the value is "default".  
`base` lookup_dict key to use for a base dictionary. The grain-selected **lookup_dict** is merged over this and then finally the **merge** dictionary is merged.  This allows common values for each case to be collected in the base and overridden by the grain selection dictionary and the merge dictionary.  Default is unset.

You can list available grains with

    salt '*' grains.items

Interresting ones are **os**, **oscodename**, **osrelease** which are for a Ubuntu 16.04 system: Ubuntu, xenial, 16.04

Still curious read the [source code](https://github.com/saltstack/salt/blob/develop/salt/modules/grains.py#L450) ;)

#### update

Once you've merged Jinja variables and Pillar data together, you can still update the resulting dictionary like this

    {% set os_map = salt['grains.filter_by']({
        'Debian': {
          'config': '/etc/collectd/collectd.conf',
          'javalib': '/usr/lib/collectd/java.so',
          'pkg': 'collectd-core',
          'plugindirconfig': '/etc/collectd/plugins',
          'service': 'collectd',
          ...
          ...
        },
        ...
        ...
    }, merge=salt['pillar.get']('collectd:lookup')) %}

    {% set default_settings = {
        'collectd': {
          'Hostname': salt['grains.get']('fqdn'),
          ...
          ...
        }
    } %}

    {% do default_settings.collectd.update(os_map) %}

    {% set collectd_settings = salt['pillar.get']('collectd', default=default_settings.collectd, merge=True) %}

In the above code, we first do the usual os dependent stuff and then we set a variable which contains a map with all the default collectd settings.

We then merge **os_map** into the settings dictionary with the **update** call. This pattern is usefull to differentiate OS dependent variable from default settings and put all of this in a single map.

The last line put all this together by merging configuration Pillar data that lives in the collectd key with our **default_settings.collectd** map. So when importing this map.jinja we'll get everything required, os_dependent and default_settings overwritten by our pillar data in a single variable. To access it

    {{ collectd_settings.pkg }}

or

    {{ collectd_settings.Hostname }}

This example comes from [collectd formula](https://github.com/saltstack-formulas/collectd-formula/blob/master/collectd/map.jinja). In the 2015.5.0 Salt release, a base argument was added to the **filter_by** function. This formula can be simplified by setting up that argument to default_settings instead of doing an update later on ! But update can still be usefull in some cases.

#### import_*

It's also possible to import and deserialize an external yaml file which is then made available as a Jinja dictionary. For example, in the apache map.jinja you'll find

    {% import_yaml "apache/modsecurity.yaml" as modsec %}

Other function like **import_json** or **import_text** can import their respective formats.

### custom modules

To add a custom module in your formula, just create a `_modules` directory at its root, store your python code inside it and call it from your templates like this


    {{ salt['custom_module_name.function_name'](args...) }}

### tcp cloud Formulas

tcp cloud is a company, acquired by Mirantis, which is specialized in deploying OpenStack and OpenContrail using Salt. They've built [Formulas](https://github.com/tcpcloud/?utf8=%E2%9C%93&query=formula) for all the required components like keystone, horizon, cinder, nova, etc..

On top of what has been said about formula conventions let see their [guidelines](http://www.opentcpcloud.org/en/documentation/salt-formulae-guidelines).

#### directory structure

The directory structure looks pretty much the same as the one we've described in the introduction with the following added stuff

    foo-formula
    ├── _grains/
    |   └── service.yml
    ├── _modules/
    |   └── service.yml
    ├── _states/
    |   └── service.yml
    ├── debian/
    |   ├── changelog
    |   ├── compat
    |   ├── control
    |   ├── copyright
    |   ├── docs
    |   ├── install
    |   ├── rules
    |   └── source
    |       └── format
    ├── doc/
    ├── foo/
    |   └── files/
    |       ├── config1.yml
    |       └── config2.yml
    |   ├── init.sls
    |   └── meta/
    |       ├── collectd.sls
    |       ├── heka.sls
    |       ├── iptables.sls
    |       ├── sensu.sls
    |       └── iptables.sls
    |   └── orchestrate/
    |       ├── init.sls
    |       ├── role1.sls
    |       └── role2.sls
    |   ├── _common.sls
    |   ├── role1.sls
    |   └── role2/
    |       ├── init.sls
    |       ├── service.sls
    |       └── more.sls
    ├── metadata/
    |   └── service/
    |       ├── role1/
    |       |   ├── deployment1.yml
    |       |   └── deployment2.yml
    |       └── role2/
    |           └── deployment3.yml
    ├── test/
    ├── Makefile
    └── metadata.yml

`_grains` optional grain modules  
`_modules` optional execution modules  
`_states` optional states modules  
`debian` APT package metadata  
`foo/files/` configuration files  
`foo/init.sls` allows the node catalog to be role agnostic by including roles when corresponding pillar.service.role[1|2] is defined  
`foo/meta/` declaration to support log, metric gathering, monitoring, firewalling, and documentation  
`foo/orchestrate/` information to orchestrate the deployment  
`foo/role1.sls` actual salt state resources that enforce service existence by installing pkg, configuring and starting it.  
`foo/role2/init.sls` used with more complex roles, uses further conditions to limit the inclusion of unecessary stuff.  
`foo/role2/service.sls` where oackage gets installed, configured and started for role2  
`metadata/service` reclass metadata  
`test` currently only syntax checking  
`metadata.yml` formula description, version and repository  

#### services and roles

On a minion you can check *services* and *roles*

    salt-call grains.item services
    salt-call grains.item roles

#### reclass metadata files

Each of the files stored under `metadata/service` serve as default reclass metadata for a given deployment.

Each role can have several deployments:

* `metadata/service/server/local.yaml`
* `metadata/service/server/single.yaml`
* `metadata/service/server/cluster.yaml`

You can use parameters like `${_param:cluster_node01_hostname}` which will be interpolated at reclass merge time from the node declaration.

### Testing

Testing your formula is crucial to insure it will work in different environments, but it could be tedious to provision so many operating system, install Salt, converge the States, run some tests and report the results. But don't freak out, it's possible to automate this workflow to insure tests are run easily and frequently.

Sometime it's fair to recognize when other do things right, when it comes to Formula testing, [test-kitchen](http://kitchen.ci/docs/getting-started/), an awesome tool by Fletcher Nichol,  from the Chef ecosystem seems to be the de-facto standard.

A provisionner, [kitchen-salt](https://github.com/simonmcc/kitchen-salt/blob/master/INTRODUCTION.md) has been created for Salt.

Lets use Test Kitchen to perform a suite of tests against a State by converging on a VM automatically provisionned by Vagrant.

#### Installation

To use this tool, you'll need

* Salt
* Ruby 2.0+
* Git
* Vagrant
* VirtualBox or VMware workstation/Fusion (but with a non free driver for Vagrant)
* test-kitchen-1.2.1
* kitchen-vagrant - test Kitchen Driver for Vagrant.

Install [Vagrant](https://www.vagrantup.com/downloads.html) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads) or VMware Fusion/Workstation

In my case I'll be using VMware Fusion as the backend for Vagrant using the following command to install the driver

    $ vagrant plugin install vagrant-vmware-fusion
    Installing the 'vagrant-vmware-fusion' plugin. This can take a few minutes...
    Installed the plugin 'vagrant-vmware-fusion (4.0.12)'!

It's been a while seen I've touched a license file, the driver isn't free so here is the license step, download your license and

    $ vagrant plugin license vagrant-vmware-fusion ~/Downloads/license.lic
    Installing license for 'vagrant-vmware-fusion'...
    The license for 'vagrant-vmware-fusion' was successfully installed!

Verify your installation

    $ vagrant plugin list

Try to launch a Vagrant box to see if everything works as expected

    $ vagrant init bento/ubuntu-16.04
 
I had to add the following line in my Vagrantfile to avoid a problem with the bento kernel

    config.vm.synced_folder ".", "/vagrant", disabled: true

Provision a VM to see if Vagrant works well

    $ vagrant up

After a while you should have a new VM running Ubuntu 16.04

Install Salt, on MacOS X used in our example just run, or consult [About SaltStack](/2016/09/salt/) for other OS.
    
    $ sudo pip install salt

Now create the following `Gemfile`
    
    source 'https://rubygems.org'
    gem "test-kitchen", '>=1.2.1'
    gem "kitchen-vagrant"
    gem "kitchen-salt", ">=0.0.11"

Install all the dependencies with bundle
    
    $ bundle install
    Installing artifactory 2.5.0
    Installing mixlib-shellout 2.2.7
    Installing mixlib-versioning 1.1.0
    Installing net-ssh 3.2.0
    Installing safe_yaml 1.0.4
    Installing thor 0.19.1
    Using bundler 1.13.1
    Installing mixlib-install 2.0.1
    Installing net-scp 1.2.1
    Installing net-ssh-gateway 1.2.0
    Installing test-kitchen 1.13.2
    Installing kitchen-salt 0.0.24
    Installing kitchen-vagrant 0.20.0
    Bundle complete! 3 Gemfile dependencies, 13 gems now installed.
    Use `bundle show [gemname]` to see where a bundled gem is installed.

Check if test-kitchen it works

    $ kitchen help
    kitchen console                                 # Kitchen Console!
    kitchen converge [INSTANCE|REGEXP|all]          # Change instance state to converge. Use a provisioner to configure one or more instances
    kitchen create [INSTANCE|REGEXP|all]            # Change instance state to create. Start one or more instances
    kitchen destroy [INSTANCE|REGEXP|all]           # Change instance state to destroy. Delete all information for one or more instances
    kitchen diagnose [INSTANCE|REGEXP|all]          # Show computed diagnostic configuration
    kitchen driver                                  # Driver subcommands
    kitchen driver create [NAME]                    # Create a new Kitchen Driver gem project
    kitchen driver discover                         # Discover Test Kitchen drivers published on RubyGems
    kitchen driver help [COMMAND]                   # Describe subcommands or one specific subcommand
    kitchen exec INSTANCE|REGEXP -c REMOTE_COMMAND  # Execute command on one or more instance
    kitchen help [COMMAND]                          # Describe available commands or one specific command
    kitchen init                                    # Adds some configuration to your cookbook so Kitchen can rock
    kitchen list [INSTANCE|REGEXP|all]              # Lists one or more instances
    kitchen login INSTANCE|REGEXP                   # Log in to one instance
    kitchen package INSTANCE|REGEXP                 # package an instance
    kitchen setup [INSTANCE|REGEXP|all]             # Change instance state to setup. Prepare to run automated tests. Install busser and r...
    kitchen test [INSTANCE|REGEXP|all]              # Test (destroy, create, converge, setup, verify and destroy) one or more instances
    kitchen verify [INSTANCE|REGEXP|all]            # Change instance state to verify. Run automated tests on one or more instances
    kitchen version                                 # Print Kitchen's version information

#### .kitchen.yml

Test Kitchen keeps it's main configuration in `.kitchen.yml`, it's used to tell which platform you want to test, it's a simple YAML file stored at the root of your formula. To quickly show you how to run tests on a formula lets clone one which already contain such a configuration file in our formula directory

    $ cd /srv/formulas
    $ git clone https://github.com/planetrobbie/influxdb-formula.git
    Cloning into 'influxdb-formula'...
    remote: Counting objects: 495, done.
    remote: Total 495 (delta 0), reused 0 (delta 0), pack-reused 495
    Receiving objects: 100% (495/495), 72.03 KiB | 0 bytes/s, done.
    Resolving deltas: 100% (283/283), done.
    Checking connectivity... done.

Configure the master configuration, `/etc/salt/master` to add your formula directory

    file_roots:
      base:
        - /srv/formulas/influxdb-formula

Test Kitchen configuration file contain

    #!yaml
    driver:
      name: vagrant
      provider: vmware_fusion
      network:
        - ["private_network", { ip: "192.168.33.33" }]
    
    provisioner:
      name: salt_solo
      formula: influxdb
      pillars-from-files:
        influxdb.sls: pillar.example
      pillars:
        top.sls:
          base:
            "*":
              - influxdb
      state_top:
        base:
          "*":
            - influxdb
            - influxdb.cli
    
    platforms:
      - name: ubuntu-16.04
    
    suites:
      - name: default

`driver` tells Test Kitchen what to use to create the test VM, in this section I've added the **provider: vmware_fusion** or by default Virtual Box is used.  
`provisioner`  details about the provisioner to be used, kitchen-salt gem provides a Test Kitchen provisioner called salt_solo  
`pillars-from-file` which Pillar data to assign to our minion  
`platforms` different guest operating systems we'll test against  
`suites` collection of attributes & tests to be run in conjunction. By default Test Kitchen store its tests below `test/integration`.  

To get what exactly get tested, look inside `test/integration/default/serverspec`, it contains a description which use the [serverspec](http://serverspec.org/) testing framework

    require "serverspec"

    +set :backend, :exec
    
    describe service("influxdb") do
      it { should be_enabled }
      it { should be_running }
    end
    
    +influxdb_ports = [8083, 8086, 8088]
    for influxdb_port in influxdb_ports do
      describe port(influxdb_port) do
        it { should be_listening }
      end
    end

Ready to run the test
        
    $ kitchen test

Test Kitchen will then create an environment to execute our formula in, **kitchen-salt** will make sure Salt is installed in our VM. Then **salt-call** will be executed and report its end status. 

At the end of the salt-call execution, if everything ran successfully you should see

    Service "influxdb"
      should be enabled
      should be running
       
      Port "8083"
        should be listening
       
      Port "8086"
        should be listening
       
      Port "8088"
        should be listening
       
    Finished in 0.37356 seconds (files took 0.34517 seconds to load)
    5 examples, 0 failures
       
    Finished verifying <default-ubuntu-1604> (5m25.64s).
    -----> Destroying <default-ubuntu-1604>...
    ==> default: Stopping the VMware VM...
    ==> default: Deleting the VM...
    Vagrant instance <default-ubuntu-1604> destroyed.
    Finished destroying <default-ubuntu-1604> (0m7.45s).
    Finished testing <default-ubuntu-1604> (11m32.35s).

If you got a bad red message, you can converge again with

    $ kitchen converge

or if convergence were successfull, just run the verification again with

    $ kitchen verify

Wow, now you have a great testing framework in place :)

### Conclusion

Formulas are the evolution of Salt States and bring modularity, reusability. Formulas are easy to hand off and you'll have fewer files to manage. States can become complex by themselves and can become messy if you don't pay attention. Breaking things up is a good practice for readability sake.

As we've seen, the next Salt release, Carbon, wil bring globbing capabilities for the dictionary keys and multiple grain matching. The **base** argument of the **filter_by** function exist now for while, to more easily merge config related stuff and os dependant information. Lets hope formula conventions and repositories will evolve to benefit from all of this.

A last word, each formula is third-party code running as root on your systems, so you need to be careful to read and understand every formula before applying them to your minions.

### Links
* Salt Formulas on [github](https://github.com/saltstack-formulas)
* tcp cloud Salt Formulas [Guidelines](http://www.opentcpcloud.org/en/documentation/salt-formulae-guidelines/#service-map-jinja)
* oopss-salt [formulas](https://github.com/oopss/oopss-salt)
* [Vagrant](https://www.vagrantup.com/)
* [Test Kitchen](http://kitchen.ci/)
* [kitchen-salt](https://github.com/simonmcc/kitchen-salt)

### Video
* Salt Conf 14 [Salt Formulas and States](http://www.slideshare.net/SaltStack/forrest-alvarez-salt-formulas-and-states-salt-conf-32725456) - talk by Forrest Alvarez

### Documentation
* Salt Formulas [documention](https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html)
* [Understanding Jinja](https://docs.saltstack.com/en/latest/topics/jinja/)
* Salt [improving](http://www.tmartin.io/articles/2014/salt-improving-jinja-usage) Jinja usage
* Installing [Test Kitchen](http://kitchen.ci/docs/getting-started/installing)
* serverspec [resource types](http://serverspec.org/resource_types.html)

[saltformulas-sucrose]: /images/posts/saltformulas-sucrose.png width=200px
[saltformulas-xxx]: /images/posts/saltformulas-xxx.png width=120px