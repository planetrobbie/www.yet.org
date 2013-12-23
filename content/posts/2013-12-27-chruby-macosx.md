---
title: "chruby on Mac OS X"
created_at: 2013-12-24 18:05:00 +0100
kind: article
published: true
tags: ['howto', 'ruby', 'macos']
---

Ruby is an important tool to have around, Mac OS X already comes bundled with it, but sometimes you need a different version. Mavericks now comes with Ruby 2.0.0-p195, any previous ones comes with 1.8.7 which is very close to end of life. There are lots of alternative to install multiple version of Ruby on your workstation, **[rvm](https://rvm.io/)** or **[rbenv](https://github.com/sstephenson/rbenv)** works well for this job but *[Postmodern](http://postmodern.github.io/)* have another angle to this problem. Quite similar to the **[Arch Linux](https://wiki.archlinux.org/index.php/The_Arch_Way)** Kiss (Keep It Simple, Stupid) philosophy, [chruby](https://github.com/postmodern/chruby) is a deadly simple tool to do just that by updating the environment variables: $RUBY_ROOT, $RUBY_ENGINE, $RUBY_VERSION, $GEM_ROOT, $GEM_HOME, $GEM_PATH and $RUBYOPT in just 90 lines of codes. Let's details how you can install it on your Mac.

<!-- more -->

### Dependencies

We will use [brew](http://brew.sh/) to install chruby. This tool require the Xcode Command Line Tools from *Apple*. First install it from

[https://developer.apple.com/downloads/](https://developer.apple.com/downloads/). You'll need a Developper ID but it's free and easy to get from this link, just click on `Register`. If you already have an Apple ID, you can use it.

Check if Xcode Command Line Tools is installed.

	xcode-select -version

You can now install brew with by running this command which will pause before doing anything on your machine

	ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

Check if brew looks good

	brew doctor

Use brew to install Ruby dependencies

	brew install gdbm libffi libyaml openssl readline

### chruby installation

To install chruby, just type

	brew install chruby

And add the following line to your .bashrc or .zshrc

	source /usr/local/opt/chruby/share/chruby/chruby.sh

To make things easier, you can install ruby-install, this tool automate Ruby installation

	brew install ruby-install

Check the installation went well 

	brew list

### Ruby 1.9.3 installation

Now you can Install any newer Ruby version like this

	ruby-install ruby 1.9.3

Use chruby to Switch to it

	chruby 1.9.3

Check all your Gems will be installed in your User directory

	gem env

You can also check your environment variables

	env

You can go back to your system Ruby using

	chruby system

We wish you all a Merry Christmas. Have Fun with Ruby on Mac.