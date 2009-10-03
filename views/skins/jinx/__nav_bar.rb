div( :id=>"nav_bar" ) { 

  div( :id=>"logo" ) { 
    if @opening_msg
      self << @opening_msg
    else
      p.nippon { 
        "何とかしてよ" # Please do something
        # "私のユニ" # My Uni
        # "幸せな、脂肪の <br /> ウェブサイト"
      } 
    end
    p.english { "MEGA UNI" }
  }


  

    selected = Proc.new { |t| 
      li.selected {
        span t
      }
    }

    unselected = Proc.new { |t,u|
      li {
        a t, :href=> the_app.urlize( u )
      }
    }

    nav_bar_li = Proc.new { |path, text, c_name, a_name, show| 
      show_it = case show
        when :if_member
          the_app.logged_in?
        when :if_not_member
          !the_app.logged_in?
        else
          true
      end

      next if !show_it 

      if the_app.current_action[:controller] == c_name && the_app.current_action[:action] == a_name
        selected.call text
      else
        unselected.call text, path 
      end     
    }

    ul.main {
      nav_bar_li.call '/', 'Home', :main, :show
      nav_bar_li.call '/help/', 'Help', :main, :help
    }
    
    if !the_app.logged_in?
      h4 'Non-Members'
      ul.non_members {
        nav_bar_li.call '/sign-up/', 'Create Account', :member, :new
      }
    end

    h4 'Members'
    ul.members {
      if the_app.logged_in?
        nav_bar_li.call '/log-out/', 'Logout', :session, :destroy   
        nav_bar_li.call '/switch_username/', 'Switch Username', :member, :switch_username
        nav_bar_li.call '/account/', 'My Account', :account, :show
      else
        nav_bar_li.call '/log-in/', 'Log-in', :session, :new
      end
    }

    h4 'Egg Timers'
    ul.egg_timers { 
      nav_bar_li.call '/my-egg-timer/', 'Old', :egg, :my
      nav_bar_li.call '/busy-noise/', 'New', :egg, :busy
    }

    h4 'Main Topics'
    ul.news {
      nav_bar_li.call '/economy/', 'Economy + War',   :news, :economy
      nav_bar_li.call '/music/',   'Music',           :news, :music
      nav_bar_li.call '/sports/',  'Sports',          :news, :sports
      nav_bar_li.call '/hearts/',  'Hearts',          :news, :index
    }

    h4 'Anti-Aging'
    ul.human_body { 
      nav_bar_li.call '/salud/',      'Salud (Espanol)',     :main,   :salud
      nav_bar_li.call '/arthritis/',  'Arthritis (osteo & rhumatoid)', :health, :arthritis
      nav_bar_li.call '/flu/',        'Flu/Cold',            :health, :flu
      nav_bar_li.call '/cancer/',     'Cancer',              :health, :cancer
      nav_bar_li.call '/hiv/',        'HIV/AIDS/STDs',       :health, :hiv
      nav_bar_li.call '/depression/', 'Depression',          :health, :depresssion
      nav_bar_li.call '/dementia/',   'Dementia/Alzheirmer', :health, :dementia
      nav_bar_li.call '/menopause/',  'Menopause/Hair',      :health, :menopause
      nav_bar_li.call '/health/',     'Other Health',        :health, :other
    }


      # ['/apartments/', 'Houses & Apartments', :housing, :index],
      # ['/lingua/', 'Translate', :lingua, :index],
      # ['/dating/', 'Lunch Date', :dating, :index],
      # ['/pets/', 'Pets & Mascots', :pets, :index],
      # ['/secrets/', 'Secrets', :health, :index],
      # ['/make-overs/', 'Make-overs', :health, :makeovers],
      # Home/Apartment.
      # 
      # Office Help.
      #  Daily Summary.
      #  To-Dos.
      #  Projects
      #  Calendar
      #  Create Global To-Do List.
  
} # === div.nav_bar!
