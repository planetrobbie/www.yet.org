include Nanoc::Helpers::Blogging
include Nanoc::Helpers::Tagging
include Nanoc::Helpers::Rendering
include Nanoc::Helpers::LinkTo

module NavHelper

	def nav_link(name, path, current)
		ident = item.identifier

		# nav rules
		if 
        (path == '/' and (ident == '/')) or path == '/tags' or path == '/work' or path == '/archives' or path == '/about' or path == '/contact'
			clazz = "active " 
		else
			clazz = ' '
		end

    if (name == 'Yet Emerging Technologies')
      clazz += 'yet'
    else
      clazz += name
    end
 
		"<li class='#{clazz}'><a href='#{path}'>#{name}</a></li>"
	end
end
include NavHelper

module PostHelper
  
  def get_post_day(post)
  	attribute_to_time(post[:created_at]).strftime('%e')
  end  
  
  def get_post_month(post)
  	attribute_to_time(post[:created_at]).strftime('%^b')
  end  
  
  def get_post_date(post)
    attribute_to_time(post[:created_at]).strftime('%B %-d, %Y')
  end

  # if compiling in production mode, only show published articles
  def blog_articles
  	if ENV['NANOC_ENV'] == 'production'
  		sorted_articles.select{|a| a[:published] }
  	else
  		sorted_articles[0, 9]
  	end
  end  
 
  # Apart from the top 10, all archived articles are rendered below 
  def blog_articles_archived
  	sorted_articles.drop(9)
  end  
  
  def get_post_start(post)
  	content = post.compiled_content
  	if content =~ /\s<!-- more -->\s/
  		content = content.partition('<!-- more -->').first +
  		"<div class='read-more'><a href='#{post.path}'>read &rsaquo;</a></div>"
  	end
  	return content	
  end

end

include PostHelper

# Creates in-memory tag pages from partial: layouts/_tag_page.haml
def create_tag_pages
  tag_set(items).each do |tag|
    @items.create(
      "= render('_tag_page', :tag => '#{tag}')",           # use locals to pass data
      { :title => "Category: #{tag}", :is_hidden => true}, # do not include in sitemap.xml
      "/tags/#{tag}/",                                     # identifier
      :binary => false
    )
  end
end

# Copy static assets outside of content instead of having nanoc3 process them.
def copy_static
  FileUtils.cp_r 'static/.', 'output/' 
end
