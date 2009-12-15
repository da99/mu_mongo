xml.instruct!
xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do
  xml.url do
    xml.loc         urlize('/')
    xml.lastmod     w3c_date( @news.first.last_modified_at  )
    xml.changefreq  "weekly"
  end
  
  xml.url do
    xml.loc         urlize('/news/')
    xml.lastmod     w3c_date( @news.first.last_modified_at ) 
    xml.changefreq  "monthly"
  end
  
  @news.each do |post|
    xml.url do
      xml.loc     urlize("/news/#{post._id}/")
      xml.lastmod w3c_date(post.last_modified_at) 
      xml.changefreq  "yearly"
    end
  end
  
    

end
