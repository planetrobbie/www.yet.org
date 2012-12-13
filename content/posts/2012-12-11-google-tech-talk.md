---
title: "Google Tech Talk - Testing at Google"
created_at: 2012-12-11 18:07:00 +0100
kind: article
published: true
tags: ['conference', 'testing', 'dev']
---

*Google* regularly invites students and professional to Tech Talk sessions, this time I was invited in their Paris office for a talk about Testing at *Google*. This is one of the first Tech Talk organized in Paris.

<!-- more -->

### Introduction

*Vincent*, our host, is in charge of testing You Tube search and discovery infrastructure.

Opened in 2011, more than 80 engineers from then 20 countries are currently working at *Google Paris*. Around 500 persons works globally in France. The team isn't dedicated to the french market, but targeted to all countries in the world. I'm glad to hear that.

![][googletalk]

#### Here are the five areas of focus in Paris:

* ***Chrome***: mobile version, iOS and Android.
* ***Cultural Institute***: still construction work happening in Paris, this area will open to the public soon, Google will expose there their Cultural contribution to the world.
* ***Emerging Markets***: countries where Internet access is not that easy, for example, Google launched FreeZone in  Philippines to provide internet access for free.
* ***You Tube***: one of the biggest area in Paris, working on the API and search and discovery, that allow people to discover interesting video on You Tube
* ***Research***: applied research, not fundamental, provides some support to other part of Google.

#### Local connections

* ***Google for Entrepreneurs*** Week
* ***Le Camping*** (startup incubator), related to La Cantine, hosting 10 new startups every 6 months
* ***Google Serve***: 3 days a year for charity (La Croix Rouge Française for example)
* ***Google Research*** Awards Program
* ***Tech Talks***

### Testing at Google

This second part of the Tech Talk was presented by *Andreas Leitner* (andreasleitner@google.com), Test Engineering Manager for *Google Zurich*. He is part of the Engineering Productivity group.

A lot of different style at Google, so this talk represent only a subset of what Google is currently doing overall. They create testing and test automation solution. They tries to minimize manual testing as much as possible, it doesn't scale very well. They solve things from an engineering perspective as much as they can.

#### Overview

Google tries to move very fast with continuous integration, a lot of experiment offline and online. Shared code based and a big dependency graph. No library releases, everybody has the potential to re-use everybody else work all the time.  
  
**3 billions** videos watched every day, **every minutes** people watch **48h** of video.

Development team writes codes, review codes, write tests, runs test. Each team decide its own process.  

#### Major language used

* C++
* Java
* Python.

#### Management

it's a flat and autonomous structure, teams are autonomous, have liberty to do what they want to do.

Pros:

* Decision making
* Little time to micro manage
* Bureaucrary get's highlithed

Cons:

* A degree of chaos
* Tribal beliefs grow
* Org stubborn about change

#### Philosophy

Google philosophy is to get the product out quickly. Andreas told us the story of [Two Bridges](http://unprotocols.org/blog:16?) and also the Broken Window methaphore. If it's something nice and shiny people respect that but if there is a defect there is less incentive to keep it going.

Building the right product is really difficult, you have to iterate again and again, before you can reach a stage where it's usable and interesting.

They are spreading the best practice testing methodologies by spreading out their Engineering productivity team over the geos.

There are two testing roles:

* Software Engineer in Test
* Test Engineer

Evangelism and education like **Testing in the Toilet** where they display print-out information about testing. You have to start testing early.

Process/Code Base:

* Bottom-up culture
* Many small teams

Code base:

* Ownership
* Anybody may change anything
* Code reviews & style guide
* No branching, it's continuous integration instead. All development are at HEAD all the time.

Code Reviews:

* More eyes see more
* Make use of developer pride
* Spreads knowledge
* What makes the "change anything policy" possible.
* End with LGTM : Looks Good to Me.

Validation Testing:

* Few manual testers
* Alpha testing: new feature are released internally first
* Beta testing: A/B testing

Tools:

* Big open source company, so many of their tools are Open Source
* Internal and external tools used
* [*Perforce*](http://www.perforce.com/) used for Revision Control.

### Regression testing in the Cloud at Google

Take an automated test, compile it and run it, wait for a new version, compile it, run it, etc ... Simple however it's surprising how many challenges come up.

* More than 10.000 developers all over the world
* More than 2.000 projects under active development
* More than 50.000 builds per day on average
* Single monolithic code tree
* Developement on HEAD: all releases from source, no intermediate libraries.
* 20+ code change per minutes: 50% of code changes monthly.
* More than 50 millions test cases run per day

So at that scale even checkin-out the source code on your machine is a really long operation. It could saturate their corporate network if everybodies do that. Many companies uses development branches to solve that issue, they don't use it. Developers change a small part of the code base for each change but building and testing generates many more files. So they use [*Fuse*](http://fuse.sourceforge.net/) to blend code around the modified source code to execute the test. So most of the files aren't transfered to your machine.

Corp to Cloud isn't efficient so as a result they don't send all the build artifact back to the office PC by default, done only when required. Cache is 1 Petabytes in size.

* 120K test suite in the code base
* Runs about 7.5 millions test suite per day
* more then 3800 continuous integration build (which is a set of test interesting a specific team)
* 10.000 cores consumed and 50 TB of memory

***Build Cop*** (the guy who's drafter to keep all the test working)

* Which change(s) broke the build ?
* How do I get the build green again ?

***Release Engineer*** (wants to push a new version)

* What's the last version where the test passed ?
* Can I have the binaries from the continuous build (please) ?

***Developer***

* Wants to sync to the last version not broken
* If I submit this change do I break any test within Google

Two kinds of dimension

* latency - how quickly I know about a broken
* precision - where is it broken

Google execute only the test affected by the change using analysis, executed as soon as the change comes in (Hyper-Continuous Build). Now how do I know which test do I need to run after a change, it is based on static analysis. Suppose I change a library that everybodies using, you see which test can reach that change, you traverse the reverse dependency tree. You get the closure, go up until you cannot reach any other nodes. So it's a simple system based purely on dependency analysis, but even that is really coslty, they also use caching to optimize everything.

Some issues are troublesome like non deterministic results based on the environment or test prioritization.

This tool is available for everybody to use but some are targeted at specific usage. They are also developping monkey testing tools too.

That's it for now. I was pretty impressed by their Paris office by the way, it's really modest from the outside, not even a Google logo, but when you get in, it's like travelling to the the Silicon Valley ;)

[googletalk]: /images/posts/googletalk-01.png width=700px