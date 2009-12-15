save_to('title') { 'LogIn' }

partial('__nav_bar')

div.content! {

  # ================= div.flash_msg =============================
  if the_app.flash_msg?
    partial '__flash_msg'
  end

  h3 'Log-in'
  
  form.log_in_form!( :action=>"/log-in/", :method=>"post" ) {
  
    fieldset {
      label 'Username'
      input.text( :id=>"member_username", :name=>"username", :type=>"text", :value=>'' )
    }
    
    fieldset {
      label 'Password'
      input.text( :id=>"member_password", :name=>"password", :type=>"password", :value=>'' )
    }
    
    div.buttons {
      button.create 'Log-in', :onclick=>"document.getElementById('log_in_form').submit(); return false;" 
    }
    
  } # === form.log_in_form!


} # === div.content!
