require 'mustache'

class Base_View < Mustache
	
  attr_reader :not_prefix
  
	def initialize new_app
		@app        = new_app
		@not_prefix = /^not?_/
	end

  def respond_to? raw_name
    meth         = raw_name.to_s
    
    orig         = super(meth)
    (return orig) if orig 
    
    not_meth     = meth.sub(@not_prefix, '') 
    (return super( not_meth )) if meth[@not_prefix] 
    
    orig
  end

  def method_missing *args
    meth = args.shift.to_s
    
    if meth[@not_prefix]
      result = send(meth.sub(@not_prefix, ''), *args) 
      return result_empty?(result)
    end
    
    raise(NoMethodError, "NAME: #{meth.inspect}, ARGS: #{args.inspect}")
  end

  def result_empty? result
    return result.empty? if result.respond_to?(:empty?)
    return result.zero? if result.is_a?(Fixnum)
    return result.strip.empty? if result.is_a?(String)
    !result
  end

  def development?
    The_App.development?
  end

	def url
		@app.request.fullpath
	end

  def href_for obj, action = :read
    data       = obj.is_a?(Hash) ? obj : obj.data.as_hash
    case action
      when :edit
        File.join '/', data[:data_model].downcase, '/edit', data[:_id]
      when :read
        class_name = obj.is_a?(Hash) ? obj[:data_model] : obj
        case class_name 
          when News, 'News'
            filename, obj_type, *rest = data[:_id].split('-')
            File.join '/', filename, obj_type, rest.join('-'), '/' 
          when Club, 'Club'
            File.join '/', data[:filename]
          else
            raise "Unknown Class for Object: #{obj.inspect}"
        end
      else
        raise "Unknown action: #{action.inspect}"
    end
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
