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
    nav_bar_li :Hello_list, 'home'
  }
   
    h4 'Egg Timers'
    ul.to_dos {
      nav_bar_li :Timer_old, 'my-egg-timer', 'Old Timer'
      nav_bar_li :Timer_new, 'busy-noise', 'New Timer'
    }

    mustache 'development?' do

      mustache 'logged_in?' do
        h4 'Non-Members'
        ul.non_members {
          nav_bar_li :Member_new, 'sign-up'
        }
      end

      h4 'Members'
      ul.members {
        mustache 'logged_in?' do
          nav_bar_li :Member_account, 'account'
          nav_bar_li :Sessiong_log_out, 'log-out'
        end

        mustache 'not_logged_in?' do
          nav_bar_li :Session_log_in, 'log-in'
        end
      }

      h4 'Stuff To Do'
      ul.to_dos {
          nav_bar_li :Something, 'add-to-do', 'Add to do'
          nav_bar_li :To_dos_today, 'today' 
          nav_bar_li :To_dos_tomorromw, 'tomorrow'
          nav_bar_li :To_dos_this_monthg, 'this-month', 'This Month'
      }

      h4 'Lives'
      ul.lives {
         
          nav_bar_li :Lives_friend, 'friend'
          nav_bar_li :Lives_friend, 'family'
          nav_bar_li :Lives_friend, 'work'
          nav_bar_li :Lives_friend, 'pet-owner', 'Pet Owner'
          nav_bar_li :Lives_friend, 'celebrity'
      }
    
    end # if development?

    h4 'Clubs'
    ul.news {
       
        nav_bar_li :Topic_bubblegum, 'bubblegum', 'Bubblegum Pop'
        nav_bar_li :Topic_child_care, 'child-care', 'Child Care'
        nav_bar_li :Topic_computer, 'computer', 'Computer Use'
        nav_bar_li :Topic_economy, 'economy',  'Economy + War'
        nav_bar_li :Topic_hair, 'hair',     'Skin & Hair'
        nav_bar_li :Topic_housing, 'housing',  'Housing & Apartments'
        nav_bar_li :Topic_health, 'health',   'Pain & Disease'
        nav_bar_li :Topic_preggers, 'preggers', 'Pregnancy'
        nav_bar_li :Topic_salud, 'salud',    'Salud (Español)'
        nav_bar_li :Topic_news, 'news',     'Other Topics'
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
