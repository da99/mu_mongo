
# ============= Member Actions ==========================          

get( "/sign\-up/" ) do
  require_ssl!
  controller :member
  action :new
  render_mab
end

          
post( "/member/" ) do
  log_out! 

  begin

# require 'rubygems'; require 'ruby-debug'; debugger


    m = Member.create( current_member, clean_room )
    self.current_member = m
    flash.success_msg = "Your account has been created."
    redirect('/account/')
    
  rescue Member::Invalid

    flash.error_msg = to_html_list( $!.doc.errors )
    session[ :form_username  ] = clean_room[:username] 
             
    redirect('/sign-up/')
  end
    
end # == post :create


# =========================== MEMBER ONLY ==========================================

# Show account and HTML pages on same view.
get( "/account/" ) do
  require_log_in!
  controller :account
  action :show
  render_mab
end # == get :show

      
put( "/member/" )  do
  begin
    m = Member.update( current_member, clean_room )
    flash.success_msg = "Data has been updated and saved."
    redirect('/account/')
  rescue Member::Invalid
    flash.error_msg = to_html_list($!.doc.errors)
    redirect('/account/')
  end
end # === put :update


__END__

configure do
  restafarize :member do
    creator :STRANGER, :password
    updator :self,    :password
    updator :ADMIN,  :security_level , :redirect => '/account/'
  end
end




