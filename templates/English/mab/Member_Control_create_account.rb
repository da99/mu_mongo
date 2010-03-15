# ~/megauni/views/Member_Control_create_account.rb
# ~/megauni/templates/English/sass/Member_Control_create_account.sass
# Member_Control_create_account 

div.content! { 
  
  # ================= div.flash_msg =============================
	partial '__flash_msg' 


  h3 'Create a New Account'
  
  form.create_account_form!(:action=>"/member/", :method=>"post") {
    
    fieldset {
      label 'Username'
      input.text( :id=>"username_name", :name=>"username", :type=>"text", :value=>'{{ session_form_username }}' )
    }
    
    fieldset {
      label 'Password'
      input.text( :id=>"password", :name=>"password", :type=>"password", :value=>'' )
    }
    
    fieldset {
      label { span 'Confirm Password'  }
      input.text( :id=>"confirm_password", :name=>"confirm_password", :type=>"password", :value=>'' )
    }

    div.buttons {
      button.create 'Create My New Account', :onclick=>"document.getElementById('create_account_form').submit(); return false;" 
    }

  } # === form.create_account_form!

  
} # === div.content!

partial('__nav_bar')

