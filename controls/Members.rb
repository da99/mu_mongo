require 'pony'

class Members
  include Base_Control
    
  # ============= Member Actions ==========================          

  def GET_create_account 
    render_html_template
  end

  def GET_create_life
    require_log_in!
    render_html_template
  end
            
  def POST_create
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

  def GET_lives username
    env['results.username'] = username
    require_log_in!
    render_html_template
  end

  def GET_life un
    env['results.username'] = un
    env['results.member'] = Member.by_username(un)
    render_html_template
  end
	
	def POST_reset_password
		env['results.email'] = clean_room['email']
		
		begin
			mem       = Member.by_email( clean_room['email'] )
			code      = mem.reset_password
			env['results.reset'] = true
			reset_url = File.join(The_App::SITE_URL, "reset-password", code)
			Pony.mail(
				:to=>clean_room['email'], 
				:from=>The_App::SITE_HELP_EMAIL, 
				:subject=>"#{The_App::SITE_DOMAIN}: Lost Password",
				:body=>"To change your old password, go to: #{reset_url}",
				:via      => :smtp,
			  :via_options => { 
					:address   => 'smtp.webfaction.com',
				  :user_name => The_App::SMTP_USER_NAME,
					:password => The_App::SMTP_PASSWORD
				}
			)
		rescue Member::Not_Found
		end
			
    render_html_template
	end
        
  def PUT_update
    begin
      m = Member.update( current_member.data._id, current_member, clean_room )
      flash_msg.success = "Data has been updated and saved."
      if clean_room['add_username']
        redirect! "/lives/#{m.clean_data.add_username}/"
      else
        redirect! '/today/'
      end
    rescue Member::Invalid
      flash_msg.errors= $!.doc.errors 
      session[:add_username] = clean_room['add_username']
      redirect! '/today/' 
    end
  end # === put :update

end # === Member_Control

