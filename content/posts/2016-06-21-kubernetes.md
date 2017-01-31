---
title: "About Kubernetes"
created_at: 2016-06-21 19:00:00 +0100
kind: article
published: true
tags: ['howto', 'containers', 'kubernetes']
---

For years Google is driving its infrastructure using containers with a system named *Borg*, they are now sharing their expertise with an Open Source container cluster manager named *Kubernetes* (or helmsmen in ancient greek) abreviated k8s. Briefly said **Kubernetes is a framework for building distributed systems**.

Release 1.0 went public in July 2015 and Google created at the same time, in partnership with the Linux Foundation, the *[Cloud Native Computing Foundation (CNCF)](https://cncf.io/)*.

If you want to know more, read on.

<!-- more -->

![][k8s-logo]

### A bit of reading first

The objective of Kubernetes is to abstract away the complexity of managing a fleet of containers. By interacting with a RESTful API, you can describe the desired state of your application and k8s will do whatever necessary to converge the infrastructure to it. It will deploy groups of containers, replicate enough of them, redeploying if some of them fails, etc...

By its open source nature, it can run almost anywhere, public cloud providers all provide easy ways to consume this technology, private clouds based on OpenStack or Mesos can also run k8s, bare metal servers can be leveraged as worker nodes for it. So if you describe your application with k8s building blocks, you'll then be able to deploy it within VMs, bare metal server, public or private clouds.

Kubernetes architecture is relatively simple, you never interact directly with the nodes that are hosting your application, but only with the control plane which present an API and is in charge of scheduling and replicating groups of containers named Pods. *Kubectl* is the command line interface you can use to interact with the API to share the desired application state but also gather detailed information on the current state.

#### Nodes

Each node that are hosting part of your distributed application do so by leveraging [Docker](https://www.docker.com) or a similar container technology like Rocket from [CoreOS](https://coreos.com/) which by the way offer a supported version of Kubernetes. They also run two additional piece of software, [kube-proxy](http://kubernetes.io/docs/admin/kube-proxy/) which give access to your running app and [kubelet](http://kubernetes.io/docs/admin/kubelet/) which receive commands from the k8s control plane. They can also run [flannel](https://coreos.com/flannel/docs/latest/), an etcd backed network fabric for containers.

#### Master

The control plane itself runs the API server ([kube-apiserver](http://kubernetes.io/docs/admin/kube-apiserver/)), the scheduler ([kube-scheduler](http://kubernetes.io/docs/admin/kube-scheduler/)), the controller manager ([kube-controller-manager](http://kubernetes.io/docs/admin/kube-controller-manager/)) and [etcd](https://coreos.com/etcd/docs/latest/) a highly available key-value store for shared configuration and service discovery implementing the [Raft](http://thenewstack.io/about-etcd-the-distributed-key-value-store-used-for-kubernetes-googles-cluster-container-manager/) consensus Algorithm.

![][k8s-arch]

### Terminology

**[Pods](http://kubernetes.io/docs/user-guide/pods)** - group of one of more containers, shared storage and options about how to run them. One IP per pod gets assigned.  
**[Labels](http://kubernetes.io/docs/user-guide/labels)** - key/value pairs that are attached to any objects, such as pods, Replication Controllers, Endpoints, etc..  
**[Annotations](http://kubernetes.io/docs/user-guide/annotations)** - key/value pairs to store arbitrary non-queryable metadata.  
**[Services](http://kubernetes.io/docs/user-guide/services)** - an abstraction which defines a logical set of Pods and a policy by which to access them  
**[Replication Controller](http://kubernetes.io/docs/user-guide/replication-controller)** - ensures that a specific number of pod replicas are running at any one time.  
**[Secrets](http://kubernetes.io/docs/user-guide/secrets)** - hold sensitive information, such as passwords, TLS certificates, OAuth tokens, and ssh keys.  
**[ConfigMap](http://kubernetes.io/docs/user-guide/configmap)** - mechanisms to inject containers with configuration data while keeping containers agnostic of Kubernetes.

### Why Kubernetes

In order to justify the added complexity that Kubernetes brings, their need to be some benefits. At its core a cluster manager like k8s exist to serve developpers, so if they can serve themselves without having to refer to the operation team it will create a new experience for developpers. But that kind of developper **Self Service** may not be what your organisation wants.

**Reliability** is a big part of the benefits of Kubernetes, Google have over 10 years of experience when it comes to infrastructure operations with Borg their internal container orchestration solution and they've built k8s based on this experience. Kubernetes can be used to make failure not impact the availability or performance of your application, that's a great benefit.

**Scalability** is handled by Kubernetes on different levels, you can add cluster capacity by adding more workers nodes, this can even be automated in public cloud with autoscaling fonctionnality on CPU and Memory triggers. Kubernetes Scheduler feature affinity features to spread your workloads evenly across the infrastructure, maximizing the availability. Finally k8s can autoscale your application using the Pod autoscaller which can be driven by customs triggers.

But all of this needs to be proven to be commonly accepted, while setting up a cluster for a proof of concept it's really important to precisely define the acceptance criteria, with very specific expectations.

### Pod Patterns

When we think about how to best build a Pod, different [patterns](http://blog.kubernetes.io/2015/06/the-distributed-system-toolkit-patterns.html) emerge, for example

* **sidecar** containers - extend and enhance the main container
* **ambassador** containers - offer a local proxy to the world, connection can then be opened on localhost because containers within the same Pod share the same IP.
* **adapter** containers - standardize/normalize output

Breaking out your application stack in smaller components will require careful thinking, but the way you can try, fail fast on such a dynamic k8s system, will help you find the best architecture by trial and error.

You'll then be able to bundle your application using the [Helm Package Manager](https://helm.sh/) which is an interesting work in progress from the [Deis](http://deis.io/) team.

### Kubernetes 1.2

If you are curious to catch-up with the latest and greatest Kubernetes features, here is a quick reminder of what has been added in this release:

* Improved [Performance and Scalability](http://blog.kubernetes.io/2016/03/1000-nodes-and-beyond-updates-to-Kubernetes-performance-and-scalability-in-12.html) - Kubernetes now supports 1000-node clusters and up to 30.000 Pods, over 10 millions requests/seconds. 99% of API calls return in < 1 second, 99% Pods starts in < 5 seconds. Pure iptables kube-proxy (no CPU, throughput or latency impact).
* [Deployment](http://blog.kubernetes.io/2016/04/using-deployment-objects-with.html) - to easily achieve [rolling updates](http://kubernetes.io/docs/user-guide/rolling-updates/) with zero downtime
* [Horizontal Pod AutoScaler (HPA)](http://kubernetes.io/docs/user-guide/horizontal-pod-autoscaling/) - scale the number of pods to a target metric (cpu utilization, custom metrics still alpha in 1.2)
* [Auto provisionning of persistent volume (PersistentVolumeClaim)](http://kubernetes.io/docs/user-guide/persistent-volumes/) - require a supported cloud GCE, AWS or OpenStack
* [Multi Zone Clusters](http://blog.kubernetes.io/2016/03/building-highly-available-applications-using-Kubernetes-new-multi-zone-clusters-a.k.a-Ubernetes-Lite.html) - Zone fault tolerance for your application, also called Ubernetes Light, will be expanded to full Federation in future releases to combine separate Kubernetes clusters running in different regions or clouds. For now a single cluster can have its worker nodes in different zones.
* [Ingress](http://blog.kubernetes.io/2016/03/Kubernetes-1.2-and-simplifying-advanced-networking-with-Ingress.html) - L7 Load Balancing (beta) with SSL support, works today with GCE, AWS, HAproxy, nginx. Maps incoming traffic to services based on Host Headers, URL Paths, ... It allows to build the same automation for on premise and off premise, same Load Balancing API everywhere but different implementation, abstracted away.
* [Secrets]() - manage secrets using the same API and kubectl CLI, injected as virtual volume into pods, never touch disks (tmpfs in memory storage). Accessed as files or environment variables from your application.

For more details on all of this, consult this [series of in-depth](http://blog.kubernetes.io/2016/03/five-days-of-kubernetes-12.html) posts or look at the stream of [CHANGELOG](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG.md/).

As a quick reminder, k8s v1.1 introduced previously added

* HTTP Load Balancing [beta]
* Autoscaling [beta]
* Batch Jobs
* Resource Overcommit
* IP Table based kube-proxy
* new kubectl [tools](http://blog.kubernetes.io/2015/10/some-things-you-didnt-know-about-kubectl_28.html) - run interactive commands, view logs, attack to containers, port-forward, exec commands, labels/annotation management, manage multiple clusters.
* and many more improvements

### What's left to address

Kubernetes is not the end game, developpers are not used to Pods, Replication Controllers and so on, so we need to expose something more familiar to them. We really shouldn't ask them to change radically their workflow, they like their git push, so instead the technology should be almost transparent to them. Platform as a Service solution that co-exist with k8s could help in that respect.

For example [Deis Workflow](https://github.com/deis/workflow), built upon kubernetes, CoreOS and Docker, delivered as a set of k8s microservices, makes it simple for developers to deploy their application. Redhat also offer, OpenShift, a PaaS on top of Kubernetes.

Service Discovery could be a DNS service like [Consul](https://www.consul.io/), an external registry like [ZooKeeper](https://zookeeper.apache.org/) or Environment variable injected at bootstrapping time. Kubernetes provide a cluster DNS addon which is using [skydns](https://github.com/skynetservices/skydns) built on top of etcd and [kube2sky]() which talk to the k8s API to provide DNS resolution for containers.

As it stands today Kubernetes doesn't do edge routing well enough, when it comes to on-premise deployment. Addressing edge routing is essential for the end to end success of hosting your application within a k8s cluster. Ingress are an interesting added feature of k8s v1.2 that need to mature, with a broad ecosystem of Load Balancers, to deliver a robust traffic routing solution for your datacenter.

Manifest Management could be managed in version control but this is something new and needs to be handled with care.

Once you have everything above in place and when your Continuous Integration workflow is humming, you need to monitor all of it carrefully, solutions like [Prometheus](https://prometheus.io/) which is now part of the [Cloud Native Computing Foundation](https://cncf.io) could be interesting to look at. Another common alternative is the following triplet [cadvisor](https://github.com/google/cadvisor) resource usage and performance characteristics of your running containers + [influxdb](https://github.com/influxdata/influxdb) time series database + [heapster](https://github.com/kubernetes/heapster) Compute Resource Usage Analysis and Monitoring of Container Clusters.

For logging you could leverage [fluentd](http://www.fluentd.org/) open source data collector + [elasticsearch](https://www.elastic.co/) full text search engine + [kibana](https://www.elastic.co/products/kibana) dashboard.

When going to productions more questions arise, what's the best architecture for your cluster ? how to setup High Availability ? how to test for failures ? how fast can you redeploy your cluster ? how will you be upgrading it without affecting the running applications ? What about the security of the overall system ?

Last one, how will you be addressing Disaster recovery ? Kubernetes self healing internal mechanism won't be enough when catastrophic failures happens. Sometimes you'll have to spin up a new cluster from scratch, you'll need to restore a backup of your cluster configuration to get your application running again. How will you recover application data ?

### Conclusion

Kubernetes is a great container orchestration solution but this technology doesn't apply everywhere. Most legacy application like Oracle or SAP won't really benefit from it. You really have to select workloads carrefully. Web applications that relies on replicated datastores could be could candidates for example

Don't make the mistake of overselling it, let the traditionnal IT stuff run untouched, but create a bridge between the different worlds. For example Service Discovery can be leveraged by an application running on k8s to get connection information to an Oracle Database, that's totally fine.

If you think you can benefit from it, make sure to share and explain the reasons and promote it within your organisation. Sponsorship is key not to see your initiative dying after a while, adoption by a broad set of people is key for its survival. 

The world of Kubernetes is moving fast, if you want to get regular updates, read the [KubeWeekly](https://kubeweekly.com/) newsletter.

Thanks for reading to that end and I wish you good luck with your containers !

### Kubernetes Links
* [Kubernetes.io](http://kubernetes.io/)
* [Kubernetes Getting Started Guides](http://kubernetes.io/docs/getting-started-guides/)
* [Kubernetes source code](http://github.com/kubernetes/kubernetes)
* [Kubernetes slack channel](http://slack.k8s.io)
* [Kubernetes twitter](https://twitter.com/kubernetesio)

### Other links
* [CoreOS](https://coreos.com/) - open-source lightweight operating system based on the Linux kernel
* [Docker](https://docs.docker.com) - open platform for developers and sysadmins to build, ship, and run distributed applications
* [Calico](https://www.projectcalico.org/) - A Pure Layer 3 Approach to Virtual Networking
* [Tigera](https://www.tigera.io/) - Calico and Flannel networking united
* [Deis](https://deis.com/) - open source PaaS built on top of k8s
* [Tectonic](https://tectonic.com/) - CoreOS supported version of k8s
* [Kubespray](https://github.com/kubespray/kargo) - Deploy a production ready kubernetes cluster with Ansible
* [Cloud Native Computing Foundation](https://cncf.io) - facilitate collaboration among developers and operators on common technologies for deploying cloud native applications and services
* [Open Container Initiative](https://www.opencontainers.org) - lightweight, open governance structure to create open industry standards around container formats and runtime
* [Raft](https://raft.github.io/) - Consensus Algorithm

### Blogs
* [Official blog](http://blog.kubernetes.io/)
* [KubeWeekly](https://kubeweekly.com/)
* [CoreKube](https://corekube.com/posts/)
* [Kunernetes networking 101](http://www.dasblinkenlichten.com/kubernetes-101-networking/) - internal communication
* [Kubernetes networking 101](http://www.dasblinkenlichten.com/kubernetes-101-external-access-into-the-cluster) - external access to the cluster

### Books
* [Kubernetes: Up and Running](http://shop.oreilly.com/product/0636920043874.do) - to be published in Aug'16

### Online Trainings
* [The illustrated Children's Guide to Kubernetes](https://deis.com/blog/2016/kubernetes-illustrated-guide/)
* [Hello World Walkthrough](http://kubernetes.io/docs/hellonode/)
* [Kubernetes Examples](https://github.com/kubernetes/kubernetes/tree/release-1.2/examples)
* Free Udacity [Scalable Microservices with Kubernetes](https://www.udacity.com/course/scalable-microservices-with-kubernetes--ud615)
* Kubernetes [from the ground up](https://rocketeer.be/blog/2015/11/kubernetes-from-the-ground-up/)
* About [etcd and Raft consensus](http://thenewstack.io/about-etcd-the-distributed-key-value-store-used-for-kubernetes-googles-cluster-container-manager/) Protocol
* Raft protocol explained [step by step](http://thesecretlivesofdata.com/raft/)

### Online Docs
* [Kubernetes](http://kubernetes.io/docs/)
* [Kubernetes Cheatsheet](http://k8s.info/cs.html)
* [Kubernetes Debugging FAQ](https://github.com/kubernetes/kubernetes/wiki/Debugging-FAQ)
* [etcd](https://coreos.com/etcd/docs/latest/) - distributed key/value store
* [flannel](https://coreos.com/flannel/docs/latest/) - Overlay Networking
* [Helm](https://github.com/kubernetes/helm/tree/master/docs) - The Kubernetes [Package Manager](https://helm.sh) contributed by Deis team.
* [CNI](https://github.com/containernetworking/cni) - Container Network Interface

### Events
* [Docker and Kubernetes Bootcamp by Mirantis](https://training.mirantis.com/docker-kubernetes-bootcamp) - august 9-10, 2016
* [Kubecon](http://events.linuxfoundation.org/events/kubecon) - november 8-9, 2016

[k8s-logo]: /images/posts/k8s-logo.png
[k8s-arch]: /images/posts/k8s-arch.png
