
module Bunny_Response
  
  def valid_header_keys
    @valid_header_keys ||= (@header.keys + ['Content-Disposition', 'Content-Type', 'Content-Length']).uniq
  end

  def add_valid_header_key raw_key
    new_key = raw_key.to_s.strip
    @valid_header_keys = (valid_header_keys + [raw_key]).uniq
    new_key
  end

  def valid_statuses
    @valid_statuses ||= (100..600).to_a
  end

  def set_status raw_val
    
    new_val = raw_val.to_i
    return(@status = new_val) if valid_statuses.include?(new_val)
    
    raise ArgumentError, "Invalid status: #{raw_val.inspect}"
  end

  def set_header key, raw_val 
    if !valid_header_keys.include?(key)
      raise ArgumentError, "Invalid header key: #{key.inspect}"
    end
    @header[key] = raw_val.to_s
  end

  def set_body raw_body
    new_body = raw_body.to_s
    set_header 'Content-Length', new_body.size
    @body = new_body
  end

  def set_as_plain_text
    set_header 'Content-Type', 'text/plain'
  end

  # Set the Content-Type of the response body given a media type or file
  # extension.
  def set_content_type(mime_type, params={})
    if params.any?
      params = params.collect { |kv| "%s=%s" % kv }.join(', ')
      set_header 'Content-Type', [mime_type, params].join(";")
    else
      set_header 'Content-Type', mime_type
    end
  end

  # Set the Content-Disposition to "attachment" with the specified filename,
  # instructing the user agents to prompt to save.
  def set_attachment(filename)
    set_header 'Content-Disposition', 'attachment; filename="%s"' % File.basename(filename)
  end

end # === Rack::Response

Method_Air_Bags.collide? Bunny_Response, Rack::Response

class Rack::Response
	include Bunny_Response
end # === Rack::Response
