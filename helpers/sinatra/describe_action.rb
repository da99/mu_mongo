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

} # === helpers
