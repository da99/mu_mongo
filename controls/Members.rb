class Members
  include Base_Control
    
  # ============= Member Actions ==========================          

  def GET_create_account 
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
               
      redirect! '/create-account/' 
    end
      
  end # == post :create


  # =========================== MEMBER ONLY ==========================================

  def GET_today
    require_log_in!
    render_html_template
  end

  def GET_account 
    require_log_in!
    render_html_template
  end 
        
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

