instruct! :xml, :version => '1.0'
rss :version => "2.0" do
  channel do
    title '{{site_title}}'
    description '{{site_tag_line}}'
    self.link '{{site_url}}'
    
    self << "{{# posts }}"
      item {
        title '{{title}}'
        self.link  '{{url}}'
        description '{{body}}'
        pubDate "{{published_at_rfc822}}"
        guid "{{url}}}"
      }
    self << '{{/posts}}'
  end
end
