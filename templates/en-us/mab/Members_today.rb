# VIEW views/Members_today.rb
# SASS templates/en-us/sass/Members_today.sass
# NAME Member_Control_today

partial '__flash_msg'

div.newspaper! {
  mustache 'no_newspaper' do
    a( 'Check out some clubs to follow.', :href=>'/clubs/')
  end

  mustache 'newspaper?' do  
    h4 'The latest from clubs you follow:'
    mustache 'newspaper' do
      div.message do
        div.body( '{{{compiled_body}}}' )
        div.permalink {
          a('Permalink', :href=>"{{href}}")
        }
      end
    end
  end
} # === div.newspaper!
partial('__nav_bar')

