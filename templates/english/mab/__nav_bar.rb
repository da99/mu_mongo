div( :id=>"nav_bar" ) { 

  div( :id=>"logo" ) { 
    mustache 'opening_msg'
    mustache 'no_opening_msg' do
      p.nippon { 
        "何とかしてよ" # Please do something
        # "私のユニ" # My Uni
        # "幸せな、脂肪の <br /> ウェブサイト"
      } 
    end
    p.english { 
      mustache 'opening_msg_site_title' 
    }
  }


  ul.help {
    mustache 'nav_help' do
      mustache 'link'
    end
  }
   
    h4 'Egg Timers'
    ul.to_dos {
      mustache 'nav_timers' do
        mustache 'link'
      end
    }

    mustache 'development?' do

      mustache 'logged_in?' do
        h4 'Non-Members'
        ul.non_members {
          nav_bar_li.call '/sign-up/', 'Create Account', :member, :new
        }
      end

      h4 'Members'
      ul.members {
        if the_app.logged_in? 
          nav_bar_li.call '/account/', 'My Account', :account, :show
          nav_bar_li.call '/log-out/', 'Logout', :session, :destroy
        else
          nav_bar_li.call '/log-in/', 'Log-in', :session, :new
        end
      }

      h4 'Stuff To Do'
      ul.to_dos {
        #nav_bar_li.call '/add-to-do/', '+ Add Stuff', :to_dos, :add
        nav_bar_li.call '/today/', 'Today', :to_dos, :today
        nav_bar_li.call '/tomorrow/', 'Tomorrow', :to_dos, :tomorrow
        nav_bar_li.call '/this-month/', 'This Month', :to_dos, :this_month
        #nav_bar_li.call '/my-egg-timer/', 'Old Egg Timer', :egg, :my
        #nav_bar_li.call '/busy-noise/', 'New Egg Timer', :egg, :busy
      }

      h4 'Lives'
      ul.lives {
        nav_bar_li.call '/friend/',    '(9) Friend',    :lives, :friend
        nav_bar_li.call '/family/',    'Family',    :lives, :family
        nav_bar_li.call '/work/',    'Work',    :lives, :worker
        nav_bar_li.call '/romance/',  '(100) Romance',   :lives, :romance
        nav_bar_li.call '/pet-owner/', 'Pet Owner', :lives, :pet_owner
        nav_bar_li.call '/celebrity/', 'Celebrity', :lives, :celebrity
      }
    
    end # if development?

    h4 'Clubs'
    ul.news {
      nav_bar_li.call '/bubblegum/', 'Bubblegum Pop', :topic, :bubblegum
      nav_bar_li.call '/child-care/', 'Child Care',   :topic, :child_care
      nav_bar_li.call '/computer/', 'Computer Use',   :topic, :computer
      nav_bar_li.call '/economy/',  'Economy + War',  :topic, :economy
      nav_bar_li.call '/hair/',     'Skin & Hair',    :topic, :skin
      nav_bar_li.call '/housing/',  'Housing & Apartments', :topic, :housing
      #nav_bar_li.call '/music/',    'Music',          :topic, :music
      nav_bar_li.call '/health/',   'Pain & Disease',         :topic, :health
      nav_bar_li.call '/preggers/', 'Pregnancy',      :topic, :preggers
      nav_bar_li.call '/salud/',    'Salud (Español)', :main, :salud
      #nav_bar_li.call '/sports/',   'Sports',         :topic, :sports
      nav_bar_li.call '/news/',     'Other Topics',    :topic, :news
    }

    # h4 'Pain & Disease'
    # ul.human_body { 
    #   nav_bar_li.call '/arthritis/',  'Arthritis (osteo & rhumatoid)', :topic, :arthritis
    #   nav_bar_li.call '/back-pain/',  'Back Pain',           :topic, :back_pain
    #   nav_bar_li.call '/cancer/',     'Cancer',              :topic, :cancer
    #   nav_bar_li.call '/dementia/',   'Dementia/Alzheirmer', :topic, :dementia
    #   nav_bar_li.call '/depression/', 'Depression',          :topic, :depresssion
    #   nav_bar_li.call '/flu/',        'Flu/Cold',            :topic, :flu
    #   nav_bar_li.call '/heart/',      'Heart & Diabetes',   :topic, :heart
    #   nav_bar_li.call '/hiv/',        'HIV/AIDS/STDs',       :topic, :hiv
    #   nav_bar_li.call '/meno-osteo/', 'Osteoporosis & Menopause',      :topic, :meno_osteo
    #   nav_bar_li.call '/health/',     'Other Health',        :topic, :health
    # }



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
