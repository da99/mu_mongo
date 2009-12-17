partial('__nav_bar')


div.content! do
  
  mustache 'flash_msg?' {
    partial '__flash_msg'
  }

  div.coming_soon! {
    span "Coming Soon..." 
  }

  div {
    p "I am still adding new features/content, so check each Monday for new stuff."
    p "This is a personal/non-commercial site. It has products that have helped me and others."
    p "There are no advertisements or affililate links here."
    p 'Currently, it\'s just for friends and family who keep asking me what to buy.'
  }


end
