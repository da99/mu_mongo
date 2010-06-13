class Find_The_Bunny

  VALID_HTTP_VERBS = %w{ HEAD GET POST PUT DELETE }
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
    music
    meno_osteo
    news
    preggers
    sports
  }
  URL_REGEX = Hash[
    :id       => '[a-zA-Z\-\d]+',
    :filename => '[a-zA-Z0-9\-\_\+]+',
		:cgi_escaped => '[^/]{1,90}',
    :digits   => '[0-9]+',
    :old_topics => "#{Old_Topics.join('|')}"
  ]
  def initialize new_app
    @app = new_app
    @url_aliases = [
      ['/'           , Hellos, 'list'        , 'GET'       ],
      ['/salud/'     , Hellos, 'salud'       , 'GET'       ],
      ['/rss.xml'    , Hellos, 'rss_xml']    ,
      ['/sitemap.xml', Hellos, 'sitemap_xml'],
      
      ['/mess/{id}/'                                 , Messages, 'by_id'       , %w{ GET PUT } ],
      ['/mess/{id}/edit/'                            , Messages, 'edit'  ]     ,
      ['/clubs/{filename}/by_label/{filename}/'      , Messages, 'by_label']   ,
      ['/clubs/{filename}/by_date/'                  , Messages, 'by_date']    ,
      ['/clubs/{filename}/by_date/{digits}/'         , Messages, 'by_date']    ,
      ['/clubs/{filename}/by_date/{digits}/{digits}/', Messages, 'by_date']    ,
      ['/messages/'                                  , Messages, 'create'      , 'POST']        ,
      
      ['/clubs/'                  , Clubs, 'list'      , 'GET'] ,
      ['/clubs/'                  , Clubs, 'create'    , 'POST'],
      ['/club-create/'           , Clubs, 'create' ]  ,
      ['/clubs/{filename}/edit/'  , Clubs, 'edit' ]    ,
      ['/clubs/{old_topics}/'     , Clubs, 'by_old_id'],
      ['/clubs/{filename}/'       , Clubs, 'by_id']    ,
      ['/clubs/{filename}/'       , Clubs, 'update'    , 'PUT'] ,
      ['/clubs/{filename}/follow/', Clubs, 'follow'    , 'GET'] ,
      ['/clubs/follow/'           , Clubs, 'follow'    , 'POST'],
      ['/clubs/{filename}/e/'     , Clubs, 'read_e'    , 'GET'] ,
      ['/clubs/{filename}/qa/'    , Clubs, 'read_qa'   , 'GET'] ,
      ['/clubs/{filename}/news/'  , Clubs, 'read_news' , 'GET'] ,
			['/club-search/'            , Clubs, 'club_search', 'POST'],
			['/club-search/{filename}/'  , Clubs, 'club_search', 'GET'],
      
      ['/log-in/' , Sessions, 'log_in'  , %w{GET POST} ],
      ['/log-out/', Sessions, 'log_out'],
      
      ['/member/'          , Members, 'create'          , 'POST'],
      ['/members/'         , Members, 'update'          , 'PUT'] ,
      ['/life/{filename}/' , Members, 'life' ]          ,
      ['/lives/{filename}/', Members, 'lives' ]         ,
      ['/create-account/'  , Members ],
      ['/create-life/'     , Members ],
      ['/today/'           , Members ],
      ['/account/'         , Members ],
      ['/reset-password/'  , Members, nil, 'POST' ],
			['/change-password/{filename}/{cgi_escaped}/', Members, 'change_password', %w{GET POST} ]
    ]
  end

  def call new_env
    
    new_env['the.app.meta'] ||= {}
    http_meth = new_env['REQUEST_METHOD'].to_s
    results = @url_aliases.detect { |path, control, raw_action_name, raw_http_verbs| 

      action_name = raw_action_name ? 
                      raw_action_name : 
                      path.gsub(%r!\A/|/\Z!, '').split("/").join('-').gsub('-', '_')
      
      # === Validate HTTP verbs
      http_verbs = [ raw_http_verbs || 'GET' ].flatten
      if http_verbs.empty?
        http_verbs << 'GET'
      end
      if http_verbs.include?('GET')
        http_verbs << 'HEAD'
      end
      http_verbs = http_verbs.compact

      invalid = http_verbs - VALID_HTTP_VERBS
      unless invalid.empty?
        raise ArgumentError, "Invalid http verbs, #{invalid.inspect} for #{control.inspect}, #{action_name.inspect}, #{raw_http_verbs.inspect}"
      end
      
      # === Does the URL match that target?
      path_matches = case path
                     when String
                       k_finale = URL_REGEX.to_a.inject(path) { |m, kv| 
                         m.gsub("{#{kv.first}}", "(#{kv.last})")
                       }
      # if new_env['PATH_INFO'] == "/clubs/hearts/" && http_meth == 'GET'
      #   
      #   require 'rubygems'; require 'ruby-debug'; debugger
      # end
        
                      
                       new_env['PATH_INFO'] =~ %r~\A#{k_finale}\Z~
                     when Regexp
                       new_env['PATH_INFO'] =~ path
                     end

      # === Action found?
      action_matches = http_verbs.include?(http_meth)

      # === Store everything into the ENV.
      if path_matches && action_matches
        new_env['the.app.meta'][:control]     = control
        new_env['the.app.meta'][:http_method] = http_meth
        new_env['the.app.meta'][:action_name] = action_name || http_meth
        new_env['the.app.meta'][:args]        = $~.captures
      end
      
    }

    if results
      @app.call new_env 
    else
      
      if new_env['PATH_INFO']['/+/']
        new_url = File.join( *(new_env['PATH_INFO'].split('+').reject { |piece| piece == '+'}) )
        return redirect(new_url)
      end
      
      raise The_App::HTTP_404, "Not found: #{new_env['REQUEST_METHOD']} #{new_env['PATH_INFO']}"
    end

  end
  
  private

  def redirect new_url
    response = Rack::Response.new
    response.redirect( new_url, 301 ) # permanent
    response.finish
  end


end # === Find_The_Bunny
