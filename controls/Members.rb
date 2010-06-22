require 'helpers/Pony'

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

  def GET_account
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
    env['results.owner'] = Member.by_username(un)
    render_html_template
  end

  def GET_life_e un
    env['results.username'] = un
    env['results.owner'] = Member.by_username(un)
    render_html_template
  end

  def GET_life_qa un
    env['results.username'] = un
    env['results.owner'] = Member.by_username(un)
    render_html_template
  end

  def GET_life_status un
    redirect!(request.path_info.sub('status/', 'news/'), 301)
  end

  def GET_life_news un
    env['results.username'] = un
    env['results.owner']    = Member.by_username(un)
    render_html_template
  end

  def GET_life_shop un
    env['results.username'] = un
    env['results.owner'] = Member.by_username(un)
    render_html_template
  end

  def GET_life_predictions un
    env['results.username'] = un
    env['results.owner'] = Member.by_username(un)
    render_html_template
  end

  def GET_life_random un
    env['results.username'] = un
    env['results.owner'] = Member.by_username(un)
    render_html_template
  end
  
  def POST_reset_password
    env['results.email'] = clean_room['email']
    
    begin
      mem       = Member.by_email( clean_room['email'] )
      code      = mem.reset_password
      env['results.reset'] = true
      reset_url = File.join(The_App::SITE_URL, "change-password", code, CGI.escape(mem.data.email), '/')
      Pony.mail(
        :to    =>clean_room['email'], 
        :from  =>The_App::SITE_HELP_EMAIL, 
        :subject=>"#{The_App::SITE_DOMAIN}: Lost Password",
        :body  =>"To change your old password, go to:\n#{reset_url}"
        # :via      => :smtp,
        # :via_options => { 
        #   :authentication => The_App::SMTP_AUTHENTICATION,
        #   :address   => The_App::SMTP_ADDRESS,
        #   :user_name => The_App::SMTP_USER_NAME,
        #   :password  => The_App::SMTP_PASSWORD,
        #   :domain    => The_App::SMTP_DOMAIN
        # }
      )
    rescue Member::Not_Found
    end
      
    render_html_template
  end

  def GET_change_password code, email
    env['results.member'] = Member.by_email(CGI.unescape(email))
    env['results.code']   = code
    env['results.email']  = email
    render_html_template
  end

  def POST_change_password code, email
    mem = Member.by_email(CGI.unescape(email))
    begin
      mem.change_password_through_reset(
        :code=>code, 
        :password=>clean_room[:password], 
        :confirm_password=>clean_room[:confirm_password]
      )
      flash_msg.success = "Your password has been updated."
      redirect! '/log-in/'
    rescue Member::Invalid
      flash_msg.errors = $!.doc.errors
      redirect! "/change-password/#{code}/#{email}/"
    end
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

  def DELETE_delete_account_forever_and_ever
    Member.delete( current_member.data._id, current_member )
    log_out!
    flash_msg.success = "Your account has been deleted forever."
    redirect! '/'
  end

end # === Member_Control

