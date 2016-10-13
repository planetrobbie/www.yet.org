---
title: "Electric Cloud and Opscode Chef: The PB&J of DevOps Webminar"
created_at: 2012-11-29 20:01:00 +0100
kind: article
published: true
tags: ['automation', 'chef', 'devops', 'webinar']
---

Today's enterprises are adopting methodologies like *DevOps* and *Continuous Delivery* to rapidly deliver applications to customers. Continuously building, testing and releasing applications improves the quality of the applications by providing fast user feedback to development teams; rapid release cycles also ensure tighter collaboration between Dev and Ops teams.

<!-- more -->

![][electric_cloud_chef-06]

In this webinar we will learn how the integrated Opscode Chef and Electric Cloud solution automates the end-to-end application delivery process to:

* Provision and configure environments in a consistent manner
* Model and deploy multi-tier applications in a fail-safe way
* Manage the overall release process from Dev to Production

Only through an integrated automation of infrastructure, application and release process, can IT organizations deliver applications quickly, with minimal errors and complete transparency.

### Presenters

* *George Moberly* - VP Products at *OPScode*
* *Kalyan Ramanathan* - VP Marketing at *Electric Cloud*

### Introduction

*Devops* is a way to deliver application faster with better quality, let's see how we can manage the overall infrastructure using this methodology.

Applications drive most of enterprises today, drive products, revenue and create differentiation. But delivering applications isn't an obvious task.

Typical Software delivery process involves the following steps: dev, qa, release, ops. It is complex and involve many components, dependencies and tools: releasing, testing, ... 

Workflow from dev to ops requires to go to many stages. Agile methodology is adding more tension, release cycles is evolving from month to days. We are now expecting *Continuous Delivery*.

All this requires a lot of infrastructure. Example Tasks :

* provision base OS
* configure OS, package patches
* install middleware
* configure middleware
* deploy multi-tier application
* configure multi-tier application
* configure test
* run and analyse test

Done again and again, throughout the release process. So how to manage it ?. What version are moving thru the release process ? What environnements, what is the status ? Many challenges as you start to manage the release process. What is needed to address thoses challenges :

1. You need to **automate your infrastructure**, it is complex so you need the ability to automate it.
2. **Automate the deployment** process, to deploy consistently.
3. **Manage the release process**, thru the various stages.

The integration between *Electric Cloud* and *Opscode Chef* provides a global solution to automate your infrastructure, with application deployment as well as the release process with Electric Cloud solution.

### *Opscode*

![][electric_cloud_chef-01]

#### What is *Chef* ?

Opscode founded september 2008, $33m from *DFJ, Battery, Ignition* based in Seattle, WA. 75+ Employees.

Chef is an automation platform for developers & systems engineers to continuously define, build & manage infrastructure.

Chef uses: *Recipes* and *Cookbooks* that describe Infrastructure as Code.

Chef enables people to easily build & manage complex & dynamic application infrastructure at massive scale.

* New model for describing infrastructure that promotes reuse
* Programmatically provision and configure
* Reconstruct business from code repository, data backup and bare metal resources.

#### High level overview of *Opscode Chef*

![][electric_cloud_chef-02]

A large number of knife plugin used to provision new infrastucture, declare resources needed. You'll then model your components on top of a thin Instance. The bootstrap process will put a chef-client on the node, the node will then download the policies which will get processed locally.

In our example above, ntp and openssh recipes are re-used between different nodes.

