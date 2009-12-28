class Member_Control
  include Control_Base
    
  # ============= Member Actions ==========================          

  def GET_sign_up 
    render_html_template
  end
            
  def POST 
    log_out! 

    begin

      m = Member.create( current_member, clean_room )
      self.current_member = m
      flash.success_msg = "Your account has been created."
      redirect! '/account/' 
      
    rescue Member::Invalid

      flash.error_msg = $!.doc.errors 
      session[ :form_username  ] = clean_room[:username] 
               
      redirect! '/sign-up/' 
    end
      
  end # == post :create


  # =========================== MEMBER ONLY ==========================================

  # Show account and HTML pages on same view.
  def GET_account 
    render_html_template
  end # == get :show

        
  def PUT 
    begin
      m = Member.update( current_member, clean_room )
      flash.success_msg = "Data has been updated and saved."
      redirect! '/account/' 
    rescue Member::Invalid
      flash.error_msg = $!.doc.errors 
      redirect! '/account/' 
    end
  end # === put :update

end # === Member_Control

