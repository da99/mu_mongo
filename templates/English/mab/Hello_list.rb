# ~/megauni/views/Hello_list.rb
# ~/megauni/templates/English/sass/Hello_list.sass

partial('__nav_bar')


div.content! do
  
  partial '__flash_msg'

  div.block.coming_soon_content! {
    h4 'Coming Soon...'
    div.body {
      ul {
        li "Get organized with to-do lists."
        li "Manage projects with others online."
        li "No ads or spam."
      }
      p {
        a('Create Account', :href=>'/create-account/')
      }
    }
  }


end

__END__

        li "Stay connected with co-workers, friends and relatives."
        li "Less annoying then FaceBook. More useful than Twitter."

