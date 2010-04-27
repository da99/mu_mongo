require 'mustache'
require 'loofah'
FIND_URLS = %r~(http://[^\/]{1}[A-Za-z0-9\@\#\&\/\-\_\?\=\.]+)~

class Array
  
  def map_html_menu &blok
    
    map { |orig|
      raw_results = blok.call(orig)
      
      selected, attrs = if raw_results.is_a?(Array)
        assert_size raw_results, 2
        raw_results
      else
        [raw_results, {}]
      end

      add_attrs = {:selected=>selected, :not_selected=>!selected}
      
      if orig.is_a?(Hash)
        orig.update add_attrs
      else
        attrs.update add_attrs
      end
    }
  end

end # === class Array


class Base_View < Mustache
  
  attr_reader :not_prefix
  
  def initialize new_app
    @app        = new_app
    @not_prefix = /^not?_/
    @cache = {}
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

  def development_or_test?
    The_App.development? || The_App.test?
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

  def base_filename
    "#{@app.control_name}_#{@app.action_name}"
  end

  def time_i
    Time.now.utc.to_i
  end
  
  def lang
    'en-us'
  end

  def css_file
    "/stylesheets/#{lang}/#{base_filename}.css"
  end

  def head_content
    ''
  end

  def loading
    nil
  end

  # === Members ===
  
  def current_member
    @app.current_member
  end

	def current_member_lang
		current_member.data.lang
	end

  def current_member_usernames
    @cache[:current_member_usernames] ||= begin
                                            if @app.current_member
                                              @app.current_member.usernames.map { |un| 
                                                {:filename=>un, :username=>un}
                                              }
                                            else
                                              []
                                            end
                                          end
  end

  def single_username?
    current_member_usernames.size == 1
  end

  def first_username
    current_member.usernames.first
  end

  def single_username
    current_member_usernames.first
  end

  def multiple_usernames?
    current_member_usernames.size > 1
  end

  def multiple_usernames
    return [] if single_username?
    current_member_usernames
  end

  # === Html ===

  def http_referer
    @app.env['HTTP_REFERER'].to_s.gsub("'", " ")
  end

  def include_tracking?
    @app.env['HTTP_HOST'] =~ /megauni/
  end

	def current_member_username
		@app.env['results.username']
	end
  
	def mini_nav_bar?
    false
  end

  def username_nav

    @cache[:username_nav] ||= begin
                                c_name = @app.control_name
                                a_name = @app.action_name
                                life_page = (c_name == :Members && a_name == 'lives')
                                current_member_usernames.map { |raw_un|
                                  un = raw_un[:username]
                                  { :selected=> (life_page && current_member_username == un), 
                                    :username=>un, 
                                    :href=>"/lives/#{un}/",
                                  :not_selected=> !(life_page && current_member_username == un)
                                  }
                                }
                              end
  end

  def compile_messages( mess_arr )
    mess_arr.map { |doc|
			doc['href'] = "/mess/#{doc['_id']}/"
      doc['compiled_body'] = from_surfer_hearts?(doc) ? doc['body'] : auto_link(doc['body'])
			doc
		}
  end

  def from_surfer_hearts?(doc)
    doc['created_at'] < '2010-01-01 01:01:01'
  end

  def auto_link raw_str
    str = raw_str.to_s 
    Loofah::Helpers.sanitize(
      str.gsub(FIND_URLS, "<a href=\"\\1\">\\1</a>")
    ).gsub(/\r?\n/, "<br />")
  end

  def default_javascripts
    [ {
      :src=>'/js/vendor/jquery-1.4.2.min.js' 
    },
      {:src=>"/js/pages/#{base_filename}.js"}]
  end

	def languages
		@cache[:languages] ||= begin
														 Couch_Plastic::LANGS.map { |k,v| 
															{:name=>v, :filename=>k, :selected=>(k=='en-us'), :not_selected=> (k != 'en-us')}
														 }.sort { |x,y| 
															x[:name] <=> y[:name]
														 }
													 end
	end

  def site_domain
    The_App::SITE_DOMAIN
  end

  def site_url
    The_App::SITE_URL
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
    The_App::SITE_TITLE
  end

  def site_tag_line
    The_App::SITE_TAG_LINE
  end

  
  private # ======== 

  # From: http://www.codeism.com/archive/show/578
  def w3c_date(str_or_date)
    date = case str_or_date
    when String
      require 'time'
      Time.parse str_or_date
    when Time
      str_or_date
    end
    date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end

end # === Base_View
