require 'multimarkdown'
	 
class Multimd < Nanoc::Filter
  identifier :mmd

  def run(content, args)
  	 MultiMarkdown.new(content).to_html
  end

end
