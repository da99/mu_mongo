require 'mustache'

class Bunny_Mustache < Mustache
	
  attr_reader :not_prefix
	def initialize new_app
		@app = new_app
    @not_prefix =  /^not?_/
	end

  def respond_to? raw_meth_name
    
    orig = super(raw_meth_name)
    return( orig ) if orig

    meth_name = raw_meth_name.to_s
    return( orig ) if not meth_name[@not_prefix]

    orig_meth        = meth_name.sub(@not_prefix, '')
    orig_meth_exists = super(orig_meth)
    return orig_meth_exists if not orig_meth_exists

    true
    
  end

  def method_missing *args
    meth = args.shift.to_s
    return(super(meth, *args)) unless meth =~ @not_prefix
    
    orig_meth = meth.sub(@not_prefix, '')
    return(super(meth, *args)) unless methods.include?(orig_meth)

    !(send(orig_meth, *args))
  end

  def development?
    The_Bunny_Farm.development?
  end

	def url
		@app.request.fullpath
	end

	def mobile_request?
		@app.request.cookies['use_mobile_version'] && 
			@app.request.cookies['use_mobile_version'] != 'no'
	end

	def css_file
		"/stylesheets/English/#{@app.controller_name}_#{@app.action_name}.css"
	end

	def head_content
		''
	end

	def loading
		nil
	end

	def site_domain
		The_Bunny_Farm::Options::SITE_DOMAIN
	end

	def site_url
		The_Bunny_Farm::Options::SITE_URL
	end
	
	def js_epoch_time raw_i = nil
		i = raw_i ? raw_i.to_i : Time.now.utc.to_i
    i * 1000
	end

	def copyright_year
		[2009,Time.now.utc.year].uniq.join('-')
	end

  # === META ====

	def meta_description
	end

	def meta_keywords
	end

  def meta_cache
  end

	def javascripts
	end

  def logged_in?
    nil #@app.logged_in?
  end

  # === FLASH MESSAGES ===

  def flash_msg?
    nil # !!(@app.flash.success_msg || @app.flash.error_msg)
  end

  def flash_msg
    return nil if not flash_msg?

    if @app.flash.success_msg
      {:class_name=>'success_msg', :title=>'Success', :msg=>@app.flass.success_msg}
    else
      title = @app.flash.error_msg.to_s["\n"] ?
      'Errors' :
      'Error'
      {:class_name=>'error_msg', :title=>title, :msg=>@app.flass.error_msg}
    end
  end

  # === NAV BAR ===
   
  def opening_msg
  end

  def site_title
    The_Bunny_Farm::Options::SITE_TITLE
  end

	
	private # ======== 

  # From: http://www.codeism.com/archive/show/578
  def w3c_date(date)
   date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end

end # === Bunny_Mustache
