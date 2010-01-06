require 'mustache'

class Base_View < Mustache
	
  attr_reader :not_prefix
  
	def initialize new_app
		@app        = new_app
		@not_prefix = /^not?_/
	end

  def respond_to? raw_name
    meth = raw_name.to_s
    orig = super(meth)
    (return orig) if orig || !meth[@not_prefix]
    
    super( meth_s.sub(@not_prefix, '') )
  end

  def method_missing *args
    meth = args.shift.to_s
    
    if meth[@not_prefix]
      return !send(meth.sub(@not_prefix, ''), *args) 
    end
    
    raise(NoMethodError, "NAME: #{meth.inspect}, ARGS: #{args.inspect}")
  end

  def development?
    The_App.development?
  end

	def url
		@app.request.fullpath
	end

	def mobile_request?
		@app.request.cookies['use_mobile_version'] && 
			@app.request.cookies['use_mobile_version'] != 'no'
	end

	def css_file
		"/stylesheets/English/#{@app.control_name}_#{@app.action_name}.css"
	end

	def head_content
		''
	end

	def loading
		nil
	end

	def site_domain
		The_App::Options::SITE_DOMAIN
	end

	def site_url
		The_App::Options::SITE_URL
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
    @app.logged_in?
  end

  # === FLASH MESSAGES ===

  def flash_msg?
    !!flash_msg
  end

  def flash_msg
    flash_success || flash_errors
  end

  def flash_success
    return nil if !@app.flash_msg.success?
    @flash_success ||= {:msg=>@app.flash_msg.success}
  end

  def flash_errors
    return nil if !@app.flash_msg.errors?
    errs = [@app.flash_msg.errors].flatten
    @flash_errors ||= begin
                        use_plural = errs.size > 1
                        msg = "<ul><li>" + errs.join("</li><li>") + "</li></ul>"
                        { :title  => (use_plural ? 'Errors' : 'Error'),
                          :errors => errs.map {|err| {:err=>err}}
                        }
                      end
  end

  # === NAV BAR ===
   
  def opening_msg
  end

  def site_title
    The_App::Options::SITE_TITLE
  end

	
	private # ======== 

  # From: http://www.codeism.com/archive/show/578
  def w3c_date(date)
   date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end

end # === Base_View
