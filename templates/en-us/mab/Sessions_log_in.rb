# ~/megauni/views/Session_Control_log_in.rb
# ~/megauni/templates/en-us/sass/Session_Control_log_in.sass
# Session_Control_log_in

partial '__flash_msg'

div.the_form! { 
  
  # ================= div.flash_msg =============================

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


partial('__nav_bar')
