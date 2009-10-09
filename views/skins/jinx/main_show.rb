save_to('title'){ "Coming Soon..." }

save_to('meta_description') { 
  the_app.options.site_tag_line
}

save_to('meta_keywords') {
  the_app.options.site_keywords
}


partial('__nav_bar')


div.content! {
  if the_app.flash_msg?
    partial '__flash_msg'
  end
  div :style=>"font-family: courier; font-size: 25px; font-weight: bold;" do
    span "Coming Soon..." 
  end

  div {
    p "I am still adding new features/content, so check each Monday for new stuff."
    p "This is a personal/non-commercial site. It has products that have helped me and others."
    p "There are no advertisements or affililate links here."
    p 'Currently, it\'s just for friends and family who keep asking me what to buy.'
  }


}

