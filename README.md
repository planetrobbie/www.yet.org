## About yet.org

*yet.org* was created in 2006 by *Sébastien Braun*, a innovation and tech enthusiast. It originally used *[Movable Types](http://www.movabletype.org/)* and was mostly talking about Science Fiction litterature. It then evolved as a *MediaWiki* [encyclopedia](http://wiki.yet.org).

As of end of end of november 2012 a new iteration to a fully static web site is on his way, it is based on the excellent *[nanoc](http://nanoc.stoneship.org/)* generator which I choosed because it's not only a blogging system but a great toolkit to build whatever comes out of your imagination. That's what I'm initiating with this *YET* makeover.

In this repository you'll find not only the code of *YET* but all the posts in MultiMarkdown format.

While creating this new incarnation, my journey were accelerated by the tons of information from people already using *nanoc*. I'd like to thank *Clark Dave* for his sharing, it helped a lot. 

It's now my turn to share, feel free to re-use whatever part of *YET*.

By the way, *YET* stands for *Yet Emerging Technologies*.

### Licensing

[<img alt="Apache 2.0 License" src="http://www.apache.org/images/feather-small.gif" width="100"/>](http://www.apache.org/licenses/LICENSE-2.0.html)

All the content published on this web site, layouts, custom rake tasks and [code](http://github.com/planetrobbie/www.yet.org) is licensed under the _Apache 2.0 License_. For other uses, please contact us.

### Requirements

The following ruby libraries (gems) are used to compile this web site:

* *nanoc*: to generate the entire web site
* *adsf*: a Dead Simple Fileserver        
* *fssm*: File System State Monitor        
* *kramdown*: Markdown parser    
* *haml*: HTML Abstraction Markup Language        
* *less*: Invoke the Less CSS compiler from Ruby        
* *pygments.rb*: Exposes the pygments syntax highlighter to Ruby
* *stringex*: useful extensions to Ruby's String class    
* *nokogiri*: Parser used by `nanoc validate-links`    
* *rainpress*: A CSS compressor  
* *therubyracer*: Call javascript code and manipulate javascript objects from ruby. Call ruby code and manipulate ruby objects from javascript.
* *rpeg-multimarkdown*: MultiMarkdown processing used in a new Filter. Require libgtk2.0-dev and [MultiMarkdown version 3.2](http://fletcherpenney.net/multimarkdown/)

This list may not be up to date, consult our [Gemfile](https://github.com/planetrobbie/www.yet.org/blob/master/Gemfile) to get a fresh one.

### Credits

Special thanks to the following people, who made this web site possible:

* *[Denis Defreyne](http://www.stoneship.org/)*, for creating *[nanoc](http://nanoc.stoneship.org/)* site publishing system.
* The creators of the *[Sublime Text 2](http://www.sublimetext.com/)* editor.