There is a huge library of *Cookbooks* available at [Opscode community](http://community.opscode.code). They also provide support as *Hosted Chef*, free for up to 5 nodes. *Private Chef* is the same technology available behind the firewall.


![][electric_cloud_chef-03]

#### Electric Cloud overview

Silicon based started since 2005, 100+ employees. Strong suite of customers.

![][electric_cloud_chef-05]


Two solutions:

**Electric Deploy**, focused on automatic application deployement

You get the ability to model the application, the various tiers, web, db tiers. Model the environment as well as the configuration of the environement. Workflow model defines where and how it will get deployed. This is how we can reach out to a solution like Chef, not only to setup but also to configure the infrastructure.

Also manage the deployment in a **fail safe** way :

* Code-safe, iteratively debug deploy process
* Run-safe, model failure and success thresholds
* Recover-safe, retry and recovery policies, managing partial failures.

**Electric Commander**, manages the full release cycle. Orchestrate Build-Test-Run process.

Provides a very flexible workflow technology. Chef can be called upon. Electric Commander runs the workflow in a predictive way, provides real time visibility into the various tools and process, you know where you are in the release process.

The combinaison of all the parts makes DevOps possible.

![][electric_cloud_chef-04]

### Demo

![][electric_cloud_chef-07]

They shown a live demo demonstrating a use case, it is based on a Java PetStore. It is using app/web/db servers. Release process starts out from a version control system, it will transition to a test environment, and then moving to staging before switching to production.

Below you'll see the modeled release process. Every box represents tasks or tools.

![][electric_cloud_chef-08]


Once the workflow has been modeled, you'll be able to easily deploy your application with necessary approval when moving from stage to stage.

So imagine you've got a new code for Java PetStore. Assume we have already built/tested the application, it will get promoted to end users.

![][electric_cloud_chef-09]

Red circles above indicates what we need to do at the infrastructure level, Chef will do this job.

A plugin technology is used to integrate with Chef. It creates a knife script which will then do the appropriate action within the Chef solution.

![][electric_cloud_chef-10]

Two distincs steps in red. Basically creating the bottow half of the infrastructure.

![][electric_cloud_chef-11]

This is the node before any customization. It has the base role. A tons of attributes are self discovered.

![][electric_cloud_chef-12]

You see above, we are adding new roles to our node: base and tomcat. The nodes will converge to the correct set of policies at the end of chef-client runs.

![][electric_cloud_chef-13]

As you see in the red circle, the node is now a tomcat server. By the way, you have a google for your infrastructure, one of the most powerfull feature of Chef. You'll be able to search for tomcat servers, load balancers and even include search results in your infrastructure description to easilly manage inter-dependencies.

![][electric_cloud_chef-14]

Infrastructure deployment is now done. Electric Cloud can take over from here. They have to extract the war and to configure the application.

![][electric_cloud_chef-15]

The application is now updated with Kangaroos.

![][electric_cloud_chef-16]

So you've seen the ability to do deployment in a really automated way, for the infrastructure and the code. You'll get trend data about how those deployment are performing. It provides full visibility about the deployment pipeline.

### Joint Solution Benefits

* Consistent full stack deployments
* Orchestrated complex multi-tier deployments
* Release pipeline visibility & management
* End to end application auditability
* Application & environment centric reporting.

### Q&A

#### Operating system limitation with Chef ?

Support for the agent on pretty much any OS: Solaris, Windows, Linux,... Customers in production doing windows management with Opscode Chef.

#### How many recipes comes out of the box with Chef ?

All the content is Apache 2.0 licensed, you are free to keep your changes. It is close to 900 cookbooks already available and indexed, some additional content are available but not currently indexed by Opscode.

#### How Electric Cloud manage testing and packaging

*Electric Commander* manages the release process, over 200 integration with many of the tools : SCM, Build systems, Test systems, ... You can pretty much take any integration plugin to adapt to your needs.

#### Electric Cloud integrates with EC2, VMware so why to I need Chef ?

It is a basic integration, Chef represents a layer of sophistication, Chef is really good at promoting infrastructure as code, to consistently configure the infrastructure. There is a lot of value there to insure the infrastructure conigurration is done well.

#### Hardware OS, DB ? What do they support ?

Chef is pre-built for many things but not 100% coverage. Basically if you can automate something with an API you can turn into a cookbook. A lot node.js, rails, emerging technologies are pretty well supported, maybe less support for legacy stuff.

Electric Cloud WebSphere, WebLogic, Oracle etc, ... no complete coverage, a lot of components constantly added.

#### Microsoft ?

Partnership with *Azure* to bring Linux and *IaaS* capabilities to Azure. There is a Cloud plugin for Azure. Electric Cloud is currently engaged in expanding that and identifying new use cases.

#### About Nexus and Artifact repository

Artifact repositoty like Nexus can interact with Electric Cloud.

#### Differences between Chef Open Source and paid version

The messaging will be clarified. The content will be published soon on Opscode site. Ask info@opscode.com if you need it right now.

### Contacts

* *[Opscode](http://www.opscode.com)* info@opscode.com, twitter: @opscode
* *[Electric Cloud](http://www.electric-cloud.com)* chef@electric-cloud.com, twitter: @electric-cloud.com

### Links

* Webinar [recording](http://www.electric-cloud.com/resources/webinars.php?commid=59781)

[electric_cloud_chef-01]: /images/posts/electric_cloud_chef-01.png width=700px
[electric_cloud_chef-02]: /images/posts/electric_cloud_chef-02.png width=700px
[electric_cloud_chef-03]: /images/posts/electric_cloud_chef-03.png width=800px
[electric_cloud_chef-04]: /images/posts/electric_cloud_chef-04.png width=700px
[electric_cloud_chef-05]: /images/posts/electric_cloud_chef-05.png width=700px
[electric_cloud_chef-06]: /images/posts/electric_cloud_chef-06.png width=400px
[electric_cloud_chef-07]: /images/posts/electric_cloud_chef-07.png width=600px
[electric_cloud_chef-08]: /images/posts/electric_cloud_chef-08.png width=700px
[electric_cloud_chef-09]: /images/posts/electric_cloud_chef-09.png width=700px
[electric_cloud_chef-10]: /images/posts/electric_cloud_chef-10.png width=700px
[electric_cloud_chef-11]: /images/posts/electric_cloud_chef-11.png width=700px
[electric_cloud_chef-12]: /images/posts/electric_cloud_chef-12.png width=700px
[electric_cloud_chef-13]: /images/posts/electric_cloud_chef-13.png width=700px
[electric_cloud_chef-14]: /images/posts/electric_cloud_chef-14.png width=700px
[electric_cloud_chef-15]: /images/posts/electric_cloud_chef-15.png width=700px
[electric_cloud_chef-16]: /images/posts/electric_cloud_chef-16.png width=700px