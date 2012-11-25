---
title: "MultiMarkdown tips & tricks"
created_at: 2012-10-29 15:52:00 +0000
kind: article
---

[MMD](http://fletcherpenney.net/multimarkdown/) is an extension of a well known markup language extending Markdown.

<!-- more -->

## Syntax

***Emphasis***

	*italic*   **bold** ***bold italic***

**Links**

	<http://yet.org>

**Inline Links**
	
	An [example](http://yet.org)

**Reference Links**
    
	An [example][id] or [id]
	
	  [id]: http://yet.org/ "Some Link" class=external style="border: solid black 1px;"

**Cross Reference**

	### Overview [Introduction] ##
	
	use it:
	
	[Introduction][]
	
**Inline Images (titles are optional)**

	![alt text](/path/img.jpg "Title")

**Reference-style Images**

	![alt text][id]

	[id]: /url/to/img.jpg "Title" width=40px height=400px

**Headers**

	# Header 1

	## Header 2

	###### Header 6

**Ordered List**

	1.  Foo
	2.  Bar

**Unordered List**

	*   A list item.

**Nested List**

	*   Abacus
		* answer
	*   Bubbles
		1.  bunk
		2.  bupkis
			* BELITTLER
		3. burper
	*   Cunning

**Blockquotes**

	> Email-style angle brackets
	> are used for blockquotes.
	
	> > And, they can be nested.

	> #### Headers in blockquotes
	> 
	> * You can quote a list.
	> * Etc.
            
**Code Spans**

	`<code>` spans are delimited by backticks.

**Code Blocks**

Indent every line of a code block by at least 4 spaces or 1 tab.

	This is a normal paragraph.

	    This is a preformatted
	    code block.

***Code Fencing***

Use ``` to wrap code section and you won't need to indent (4x) manually to trigger a code block.

**Horizontal Rules**

	---

**Manual Line Breaks**

End a line with two or more spaces:

	Roses are red,   
	Violets are blue.

**Tables**
    
	[Table Caption]
	|            |        Grouping           ||
	| Left align | Right align | Center align |
	|:-----------|------------:|:------------:|
	| This       |        This |     This     |
	| column     |      column |    column    |
	| will       |        will |     will     |
	| be         |          be |      be      |
	| left       |       right |    center    |
	| aligned    |     aligned |   aligned    |

* You can use normal Markdown markup within the table cells.  
* The alignment of each column is determined by the placement of the colons in the separator line. 
* Normalize a table with `Control-Option-Command-T` see [TextMate Tables bundle](http://www.leancrew.com/all-this/2008/08/tables-for-markdown-and-textmate/).		
* Create a MultiMarkdown table from tab-separated values with `Control-Option-Command-Tab`

**Footnotes, Citations**
    
	Footnotes[^1]    

	This is a statement that should be attributed to its source [p. 23][#Doe:2006].

	And following is the description of the reference to be used in the bibliography.

	[^1]: This is a footnote
	[#Doe:2006]: John Doe. *Some Big Fancy Book*.  Vanity Press, 2006.    

**Definition Lists**

	Apple
	:	Pomaceous fruit of plants of the genus Malus in 
		the family Rosaceae.
	:	An american computer company.
	
	Orange
	:	The fruit of an evergreen tree of the genus Citrus.
	
## Auto-create an Evernote from selected MultiMarkdown
from blogpost @ [http://nsuserview.kopischke.net/search/evernote](http://nsuserview.kopischke.net/search/evernote)

1. install [MultiMarkdow](https://github.com/fletcher/peg-multimarkdown/downloads) 
2. put the [following script](https://gist.github.com/1009149) in ~/Library/Services
3. using Keyboad > Shortcut, associate it to `crtl+opt+cmd E`
4. select some *MultiMarkdown* to press shortcut to create an Evernote from it, Metadata below needs to start at first line.
    1. *Title*: Cheatsheet
    2. *Notebook*: in
    3. *Keywords*: tag1, tag2

## Watch a folder to auto-import notes to Evernote

1. create a new folder that you want to be “watched”
2. copy the following script to clipboard
	
>     on adding folder items to this_folder after receiving these_items
>	    repeat with anItem from 1 to number of items in these_items
>	          set this_item to item anItem of these_items
>	          set the item_info to info for this_item
>	          set the item_path to this_item as text
>         
>	          tell application "Evernote"
>	               try
>	                    create note from file item_path notebook "Auto Import"
>	               on error error_message number error_number
>                   
>	                    if the error_number is equal to 4 then
>	                         -- The file being imported is not supported
>	                         set userCanceled to false
>	                         try
>	                              display dialog "Your Evernote account does not support the import of this type of file.  Why not consider upgrading?" buttons {"Cancel", "Go Premium"} default button "Cancel" cancel button "Cancel" with icon caution
>	                         on error number -128
>	                              set userCanceled to true
>	                         end try
>                        
>                           -- If the user wishes they can be taken to the Evernote premium upgrade page
>	                         if userCanceled is false then
>                                  tell application "Safari"
>	                                   activate
>	                                   open location "https://www.evernote.com/Checkout.action"
>	                              end tell
>	                         end if
>	                    else
>	                         display alert "Import into Evernote failed" message "Error(" & error_number & "): " & error_message as warning
>	                    end if
>	               end try
>	          end tell
>	     end repeat
>		end adding folder items to
>		beep 1
		     
3. launch Applescript Editor and paste it there
4. Compile the script
5. save it and move it to /Library/Scripts/Folder Action Scripts
6. right click the folder, Enable Folder Actions and select your script 

## OSX <-> Marked integration
from blogpost @ [Marked Bonus Pack (scripts, commands and bundles)](http://support.markedapp.com/kb/how-to-tips-and-tricks/marked-bonus-pack-scripts-commands-and-bundles)

1. Let's create a *Marked* Service to easily preview selected MultiMarkdown   
2. download [MarkedBonusPack1.5](http://brettterpstra.com/downloads/MarkedBonusPack1.5.zip)
3. Put the Services in ~/Library/Services
4. assign a shortcut in **System Preferences->Keyboard->Shortcuts->Services**

## TextMate <-> Marked integration

1. Double-click on the Marked bundle to open it in TextMate's Bundle Editor.
2. `Control-Command-M` preview current selection

## Evernote <-> Marked integration

1. To watch Evernote folders: start `~/path/to/everwatch.rb` in Terminal.
2. Open "~/Marked Preview.md" in Marked to preview 
3. `Command-S` in Evernote to refresh preview. (4'' delay, autosave takes longer)

## Vim <-> Marked integration

1. install [MacVim](http://code.google.com/p/macvim/)
2. add the following line to .vimrc `:nnoremap <leader>m :silent !open -a Marked.app '%:p'<cr>`
3. open or create a file using `mvim`
4. save the file
5. `\m` to preview, use `alt+shift+/` to get `\` 

## Mediawiki <-> Markdown
from [Mediawiki](http://www.mediawiki.org/wiki/Extension:MarkdownSyntax)

1. mkdir $IP/extensions/MarkdownSyntax ($IP is the Mediawiki install dir, for me it's /var/lib/mediawiki)
2. download [PHP Markdown](http://www.michelf.com/projects/php-markdown/)
3. mv markdown.php $IP/extensions/MarkdownSyntax/
4. vi markdown.php to change `<code><pre>` to `<pre><code>` and closing tags too (to correct code blocks bug)
4. cp [MarkdownSyntax.php](http://www.mediawiki.org/wiki/Extension:MarkdownSyntax#MarkdownSyntax.php) $IP/extensions/MarkdownSyntax/
5. vi /etc/mediawiki/LocalSettings.php  
	
    require_once( "$IP/extensions/MarkdownSyntax/MarkdownSyntax.php" );

## AlternateSyntaxParser Mediawiki extension installation
to [configure](http://www.mediawiki.org/wiki/Extension:AlternateSyntaxParser) different parsers per page or site wide. 

1. mkdir $IP/extensions/AlternateSyntaxParser
2. cp [AlternateSyntaxParser.php](http://jimbojw.com/wiki/index.php?title=AlternateSyntaxParser&action=raw&ctype=text/plain&name=AlternateSyntaxParser.php) $IP/extensions/AlternateSyntaxParser
3. comment out line 112: !$this->mEditPreviewFlag (seems buggy with Mediawiki 1.15)
3. mv markdown.php /var/lib/mediawiki/extensions/AlternateSyntaxParser (don't need it in MarkdownSyntax dir any more)
3. vi /etc/mediawiki/LocalSettings.php

	require_once('extensions/AlternateSyntaxParser/AlternateSyntaxParser.php');
	$wgEnableParserCache = false;
	$wgAlternateSyntaxParserLanguage = 'markdown'; (if you need system wide default)  

4. First line of docs should contain

	`#MARKUP language`     

## MultiMarkdown 3.6 installation

* Provides: multimarkdown (C) and shell wrappers: mmd, mmd2tex, mmd2opml, mmd2odf
* [OSX](https://github.com/fletcher/peg-multimarkdown/downloads) binaries
* [Windows](https://github.com/fletcher/peg-multimarkdown/downloads) binaries
* [OpenSUSE](http://software.opensuse.org/package/multimarkdown) package
* Compile from [source](https://github.com/fletcher/peg-multimarkdown)  

    % git clone git://github.com/fletcher/peg-multimarkdown.git  
    % make; make install

## New features compared to Markdown

* footnotes
* tables
* citations and bibliography (works best in LaTeX using BibTeX)
* math support
* automatic cross-referencing ability
* smart typography, with support for multiple languages
* image attributes
* table and image captions
* definition lists
* glossary entries (LaTeX only)
* document metadata (e.g. title, author, date, etc.)

## Links

1. [Official](http://fletcherpenney.net/multimarkdown) web site
2. [documentation](https://github.com/fletcher/MultiMarkdown/blob/master/Documentation/MultiMarkdown%20User%27s%20Guide.md)
3. <http://markedapp.com> - show you the final output of your document as you work.
4. [Byword](http://bywordapp.com/) - IOS, OSX beautiful MultiMarkdown editor
5. [TextMate](http://macromates.com) - great OSX editor now [Open Sourced](https://github.com/textmate/textmate) 
6. <http://markable.in/> - live online rendering of Markdown text
7. [Pandoc](http://johnmacfarlane.net/pandoc) - great to convert between Markup languages from Markdown, reStructuredText, textile, html, DocBook, or LaTeX to html, Word, OpenOffice, Mediawiki, epub, DocBook, pdf, RST, ....
8. Other Markdown syntaxes: [GitHub flavored (GFM)](http://github.github.com/github-flavored-markdown), [Markdown Extra](http://michelf.ca/projects/php-markdown/extra/), [Maruku](http://maruku.rubyforge.org/maruku.html), [kramdown](http://kramdown.rubyforge.org/), [Pandoc Markdown](http://johnmacfarlane.net/pandoc/README.html#pandocs-markdown)
9. [Wikipedia list](http://en.wikipedia.org/wiki/List_of_Markdown_implementations) of implementation
10. [Ruby PEG MultiMarkdown](https://github.com/djungelvral/rpeg-multimarkdown) a MultiMarkdown module for ruby forked from rpeg-markdown                                                        	
