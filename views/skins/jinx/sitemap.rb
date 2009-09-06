xml.instruct!
xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do
  xml.url do
    xml.loc         urlize('/')
    xml.lastmod     w3c_date(@news.first.last_modified)
    xml.changefreq  "never"
  end
  
  xml.url do
    xml.loc         urlize('/hearts/')
    xml.lastmod     w3c_date(@news.first.last_modified )
    xml.changefreq  "monthly"
  end
  
  @news.each do |post|
    xml.url do
      xml.loc     urlize("/heart_link/#{post[:id]}/")
      xml.lastmod w3c_date(post.last_modified) 
      xml.changefreq  "yearly"
    end
  end
  
    

end
