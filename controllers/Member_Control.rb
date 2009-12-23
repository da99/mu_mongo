class Member_Control
    
  # ============= Member Actions ==========================          

  def GET_sign_up the_stage
    the_stage.render_html_template
  end
            
  def POST the_stage
    the_stage.log_out! 

    begin

      m = Member.create( current_member, clean_room )
      self.current_member = m
      the_stage.flash.success_msg = "Your account has been created."
      the_stage.redirect! '/account/' 
      
    rescue Member::Invalid

      the_stage.flash.error_msg = $!.doc.errors 
      the_stage.session[ :form_username  ] = the_stage.clean_room[:username] 
               
      the_stage.redirect! '/sign-up/' 
    end
      
  end # == post :create


  # =========================== MEMBER ONLY ==========================================

  # Show account and HTML pages on same view.
  def GET_account the_stage
    the_stage.render_html_template
  end # == get :show

        
  def PUT the_stage
    begin
      m = Member.update( current_member, clean_room )
      the_stage.flash.success_msg = "Data has been updated and saved."
      the_stage.redirect! '/account/' 
    rescue Member::Invalid
      the_stage.flash.error_msg = $!.doc.errors 
      the_stage.redirect! '/account/' 
    end
  end # === put :update

end # === Member_Control

