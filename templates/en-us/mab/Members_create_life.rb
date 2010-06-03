# VIEW views/Members_create_life.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Members_create_life.sass
# NAME Members_create_life

div.content! { 
  
  # ================= div.flash_msg =============================
	

  h3 'Add another username.'
  
  form.form_username_create!(:action=>"/members/", :method=>"post") {
    
    input :type=>'hidden', :name=>'_method', :value=>'put'

    fieldset {
      label 'New Username'
      input.text( :id=>"username_name", :name=>"add_username", :type=>"text", :value=>'{{ session_form_username }}' )
    }

    div.buttons {
      button.create 'Save'
    }

  } # === form.create_account_form!



  
} # === div.content!

partial('__nav_bar')

