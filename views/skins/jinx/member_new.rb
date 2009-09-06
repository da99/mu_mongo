save_to('title') { 'Sign-up' }


partial('__nav_bar')


div.content! { 

  # ================= div.flash_msg =============================
  partial '__flash_msg' if the_app.flash_msg?


  h3 'Create a New Account'
  
  form.single.signup_form!(:action=>"/member", :method=>"post") {
    
    fieldset {
      label 'Username'
      input.text( :id=>"username_name", :name=>"username[name]", :type=>"text", :value=>the_app.flash(:username) )
    }
    
    fieldset {
      label 'Password'
      input.text( :id=>"password", :name=>"password", :type=>"password" )
    }
    
    fieldset {
      label { span 'Confirm Password'  }
      input.text( :id=>"confirm_password", :name=>"confirm_password", :type=>"password" )
    }

    div.buttons {
      button.create 'Create My New Account', :onclick=>"document.getElementById('signup_form').submit(); return false;" 
    }

  } # === form.signup_form!

  
} # === div.content!










