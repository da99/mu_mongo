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
    mustache 'nav_bar' do
      nav_bar 'home'
    end
  }
   
    h4 'Egg Timers'
    ul.to_dos {
      mustache 'nav_bar' do
        nav_bar 'my-egg-timer', 'Old Timer'
        nav_bar 'busy-noise', 'New Timer'
      end
    }

    mustache 'development?' do

      mustache 'logged_in?' do
        h4 'Non-Members'
        ul.non_members {
          mustache 'nav_bar' do
            nav_bar 'sign-up'
          end
        }
      end

      h4 'Members'
      ul.members {
        mustache 'logged_in?' do
          mustache 'nav_bar' do
            nav_bar 'account'
            nav_bar 'log-out'
          end
        end

        mustache 'not_logged_in?' do
          mustache 'nav_bar' do
            nav_bar 'log-in'
          end
        end
      }

      h4 'Stuff To Do'
      ul.to_dos {
        mustache 'nav_bar' do
          nav_bar 'add-to-do', 'Add to do'
          nav_bar 'today' 
          nav_bar 'tomorrow'
          nav_bar 'this-month', 'This Month'
        end
      }

      h4 'Lives'
      ul.lives {
        mustache 'nav_bar' do
          nav_bar 'friend'
          nav_bar 'family'
          nav_bar 'work'
          nav_bar 'pet-owner', 'Pet Owner'
          nav_bar 'celebrity'
        end
      }
    
    end # if development?

    h4 'Clubs'
    ul.news {
      mustache 'nav_bar' do
        nav_bar 'bubblegum', 'Bubblegum Pop'
        nav_bar 'child-care', 'Child Care'
        nav_bar 'computer', 'Computer Use'
        nav_bar 'economy',  'Economy + War'
        nav_bar 'hair',     'Skin & Hair'
        nav_bar 'housing',  'Housing & Apartments'
        nav_bar 'health',   'Pain & Disease'
        nav_bar 'preggers', 'Pregnancy'
        nav_bar 'salud',    'Salud (Español)'
        nav_bar 'news',     'Other Topics'
      end
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
