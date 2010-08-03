require 'models/Path_Map'

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
  
  private # ==================================================
  def map prefix, &blok
    @url_aliases += Path_Map.new(prefix, &blok).url_aliases
  end

  def redirect new_url
    response = Rack::Response.new
    response.redirect( new_url, 301 ) # permanent
    response.finish
  end

  public # ==================================================
  def initialize new_app
    @app = new_app
    @url_aliases = []
    
    map '/' do
      to Hellos
      path '/', :list
      path '/salud' , :salud
      path '/rss.xml', :rss_xml
      path '/sitemap.xml', :sitemap_xml
    end
    
    map '/' do
      to Messages
      path '/messages/', :create, 'POST'
      
      map '/mess/{id}'  do 
        path '/'    , :by_id  , %w{ GET PUT}
        path '/edit', :edit
        path '/log' , :doc_log
      end
      
      map '/clubs/{filename}' do
        path '/by_label/{filename}/', 'by_label'
        map '/by_date' do
          path '/'                  , 'by_date'
          path '/{digits}/'         , 'by_date'
          path '/{digits}/{digits}/', 'by_date'
        end
      end
    end
    
    map '/clubs' do
      to Clubs
      
      top_slash do
        path '/club-create/'                 ,  'create'         
        path '/club-search/'                 ,  'club_search'     , 'POST'
        path '/club-search/{filename}/'      ,  'club_search'
      end
      
      path '/'                , 'list'
      path '/'                , 'create'   , 'POST'
      path '/{old_topics}/'   , 'by_old_id'
      path '/follow/'         , 'follow'   , 'POST'
      
      map '/{filename}/' do
        path '/'            ,  'by_filename'    
        path '/'            ,  'update'          , 'PUT'
        path '/edit/', 'edit'
        path '/follow/'     ,  'follow'       
        path '/e/'          ,  'read_e'      
        path '/qa/'         ,  'read_qa'    
        path '/news/'       ,  'read_news' 
        path '/fights/'     ,  'read_fights'
        path '/shop/'       ,  'read_shop'  
        path '/random/'     ,  'read_random'
        path '/thanks/'     ,  'read_thanks' 
        path '/predictions/',  'read_predictions'
        path '/magazine/',  'read_magazine'
      end
    end
    
    map '/' do
      to Sessions
      path '/log-in/' ,  'log_in'  , %w{GET POST} 
      path '/log-out/',  'log_out'
    end
      
    map '/member' do
      to Members
      path '/', 'create', 'POST'
      path '/', 'update', 'PUT'

      top_slash do
        path '/lives/{filename}', 'lives'
        path '/create-account'
        path '/create-life'
        path '/today'
        path '/account'
        path '/reset-password'                          , nil              , 'POST'
        path '/change-password/{filename}/{cgi_escaped}', 'change_password', %w{GET POST}
        path '/delete-account-forever-and-ever'         , nil              , 'DELETE'
        
        map '/life/{filename}' do
          path '/'                        , 'life'
          path '/e'                       , 'life_e'
          path '/qa'                      , 'life_qa'
          path '/news'                    , 'life_news'
          path '/status'                  , 'life_status'
          path '/shop'                    , 'life_shop'
          path '/predictions'             , 'life_predictions'
          path '/random'                  , 'life_random'
        end
      end
    end
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
      
      if new_env['PATH_INFO'] == '/templates/' || new_env['HTTP_USER_AGENT'].to_s['TwengaBot']
        return redirect('/')
      end
      
      raise The_App::HTTP_404, "Not found: #{new_env['REQUEST_METHOD']} #{new_env['PATH_INFO']}"
    end

  end
  

end # === Find_The_Bunny
