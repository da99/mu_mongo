save_to('title') { 'Login' }

partial('__nav_bar')

div.content! {

  # ================= div.flash_msg =============================
  if the_app.flash_msg?
    partial '__flash_msg'
  end

  h3 'Log-in'
  
  form.single.login_form!( :action=>"/log-in", :method=>"post" ) {
  
    fieldset {
      label 'Username'
      input.text( :id=>"member_username", :name=>"username", :type=>"text" )
    }
    
    fieldset {
      label 'Password'
      input.text( :id=>"member_password", :name=>"password", :type=>"password" )
    }
    
    div.buttons {
      button.create 'Log-in', :onclick=>"document.getElementById('login_form').submit(); return false;" 
    }
    
  } # === form.login_form!


} # === div.content!
