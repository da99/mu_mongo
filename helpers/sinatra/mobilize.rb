

helpers {



  def stop_using_mobile_version
    response.set_cookie('use_mobile_version', :value=>'no', :expires => (Time.now + (60 * 60 * 24 * 365 * 10)) )
  end

  def mobile_request?(path = nil)
    @mobile_request || 
      (request.cookies['use_mobile_version'] && request.cookies['use_mobile_version'] != 'no' ) || 
        (path || request.path_info).strip =~ /\/m\/?$/
  end

  def mobile_path(raw_path)
    return raw_path if !raw_path.respond_to?(:to_s)
    return raw_path.to_s if mobile_request?(raw_path.to_s)
    File.join( raw_path.to_s.strip, 'm/')
  end

  def mobile_path_if_requested(raw_path)
    return raw_path if !mobile_request?
    mobile_path raw_path
  end   

} # === helpers


