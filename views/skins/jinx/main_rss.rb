xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
    xml.title options.site_title 
    xml.description options.site_tag_line
    xml.link options.site_url
    
    @posts.each { |post|
      xml.item {
        xml.title post.title
        xml.link File.join( options.site_url, 'news', "#{post._id}/")
        xml.description post.body
        xml.pubDate Time.parse((post.published_at || post.created_at).to_s).rfc822()
        xml.guid File.join( options.site_url, 'news', "#{post._id}/")
      }
    }
  end
end
