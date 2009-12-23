# ~/megauni/views/Hello_list.rb
# ~/megauni/templates/english/sass/Hello_list.sass

partial('__nav_bar')


div.content! do
  
  partial '__flash_msg'

  div.block.coming_soon_content! {
    h4 'Coming Soon...'
    div.body {
      p "I am still adding new features/content, so check each Monday for new stuff."
      p "This is a personal/non-commercial site. It has products that have helped me and others."
      p "There are no advertisements or affililate links here."
      p 'Currently, it\'s just for friends and family who keep asking me what to buy.'
    }
  }


end
