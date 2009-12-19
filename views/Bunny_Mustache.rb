class Bunny_Mustache < Mustache
	
	def initialize new_app
		@app = new_app
	end

  def development?
    The_Bunny.development?
  end

  def site_title
    The_Bunny::Options::SITE_TITLE
  end

	def site_domain
		The_Bunny::Options::SITE_DOMAIN
	end
	
	def js_epoch_time raw_i = nil
		i = raw_i ? raw_i.to_i : Time.now.utc.to_i
    i * 1000
	end

	def copyright_year
		[2009,Time.now.utc.year].uniq.join('-')
	end

	def meta_description
	end

	def meta_keywords
	end

	def javascripts
	end

  def logged_in?
    false
  end


  def flash_msg?
    !!(@app.flash.success_msg || @app.flash.error_msg)
  end

  def success_msg
    @app.flash.success_msg
  end

  def error_or_errors
    @app.flash.error_msg.to_s["\n"] ?
      'Errors' :
      'Error'
  end
  alias_method :errors_or_error, :error_or_errors

  def error_msg
    @app.flash.error_msg
  end

  def error_msg_li
    @app.flash.error_msg.split('</li>').size > 2 ? 
      'Errors' : 
      'Error'
  end

  # === NAV BAR ===
   
  def opening_msg
  end

  def no_opening_msg
    !!opening_msg
  end

  def selected t
      li.selected {
        span t
      }
  end

  def unselected t, u
      li {
        a t, :href=> u 
      }
  end

  def opening_msg_site_title
    if @app.request.path == '/'
      The_Bunny::Options::SITE_TITLE
    else
      %~<a href="/">#{The_Bunny::Options::SITE_TITLE}</a>~
  end
   
  def nav_bar_li path, text, c_name, a_name, show

      show_it = case show
        when :if_member
          the_app.logged_in?
        when :if_not_member
          !the_app.logged_in?
        else
          true
      end

      return if !show_it 

      if the_app.controller == c_name && the_app.action == a_name
        selected.call text
      else
        unselected.call text, path 
      end     
      
  end

  def nav_bar_li_slash 
    nav_bar_li '/', 'Home', :main, :show
  end

  def nav_bar_li_slash_help
    nav_bar_li '/help/', 'Help', :main, :help
  end

      nav_bar_li.call '/my-egg-timer/', 'Old', :egg, :my
      nav_bar_li.call '/busy-noise/', 'New', :egg, :busy

end # === Bunny_Mustache
