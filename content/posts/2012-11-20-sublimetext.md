---
title: "Sublime Text 2"
created_at: 2012-11-22 14:38:41 +0100
kind: article
published: true
---

*[Sublime Text 2](https://www.sublimetext.com/)* is one of the best editor for text, code, markup and prose which is available for $59 on OSX, Windows and Linux.  
This cheatsheet is based on the [Tuts+ online training](https://tutsplus.com/course/improve-workflow-in-sublime-text-2/) by Jeffrey Way a editor fanatic who tried them all : [Coda](http://www.panic.com/Coda/), [TextMate](), [Vim]().

<!-- more -->

## Killer features ##

* Command Palette *Crtl + Shift + P*
* Multiple Cursors *Crtl + D*
* Vintage Mode (Vim emulation).
* Lightning fast.
* Become the cool kids code editor, massive documentation.
* Command palet to limit mouse interaction.
* Plugin community incredibility vibrant, package control allow you to install them in seconds.

## Howto

### Shortcuts

|Multiple Selection/Cursors||
|:-:|:-:|
|*Right Click + Shift*|column selection, use crtl/alt to add/remove from selection|
|*Crtl + D*|add the next occurrence of the current word to the selection|
|*Crtl +  shift + L*|Select a block of **lines**, and then split it into many selections, one per line|
|*Alt + F3*|select all occurence of the current word|
|***Most used***||
|*Crtl + Shift + P*|Command Palette|
|*Crtl + P*|file palet|
|*Crtl + K + Crtl B*|toggle Sidebar on/off|
|*Crtl + g*|goto line|
|*Crtl + Shift + up/down*|move line up/down|
|*Crtl +/-*|zoom in/out|
|***Bookmarks***||
|*Crtl + F2*|toggle|
|*Crtl + shift + F2*|clear all|
|*F2*|next|
|*shift + F2*|previous|
|***Others***||
|*Crtl + I*|Incremental search|
|*Crtl + l*|select line|


### Package Control ##

Sublime Package Control is a package manager to discover, install, update and remove packages for Sublime Text 2. It features an automatic upgrader and supports GitHub, BitBucket and a full channel/repository system. To install it follow this procedure :

1. Open Sublime Text console with `crtl + \``
2. Copy the following line to Sublime Text Console

		import urllib2,os; pf='Package Control.sublime-package'; ipp=sublime.installed_packages_path(); os.makedirs(ipp) if not os.path.exists(ipp) else None; urllib2.install_opener(urllib2.build_opener(urllib2.ProxyHandler())); open(os.path.join(ipp,pf),'wb').write(urllib2.urlopen('http://sublime.wbond.net/'+pf.replace(' ','%20')).read()); print 'Please restart Sublime Text to finish installation'

3. If you get `urllib2.URLError: <urlopen error [Errno -2] Name or service not known>`, you may have a bad proxy settings, remove it by adding the following Python line in the above script

		os.environ['http_proxy']='';

4. Restart Sublime Text
5. Launch the Command Palet with `Shift + Control + P` and search for Package Control, you should get the following :

![][PackageControl]

Note: If you type `install` in the Command Palet, you can easily install new packages. If you get no package, check your proxy settings or remove them with 
		
		gconftool -R /system/http_proxy

## Packages ##

### PlainTasks ###
This package offers a great way to manage your tasks as plain text files.

|Shortcuts||
|:-:|:-:|
|*Crtl + shift + p / type task*|Start a new todo-list from Command Palet|
|*Crtl + enter*|New task|
|*Crtl + d*|Toggle done/undone|
|*Crtl + m*|Toggle cancelled|
|*Crtl + shift + A*|Archive all done tasks|
|*Project:*|Anything that ends with : is a Projet|
|*@feature*|Tags|
|*- - + tab*|- - - ✄ - -|
|*Crtl + Shit + up/down*|Re-order tasks|
|*Crtl + r*|List of project|
|||
|||

## Customization ##

### My favorite color schemes for MultiMarkdown ###

* *Twilight* : white text, brown titles, yellow bullets
* *Sunburst* : big brown line for Headings
* *Monokai* : Default one but not enough colorized details for MMD

Note : Solarized Dark and Light are the most popular ones following scientist studies that consider the best lighting for the night and the one the day.                      
## Links ##

* [Official site](https://www.sublimetext.com/)
* [Cheatsheet](http://cheat.errtheblog.com/s/subl)
* [macstories Tips & Tricks](http://www.macstories.net/roundups/sublime-text-2-and-markdown-tips-tricks-and-links)
* [tutsplus Tips & Tricks](http://net.tutsplus.com/tutorials/tools-and-tips/sublime-text-2-tips-and-tricks/)

[PackageControl]: /images/posts/packagecontrol.png "Package Control"