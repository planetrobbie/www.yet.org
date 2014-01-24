---
title: "Elementary"
created_at: 2012-11-19 12:35:00 +0000
kind: article
tags: ['linux', 'desktop interface', 'gnome']
---

*[Elementary](http://elementaryos.org/)* is a new initiative to create an Operating Sytem with an emphasis on elegance.

<!-- more -->

Elementary team have a commitment to a particular toolkit ([GTK+](http://www.gtk.org/)) and support a preferred programming language ([Vala](https://live.gnome.org/Vala)). They've created an application development framework ([Granite](https://launchpad.net/granite)) and other developer tools that are designed to help developers build apps specifically for this platform.

Current [Luna Beta 1](http://elementaryos.org/journal/luna-beta-1-released) version is based on Ubuntu 12.04 LTS ([Precise Pangolin](https://wiki.ubuntu.com/PrecisePangolin/ReleaseNotes/UbuntuDesktop)).

Let's review all the components of this sleak OS.

## Major Components

### Window Manager - [Gala](https://launchpad.net/gala) ###

[Gala](http://elementaryos.org/journal/meet-gala-window-manager) is built on *LibMutter* which is the library used by *Mutter* the *Gnome3* Window Manager. Both *Mutter* and *Gala* uses *Clutter* which does its rendering using *OpenGL* or *OpenGL ES* to offer a light and smoothly-animated experience in addition to support for more complex decoration theming. Power users will love the new workspace management features as well.

*LibMutter* offers smoother (antialiased) window corners. *Gala* also gives us the ability to have beautiful big shadows beneath our windows and resize windows is now smoothly done in realtime 

*Gala* organize Workspace in a horizontal list, a workspace will be automatically closed with the last window. If you close a Workspace from the switcher, *Gala* will close all running windows too.

When using `alt+TAB` only the selected window will be displayed, the Dock will display the order in which the windows will appear. Elementary OS team choosed not to introduce any new and invasive UI element that would only be seen during window switching.

Grid-based window tiling is inherited from *LibMutter*

### Desktop environment and shell - Pantheon ###

Consists of the greeter, panel, app launcher, dock, window manager, settings app, and theme.

Pantheon Greeter (login screen), is now built on [LightDM](http://www.freedesktop.org/wiki/Software/LightDM). It features smooth graphics and animation with Clutter, displays the time and date with beautiful typography, and has built-in accessibility.

### Application launcher - [SlingShot](https://launchpad.net/slingshot) ###

![][SlingShot]

App launcher, displays an optimal 3x5 paged grid of app icons built for speed and utilizes Granite which ensures consistency with the rest of the system.

### Top panel - [WingPanel](https://launchpad.net/wingpanel) ###

![][WingPanel]

*WingPanel* is a space-saving top panel with a refined look providing easy indicators access; clicking an indicator reveals a pleasing popover with the relevant items, and the Applications item now opens Slingshot instead of a menu.

### Dock - [Plank](https://launchpad.net/pantheon-dock) ###

![][Plank]

[Plank](http://wiki.go-docky.com/index.php?title=Plank:Introduction) is meant to be the simplest dock on the planet. The goal is to provide just what a dock needs and absolutely nothing more. It is, however, a library which can be extended to create other dock programs with more advanced features. Thus, Plank is the underlying technology for [Docky](http://wiki.go-docky.com/index.php?title=Welcome_to_the_Docky_wiki) (starting in version 3.0.0) and aims to provide all the core features while Docky extends it to add fancier things like Docklets, painters, settings dialogs, 

Plank is one of the only part of Elementary to be developed in Vala by 3rd party developers and features LibUnity integration to allow to show app badges, progess bars and contextual quicklist items.

If you need to change the Dock Position, change the value of `Position=` in the `~/.config/plank/dock1/settings` file, put instead: `0/1/2/3` respectively for `left/up/righ/bottom`.

### Settings - [Switchboard](https://launchpad.net/switchboard) ###

![][Switchboard]

Unified system configuration, supports a slick open standard for settings panes, called plugs (standalone executable binaries). *Luna* comes with a number of plugs preinstalled as well as a transitional compatibility layer for GNOME’s System Settings panes.

*Switchboard* is divided in four categories : Network, Hardware, Personal, System. Application level settings won't be available here.

## Elementary Applications

### Terminal - [Pantheon Terminal](https://launchpad.net/pantheon-terminal) ###

A lightweight and simple terminal emulator. It makes use of Granite, meaning it has excellent and consistent tab management.

### Editor - [Scratch](https://launchpad.net/scratch) ###

![][Scratch]

*Scratch* is the text editor that works for you. It auto-saves your files and remembers your tabs so you never lose your spot, even in between sessions.

It is written from the ground up to be extensible. Keep things super lightweight and simple, or install extensions to turn Scratch into a full-blown IDE; it's your choice. And with a handful of useful preferences, you can tweak the behavior and interface to your liking.

*Scratch* closely follows the high standards of design, speed, and consistency. It's sexy, but not distracting.

Syntax-highlighted languages: Bash, C, C#, C++. Cmake, CSS, .Desktop, Diff, Fortran, Gettext, HTML; ini, Java, JavaScript, LaTex, Lua, Makefile, Objective C, Pascal, Perl, PHP, Python, Ruby, Vala, XML.

Additional features include:

* syntax highlighting with gtksourceview-3
* a find bar to search the words in the files
* strong integration with Granite framework by elementary-team
* tab and split documents system

### Web Browser - [Midori](http://twotoasts.de/index.php/midori/) ###

![][Midori]

Newer and much faster version of [WebKit](http://www.webkit.org/), providing an all-around better experience and supporting the latest in CSS3 and HTML5. A new Dynamic Notebook has been integrated from Granite, giving Midori a beautiful and consistent tabbed browsing experience. Midori also makes use of Popovers in its bookmarking interface. Lastly, Midori has received many important compatibility and security updates.

### Mail Client - [Geary](http://worldofgnome.org/geary-mail-client-4-gnome-version-0-2-released/) ###

![][Geary]

A new mail client which supplants Jupiter’s (previous release) *Postler* and does a mighty fine job. Geary brings some of the best features of webmail to the desktop—like threaded conversations and excellent HTML rendering—while excelling in desktop integration with attachment handling, mail notifications, and more.

Geary doesn’t store the data locally (keeps some caching though) but syncs with the mail server in “real time”.

Currently lacking features of v0.2: Searching, Multiple accounts, Offline mode.

### Calendar - [Maya](https://launchpad.net/maya) ###

![][Maya]

*Maya*, a new app in Luna, is a simple desktop calendar. With it you can create, view, and manage events to organize your agenda.

### Contact - [Dexter](https://launchpad.net/dexter-contacts) ###

![][Dexter]

Dexter is a contact management application for Pantheon

### Music player - [Noise](https://launchpad.net/noise) ###

![][Noise]

Noise is a brand new music player, it combines a beautifully simple interface with a powerfully fast backend to let you get right at your music. It makes excellent use of Granite’s ThinPane and DecoratedWindow widgets, ensuring consistency with the rest of the desktop.

## Developement Framework - [Granite](https://launchpad.net/granite) ##

*Granite* is an extension of GTK. Among other things, it provides the commonly-used widgets such as modeswitchers, welcome screens, AppMenus, search bars, and more found in elementary apps.

## Elementary Keyboards Shortcuts and special keys ##
|||
|:-|:-:|
|`⌘ + Left/Right`|Switch Workspace|
|`⌘ + Space`|App Launcher|
|`⌘ + Zero`|New Workspace|
|`⌘ + S`|Workspace overview| 
|`⌘ + W`|Window Overview|
|`⌘ + A`|Window Overview across all workspace|
|`⌘ + L`|lock screen|  
|`⌘ + ⇧ + Left/Right`|Move Window with Workspace|
|`⌘ + Ctrl + Left/Right`|Snap Window to Half of Workspace|
|`⌘ + Ctrl + Up/Down`|Maximize/Unmaximize Window|
|`⌘ + Click + Drag`|move window around|
|`⌘ + Right Click + Drag`|Resize Window|
|`Crtl + ⇧ + C`|copy inside the terminal|
|`Crtl + ⇧ + V`|paste inside the terminal|
|`Crtl + alt + tab`|cycle through panels|
|`AltGr + n + space`|~|

## Customization ##

*Elementary* is great, but let's make it even better with the following customization

* *ZSH* installed, alias rake="noglob rake" added, globbing interfere with [] in Rake commands
* *Oh My Zsh* auto-installed from GitHub shell script, see YET [article](/2012/12/oh-my-zsh/)
* *Sublime Text 2* [installed](http://www.sublimetext.com/2) with Twiligh color scheme.
* *VMware Tools* for Ubuntu 12.04 see [installation Note](http://partnerweb.vmware.com/GOSIG/Ubuntu_12_04.html).
* *RVM* [installed](https://www.digitalocean.com/community/articles/how-to-install-ruby-on-rails-on-ubuntu-12-04-lts-precise-pangolin-with-rvm) to install & manage Gems (nanoc, adsf, fssm, ..) & Ruby 1.9.3 
* *peg-multimarkdown* installed from [source](https://github.com/fletcher/peg-multimarkdown)
* *gimp* installed
* exclude host from proxying with:
		gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '10.0.0.0/8', '192.168.0.0/16', '172.16.0.0/12' , '*.localdomain.com' ]"
		gconftool -R /system/http_proxy [to remove proxying which interfere with Sublime Text Package Control]
* *iftop*, *vnstat*, *htop*, *slurm* installed for network & process monitoring
* *tree* installed for nice tree dir colored output.
* *dnstools* installed to debug DNS issues.
* *dropbox* installed from deb provided on their site.
* *dconf-tools* to configure Pantheon Terminal colors using `dconf-editor` but still a work in progress, waiting for future release of Luna. Currently using Gnome Terminal instead to benefit from Solarized Dark palette. using customization below.
* sudo apt-get install python-setuptools; easy_install Pygments; easy_install sphinx; export LC_ALL=en_US.UTF; export LANG=en_US.UTF-8; make html; make epub
* sudo apt-get install sshfs; usermod -a -G fuser brauns; sshfs user@<ip>:/remote/path/ /mnt/local/path
* pidgin installed (IRC client)

### AltGr inversion trick ##
1. Linux VM need to be configured with Mac Profile Keyboard in settings 
2. To switch both Alt keys (from [blog](http://instant-thinking.de/2009/01/17/ubuntu-linux-unter-vmware-fusion-sonderzeichen-auf-der-mac-tastatur/))
3. Edit ~/.Xmodmap

	% vi .Xmodmap  
	
	>clear mod1  
	>clear mod5  
	>keycode 108 = Alt_L  
	>keycode 64 = ISO_Level3_Shift  
	>add mod1 = Alt_L  
	>add mod5 = ISO_Level3_Shift  

4. Reread this file with xmodmap .Xmodmap
5. see [here](https://help.ubuntu.com/community/AppleKeyboard) for more information on Apple Keyboard on Ubuntu

Note: to display keycode of touch pressed on the keyboard, you can launch from a terminal the `showkey` application.

### Adding Sublime Text 2 Icon & Launcher ##
	
1. Copy Sublime Text 2 classic [Icon](http://c758482.r82.cf2.rackcdn.com/sublime_text_icon_2181.png) or this newer [one](http://i.imgur.com/xjZjS.png)

    % cp sublime_text.png ~/.local/share/icons/  

2. Edit launcher

	% vi /usr/share/applications/sublime_text.desktop  

	>\#!/usr/bin/env xdg-open  

	>[Desktop Entry]  
	>Name=Sublime Text 2  
	>Exec=/home/brauns/SublimeText2/sublime_text  
	>Icon=sublime_text  
	>Type=Application  
	>Categories=GNOME;GTK;Utility;TextEditor;Development;  
	>MimeType=text/plain;text/x-web-markdown;  
	>StartupNotify=true  
	>Terminal=false  

### Solarized colors

#### Dircolors

To install Solarized color theme for LS_COLORS:

	wget --no-check-certificate https://raw.github.com/seebi/dircolors-solarized/master/dircolors.ansi-dark
	mv dircolors.ansi-dark .dircolors
	eval `dircolors ~/.dircolors`

To make it persistent you can add the above line to your `~/.zshrc`

#### Gnome Terminal

To setup Solarized for GNOME Terminal:

	git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git
	cd gnome-terminal-colors-solarized
	
	And now you can set it to light or dark using the following commands:
	./set_dark.sh
	./set_light.sh

## Conclusion

I've been using Elementary for few days now, I find it even better then Mac OSX. I'm now using it fulltime now :). So I encourage you to test it, You'll find the iso on their [site](http://elementaryos.org/journal/luna-beta-1-released).

[WingPanel]: /images/posts/wingpanel.png "WingPanel" width=850px
[SlingShot]: /images/posts/slingshot.png "SlingShot"
[Switchboard]: /images/posts/switchboard.png "Switchboard"
[Plank]: /images/posts/plank.png "Plank" width=850px
[Scratch]: /images/posts/scratch.png "Scratch"
[Midori]: /images/posts/midori.png "Midori"
[geary]: /images/posts/geary.png "Geary"
[maya]: /images/posts/maya.png "Maya"
[Dexter]: /images/posts/dexter.png "Dexter"
[Noise]: /images/posts/noise.png "Noise"