# VIEW ~/megauni/views/Hello_sitemap_xml.rb
# NAME Hello_sitemap_xml

instruct!
urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do

  url do
    loc         '{{site_url}}'
    lastmod     '{{last_modified_at}}'
    changefreq  "weekly"
  end
  
  url do
    loc         '{{news_url}}'
    lastmod     '{{last_modified_at}}'
    changefreq  "monthly"
  end
  
  self << '{{# news }}'
    url do
      loc     '{{url}}'
      lastmod '{{last_modified_at}}'
      changefreq  "yearly"
    end
  self << '{{/ news }}'

end
