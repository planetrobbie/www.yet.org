---
title: "Sublime Text 2"
created_at: 2012-11-22 14:38:41 +0100
kind: article
published: true
tags: ['cheatsheet', 'tools']
---

*[Sublime Text 2](https://www.sublimetext.com/)* is one of the best editor for text, code, markup and prose which is available for $59 on OSX, Windows and Linux.  
This cheatsheet is based on the [Tuts+ online training](https://tutsplus.com/course/improve-workflow-in-sublime-text-2/) by Jeffrey Way a editor fanatic who tried them all : [Coda](http://www.panic.com/Coda/), [TextMate](), [Vim]().

<!-- more -->

### Installation on Ubuntu or Elementary OS

Sublime Text 3 is in the works, still in [beta](http://www.sublimetext.com/3). In the meantime you can install version 2.0.2, from a terminal:

	sudo add-apt-repository ppa:webupd8team/sublime-text-2
	sudo apt-get update
	sudo apt-get install sublime-text

But if you prefer you can download `Sublime-Text2.0.2-x64.tar.bz2` from *Sublime Text* [official site](http://www.sublimetext.com/2), Windows or OSX binaries are also there.

### Killer features ##

* `Crtl + Shift + p` Command Palette to limit mouse interaction
* `Crtl + D` Multiple Cursors
* Vintage Mode (Vim emulation).
* Lightning fast.
* Become the cool kids code editor, massive documentation.
* Plugin community incredibility vibrant, package control allow you to install them in seconds.

### Howto

#### Shortcuts

|**Most used**||
|:-|:-|
|`Crtl + p`|File palet|
|`Crtl + Shift + p`|Command Palette|
|`Crtl + k + Crtl b`|toggle Sidebar on/off|
|`Crtl + g`|goto line|
|`Crtl + Shift + Up/Down`|move line up/down|
|`Crtl + [` or `Crtl + ]`|ident back and forth|
|`Crtl +/-`|zoom in/out|
|**Multiple Selection / Cursors**||
|`Right Click + Shift`|column selection, use Crtl/Alt to add/remove from selection|
|`Crtl + D`|add the next occurrence of the current word to the selection|
|`Crtl +  Shift + L`|Select a block of lines, and then split it into many selections, one per line|
|`Alt + F3`|select all occurence of the current word|
|**Bookmarks**||
|`Crtl + F2`|toggle|
|`Crtl + Shift + F2`|clear all|
|`F2`|next|
|`shift + F2`|previous|
|***Others***||
|`Crtl + l`|Select line|
|`Crtl + Shift + i`|Incremental search|
|`Crtl + Shift + k`|Kill line|
|`Crtl + Return`|Return like if you were at end of line|
|`Crtl + /`|Comment line|

#### Rails tips & tricks

Install [*ERB Insert and Toggle Commands*](http://github.com/eddorre/SublimeERB) using *Package Control*, it gives you easy access to ERb tags, you just need to add the following to your user key bindings after installation to cycle thru Erb Tags with a simple key press:
	
	[
	    { "keys": ["ctrl+="], "command": "erb" }
	]

Install [*RubyTest*](https://github.com/maltize/sublime-text-2-ruby-tests) to run your Ruby tests from within *Sublime Text 2* just by typing `ctrl+shift+t.`

See [*Michael Hartl*](http://ruby.railstutorial.org/) docs [on *GitHub*](https://github.com/mhartl/rails_tutorial_sublime_text) for more information.

#### Package Control ##

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

If Package Control install fails silently, just remove the `Package settings > Package control: user` repositories you've configured.

### Packages ##

#### PlainTasks ###
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

If you use [*DropBox*](https://www.dropbox.com) and [*TaskPaper*](http://www.hogbaysoftware.com/products/taskpaper) for iOS, you'll be able to sync up your task to all your devices using the following *PlainTask* Configuration update :

	   "open_tasks_bullet": "-",
	   "done_tasks_bullet": "-",
	   "date_format": "(%Y-%m-%d)",
	   "translate_tabs_to_spaces": false,

Following [Patch](https://github.com/aziz/PlainTasks/pull/25/files) applied, for full TaskPaper compatibility.

#### FindKeyConflicts ###

Sometimes you press a key and the result surprise you, it's maybe due to a binding conflict. The last settings always preval. To check for that you can use [FindKeyConflicts](https://github.com/skuroda/FindKeyConflicts) Package.

#### Chef ###

If you are like me and are interested in *[Chef](http://www.getchef.com)*, a configuration management framework. You can install the [Chef package](https://sublime.wbond.net/packages/Chef) that will add autocompletion for common Chef idioms.

### Customization ##

#### My favorite color schemes for MultiMarkdown ###

* *Twilight* : white text, brown titles, yellow bullets
* *Sunburst* : big brown line for Headings
* *Monokai* : Default one but not enough colorized details for MMD

Note : Solarized Dark and Light are the most popular ones following scientist studies that consider the best lighting for the night and the one the day.

### Keyboard troubleshooting ##

Running Sublime Text 2 under VMware Fusion can sometimes be troublesome when it comes to Key bindings. To see what keys sublime gets from the OS, open the Python console from the `View > Console` menu and type

	sublime.log_input(True)

### Links ##

* [Official site](https://www.sublimetext.com/)
* [Cheatsheet](http://cheat.errtheblog.com/s/subl)
* [macstories Tips & Tricks](http://www.macstories.net/roundups/sublime-text-2-and-markdown-tips-tricks-and-links)
* [tutsplus Tips & Tricks](http://net.tutsplus.com/tutorials/tools-and-tips/sublime-text-2-tips-and-tricks/)

[PackageControl]: /images/posts/packagecontrol.png "Package Control"