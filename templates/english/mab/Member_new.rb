save_to('title') { 'Sign-up' }


partial('__nav_bar')


div.content! { 

  # ================= div.flash_msg =============================
  mustache 'flash_msg?' do
		partial '__flash_msg' 
	end


  h3 'Create a New Account'
  
  form.sign_up_form!(:action=>"/member/", :method=>"post") {
    
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
      button.create 'Create My New Account', :onclick=>"document.getElementById('sign_up_form').submit(); return false;" 
    }

  } # === form.sign_up_form!

  
} # === div.content!









