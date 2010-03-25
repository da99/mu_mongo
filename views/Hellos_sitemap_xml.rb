# mab   ~/megauni/templates/English/xml/Hellos_sitemap_xml.rb
# SASS  ~/megauni/templates/English/sass/Hellos_sitemap_xml.sass
# NAME  Hellos_sitemap_xml

class Hellos_sitemap_xml < Base_View

	def last_modified_at
		latest_post = news.first
    return w3c_date(Time.now.utc) if not latest_post
    news.first[:last_modified_at]
	end

	def news_url
		File.join(site_url, 'news/')
	end

	def news
		@news ||= News.by_published_at(:limit=>5, :descending=>true).map { |post|
			{:last_modified_at => w3c_date(post[:doc][:updated_at] || post[:doc][:created_at]),
			 :url => File.join(site_url, 'news', post[:doc][:_id] + '/' ) }
		}
	end

end # === Hello_sitemap_xml 
