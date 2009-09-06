div( :id=>"nav_bar" ) { 

  div( :id=>"logo" ) { 
    if @opening_msg
      self << @opening_msg
    else
      p.nippon { "私のユニ" } # "幸せな、脂肪の <br /> ウェブサイト"}
    end
    p.english { "MEGA UNI" }
  }


  ul { 
  
    [ 
      ['/', 'Home', :main, :show], 
      ['/hearts', 'Hearts', :heart, :show],
      # ['/egg', 'Timer + Alarm', :egg, :show],
      ['/salud', 'Salud (Health)', :main, :salud] ,
      ['/my-egg-timer', 'My Egg Timer', :egg, :my] ,
      ['/busy-noise', 'Busy Noise Timer', :egg, :busy],
      ['/help', 'Help', :main, :help]
      #['/sign-up', 'Sign-up', :member, :new],
      #['/log-in', 'Log-in', :session, :new]
    ].each { |path, text, c_name, a_name|
      if the_app.current_action[:controller] == c_name && the_app.current_action[:action] == a_name
        li.selected { 
          span text
        }        
      else
        li {
          if [:heart, :main].include?(c_name) && [:show, :salud, :help].include?(a_name)
            a text, :href=> the_app.urlize( the_app.mobile_path_if_requested(path) )
          else
            a text, :href=> the_app.urlize( path )
          end
        }
      end
    } # === each
       
    
  } # === ul

  
} # === div.nav_bar!
