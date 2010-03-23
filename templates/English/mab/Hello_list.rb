# ~/megauni/views/Hello_list.rb
# ~/megauni/templates/English/sass/Hello_list.sass



div.content! do
  
  partial '__flash_msg'

  div.block.coming_soon! {
    h4 'Introduction'
    p %^ 
         MegaUni.com is a website made up of different online clubs.
    ^
    ul { 
      li "San Francisco" #  (Survival Tips + Marketplace)
      li "Tokyo" # (+ Translate Please)
      li "Vitamin Fanatics" #  (Harmless + Helpful)
      li "Vote For More Clubs"
      li "- How I Train My Boyfriend"
      li "- Introverts"
      li "- Obama-rific" #  (Politics + News)
      li "City Clubs "
			li "- Multiple Languages"
			li "- Carpooling"
			li "- Garbage Renting"
    } 

  }


end

partial('__nav_bar')
__END__

        li "Stay connected with co-workers, friends and relatives."
        li "Less annoying then FaceBook. More useful than Twitter."

