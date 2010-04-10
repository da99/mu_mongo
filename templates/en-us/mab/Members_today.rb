# VIEW views/Members_today.rb
# SASS /home/da01/MyLife/apps/megauni/templates/en-us/sass/Member_Control_today.sass
# NAME Member_Control_today

div.content! { 

  partial '__flash_msg'
  
  mustache 'no_newspaper' do
    p {
      span 
      a( 'Check out some clubs to follow.', :href=>'/clubs/')
    }
  end

  mustache 'newspaper' do
    div.message do
      div.body( '{{{compiled_body}}}' )
      div.permalink {
        a('Permalink', :href=>"{{href}}")
      }
    end
  end
  
} # === div.content!

partial('__nav_bar')

