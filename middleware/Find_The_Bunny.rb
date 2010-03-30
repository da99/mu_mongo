class Find_The_Bunny
  Old_Topics = %w{
    arthritis
    back_pain
    cancer
    child_care
    computer
    dementia
    depression
    economy
    flu
    hair
    health
    heart
    hiv
    housing
    meno_osteo
    news
    preggers
  }
  def initialize new_app
    @app = new_app
    @url_aliases = [
      [%r!\A/mess/([a-zA-Z\d]+)! , { :controller => Messages, :action_name => 'by_id' } ],
      [%r!\A/clubs/([a-zA-Z0-9\-\_\+]+)/by_label/([a-zA-Z0-9\-\+\_]+)! , {:controller=>Messages, :action_name=>'by_label'}],
      [%r!\A/clubs/([a-zA-Z0-9\-\_\+]+)/by_date/\Z! , {:controller=>Messages, :action_name=>'by_date'}],
      [%r!\A/clubs/([a-zA-Z0-9\-\_\+]+)/by_date/(\d+)/\Z! , {:controller=>Messages, :action_name=>'by_date'}],
      [%r!\A/clubs/([a-zA-Z0-9\-\_\+]+)/by_date/(\d+)/(\d+)/\Z! , {:controller=>Messages, :action_name=>'by_date'}],
      [%r!\A/clubs/(#{Old_Topics.join('|')})/\Z! , {:controller=>Clubs, :action_name=>'by_old_id'}],
      [%r!\A/clubs/([a-zA-Z0-9\-\_\+]+)/\Z! , {:controller=>Clubs, :action_name=>'by_id'}]
    ]
  end

  def call new_env
    
    new_env['the.app.meta'] ||= {}
    http_meth = new_env['REQUEST_METHOD'].to_s
    results = @url_aliases.detect { |k,v| 
      if new_env['PATH_INFO'] =~ k
        new_env['the.app.meta'][:control]       = v[:controller]
        new_env['the.app.meta'][:http_method] = v[:http_method] || http_meth
        new_env['the.app.meta'][:action_name]   = v[:action_name] || http_meth
        new_env['the.app.meta'][:args]          = $~.captures
      end
    }

    results ||= The_App.controls.detect { |control|

      raw_pieces = new_env['PATH_INFO'].strip_slashes.split('/')

      pieces = if raw_pieces.empty?
                 [http_meth, 'list']
               else
                 [http_meth, raw_pieces].flatten
               end
      
      # Check if first piece is part of a Control.
      if pieces[1] 
        c_name = pieces[1].split('_').map(&:capitalize).join('_') 
        if c_name === control.to_s || "#{c_name}s" === control.to_s
          pieces.delete_at(1)
        end
      end

      # Loop through pieces, combining them with an underscore 
      # until the combination, matches a method name of the
      # control, along with argument count.
      pieces.dup.inject([]) do |a_name_arr, segment|
        
        a_name_arr << pieces.shift.gsub(/[^a-zA-Z0-9]+/, '_')
        a_name = a_name_arr.join('_')
        
        if control.public_instance_methods.include?(a_name) &&
           control.instance_method(a_name).arity == pieces.size
          
          new_env['the.app.meta'][:control]     = control
          new_env['the.app.meta'][:http_method] = new_env['REQUEST_METHOD'].to_s
          new_env['the.app.meta'][:action_name] = a_name.sub(new_env['the.app.meta'][:http_method] + '_' , '')
          new_env['the.app.meta'][:args]        = pieces
          break
        end

        a_name_arr

      end

      new_env['the.app.meta'][:control]
    }

    if results
      @app.call new_env 
    else
      raise The_App::HTTP_404, "Not found: #{new_env['REQUEST_METHOD']} #{new_env['PATH_INFO']}"
    end

  end

end # === Find_The_Bunny
