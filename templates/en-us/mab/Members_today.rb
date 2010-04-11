# VIEW views/Members_today.rb
# SASS templates/en-us/sass/Members_today.sass
# NAME Member_Control_today

div.content! { 

  partial '__flash_msg'
  
  mustache 'no_newspaper' do
    p {
      span 
      a( 'Check out some clubs to follow.', :href=>'/clubs/')
    }
  end

  mustache 'newspaper?' do  
    div.newspaper! do
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
  end
  
  
} # === div.content!

partial('__nav_bar')

