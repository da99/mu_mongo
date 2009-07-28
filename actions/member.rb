controller( :Member ) do

    # ============================= STRANGERS =========================================
    
    get( :new,  "/signup", Member::STRANGER ) 

    
    post( :create,  "/member", Member::STRANGER  ) do
        old_clean = clean_room
        session.clear 
        
        begin
          m = Member.new
          m.changes_from_editor( clean_room )
          m.save  
                            
          flash( :success_msg,  "Your account has been created." )
          session[:member_username] = m.username
          redirect('/admin')
          
        rescue Sequel::ValidationFailed
          session.clear
          flash( :error_msg, m.error_msg )
          flash( :username,  clean_room['username'] )
          flash( :email,  clean_room['email'] )
                   
          redirect('/signup', :status => 302)
        end
        
    end # == post :create
    
    
    # =========================== MEMBER ONLY ==========================================
    
    # Show account and HTML pages on same view.
    get( :show, "/admin", Member::MEMBER ) do
      @slice_locations = []
      render_mab
    end # == get :show
    
          
    put( :update, "/member",  Member::MEMBER)  do
        current_member.changes_from_editor( clean_room, current_member )
        begin
            current_member.save
            render_success_msg( "Your account has been updated." )
        rescue Sequel::ValidationFailed
            render_error_msg( current_member.error_msg )
        end
    end # === put :update


    put( :trash, "/trash", Member::MEMBER )  do
        current_member.trash_it!
        flash( :success_msg,  "Your account has been trashed." )
    end # === put :trash


end # === class Member

