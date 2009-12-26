# mab   ~/megauni/templates/english/xml/Hello_sitemap_xml.rb
# SASS  ~/megauni/templates/english/sass/Hello_sitemap_xml.sass
# NAME  Hello_sitemap_xml

class Hello_sitemap_xml < Bunny_Mustache

	def last_modified_at
		news.first[:last_modified_at ]
	end

	def news_url
		File.join(site_url, 'news/')
	end

	def news
		@news ||= News.by_published_at(:limit=>5, :descending=>true).map { |post|
			{:last_modified_at => w3c_date(post.last_modified_at),
			 :url => File.join(site_url, 'news', post.original_data._id + '/' ) }
		}
	end

end # === Hello_sitemap_xml 
