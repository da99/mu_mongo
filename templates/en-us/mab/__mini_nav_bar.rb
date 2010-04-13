# ~/megauni/views/Base_View.rb
# ~/megauni/templates/en-us/sass/layout.sass

div( :id=>"nav_bar" ) { 

  div( :id=>"logo" ) { 
    p.english { 
      a '{{site_title}}', :href=>'/'
    }
    p.nippon {
      "を単一化します" # Unify
    } 
  }

  ul {
    
    nav_bar_li :Hello, 'help'
    
    mustache 'logged_in?' do
      nav_bar_li :Session_Control, 'log-out', 'Log-out'
      nav_bar_li :Members, '/today/', '[ Today ]'
      nav_bar_li :Members, '/account/', '[ Account ]'
    end  
    
    mustache 'not_logged_in?' do
      nav_bar_li :Session_Control, 'log-in', 'Log-in'
      nav_bar_li :Member_Control, 'create-account', 'Join'
    end
    
  }

  h4 'Lives'
  ul {
    mustache 'logged_in?' do
        mustache 'username_nav' do
          mustache 'selected' do
            nav_bar_li_selected '{{username}}'
          end
          mustache 'not_selected' do
            nav_bar_li_unselected '{{username}}', '{{href}}'
          end
        end
        nav_bar_li :Members, :create_life, "/create-life/", "[ Create Life ]"
    end
  }

  h4 'Clubs'
  ul {
    li {
      nav_bar_li :Clubs, :list, '/clubs/', '[ View All ]'
    }
    mustache 'logged_in?' do
      nav_bar_li :Clubs, :create, '/clubs/create/', '[ Create ]'
    end
  } # === ul

  
} # === div.nav_bar!
