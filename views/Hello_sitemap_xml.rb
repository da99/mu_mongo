# mab   ~/megauni/templates/English/xml/Hello_sitemap_xml.rb
# SASS  ~/megauni/templates/English/sass/Hello_sitemap_xml.sass
# NAME  Hello_sitemap_xml

class Hello_sitemap_xml < Base_View

	def last_modified_at
		news.first[:last_modified_at ]
	end

	def news_url
		File.join(site_url, 'news/')
	end

	def news
		@news ||= News.by_published_at(:limit=>5, :descending=>true).map { |post|
			{:last_modified_at => w3c_date(post.last_modified_at),
			 :url => File.join(site_url, 'news', post.data._id + '/' ) }
		}
	end

end # === Hello_sitemap_xml 
