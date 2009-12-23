# ~/megauni/views/Session_log_in.rb
# ~/megauni/templates/english/sass/Session_log_in.sass
# Session_log_in


div.content! { 
  
  # ================= div.flash_msg =============================
  partial '__flash_msg'

  div.block do 
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
  end

} # === div.content!


partial('__nav_bar')
