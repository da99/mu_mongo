# XML   /home/da01tv/MyLife/apps/megauni/templates/en-us/xml/Hellos_rss_xml.rb
# NAME  Hellos_rss_xml

class Hellos_rss_xml < Base_View

  def posts
		@news ||= Message.by_published_at(:limit=>5, :sort=>[:published_at, :desc]).map { |post|
			{:published_at_rfc822 => rfc822_date(post['created_at']),
			 :url => File.join(site_url, 'mess', post['_id'].to_s + '/' ),
       :body => post['body'],
       :title => (post['title'] || "Message: #{post['_id']}") 
      }
		}
	end
  
end # === Hellos_rss_xml 
