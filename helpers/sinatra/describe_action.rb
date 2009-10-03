helpers {

  def current_action
      @current_action_props
  end 
                
  def describe(c_name, a_name, *args)
    @current_action_props = {  :action => a_name.to_sym, 
                      :path=>request.path_info, 
                      :http_verb=>request.request_method, 
                      :controller =>c_name.to_sym }.freeze
  end

  def protected_for( *args )
    level, c_name, a_name = args
    describe c_name, a_name
    current_action[:perm_level] = level
    check_creditials!
    yield
  end
          
  def strigify_proc( raw_proc )
      raw_proc.to_ruby.gsub( /^proc \{|\}$/, '' )
  end 

  def content_xml_utf8
    content_type :xml, :charset => 'utf-8'
  end

  def robot_agent?
    env['HTTP_USER_AGENT'] && 
      (env['HTTP_USER_AGENT']['Googlebot'] ||
       env['HTTP_USER_AGENT']['Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 4.0; obot)'])
  end

} # === helpers
