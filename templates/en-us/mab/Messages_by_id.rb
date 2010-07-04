# VIEW views/Messages_by_id.rb
# SASS ~/megauni/templates/en-us/sass/Messages_by_id.sass
# NAME Messages_by_id

show_if 'show_moving_message?' do
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
end

div.col.message!{

 show_if 'message_data' do
   h4 '{{title}}'
   div.body { '{{{compiled_body}}}' }
 end

} # div.message!

div.col.about! {

  p.published_at '{{published_at}}'
  
  p {
    span "This {{message_model_in_english}} was posted in section, "
		a('{{message_section}}', :href=>'{{message_section_href}}')
		span ', of universe, '
    a('{{club_title}}', :href=>'{{club_href}}')
    span '.'
  }

  show_if 'message_updator?' do
    p {
      a('Edit.', :href=>'{{message_href_edit}}')
    }
  end

} # div.about!
  
partial('__nav_bar')

