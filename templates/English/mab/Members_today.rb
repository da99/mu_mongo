# VIEW views/Member_Control_today.rb
# SASS /home/da01/MyLife/apps/megauni/templates/English/sass/Member_Control_today.sass
# NAME Member_Control_today

div.content! { 

  h4 'Create a Club'

  form(:id=>'form_clubs_create', :action=>"/clubs/", :method=>"post") {
    fieldset {
      label 'Title:'
      input :name=>'title', :id=>'create_club_title', :type=>'text', :value=>''
    }
    fieldset {
      label 'Filename:'
      input :name=>'filename', :id=>'create_club_filename', :type=>'text', :value=>''
    }
    fieldset {
      label 'Description:'
      textarea '', :name=>'teaser', :id=>'create_club_teaser'
    }
    div.buttons {
      button 'Save'
    }
  }
  
} # === div.content!

partial('__nav_bar')

