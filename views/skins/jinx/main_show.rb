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

  div %~
    Ok, so I have a general idea of what this site will be.
    It will only be open if you have an invitation code.  
    (Egg timers will be always open to the public.)
    You will have a limit of 10 friends. If 3 or more of your friends
    get banned, you will also be banned.  From the beginning, 
    it will be about the economy, pets, and anti-aging.
    Live long and survive the double-dip recession coming in 2011.
  ~

}

