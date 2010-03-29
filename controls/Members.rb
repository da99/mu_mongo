class Members
  include Base_Control
    
  # ============= Member Actions ==========================          

  def GET_create_account 
    render_html_template
  end
            
  def POST 
    log_out! 

    begin
      clean_room[:add_life] ||= 'friend'
      m = Member.create( current_member, clean_room )
      self.current_member = m
      flash_msg.success = "Your account has been created."
      redirect! '/today/' 
      
    rescue Member::Invalid

      flash_msg.errors= $!.doc.errors 
      session[ :form_username  ] = clean_room[:username] 
               
      redirect! '/create-account/' 
    end
      
  end # == post :create


  # =========================== MEMBER ONLY ==========================================

  def GET_today
    require_log_in!
    render_html_template
  end

  # def GET_account 
  #   require_log_in!
  #   render_html_template
  # end 
        
  def PUT 
    begin
      m = Member.update( current_member, clean_room )
      flash_msg.success = "Data has been updated and saved."
      redirect! '/account/' 
    rescue Member::Invalid
      flash_msg.errors= $!.doc.errors 
      redirect! '/account/' 
    end
  end # === put :update

end # === Member_Control

