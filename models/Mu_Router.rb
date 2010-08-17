
class Mu_Router

  def self.maps
    @maps ||= new.compile
  end

  def self.detect new_env
    http_meth = new_env['REQUEST_METHOD'].to_s
    self.maps.detect { |path, control, raw_action_name, raw_http_verbs| 
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

      invalid = http_verbs - Find_The_Bunny::VALID_HTTP_VERBS
      unless invalid.empty?
        raise ArgumentError, "Invalid http verbs, #{invalid.inspect} for #{control.inspect}, #{action_name.inspect}, #{raw_http_verbs.inspect}"
      end
      
      # === Does the URL match that target?
      path_matches = case path
                     when String
                       k_finale = Find_The_Bunny::URL_REGEX.to_a.inject(path) { |m, kv| 
                         m.gsub("{#{kv.first}}", "(#{kv.last})")
                       }
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
  end
  
  # ==========================================================================================
  #                                Instance 
  # ==========================================================================================

  attr_reader :prefix, :control, :url_aliases
  def initialize new_prefix = '/', &blok
    @control     = nil
    @prefix      = new_prefix
    @url_aliases = []
    instance_eval(&blok) if block_given?
  end
  
  def compile
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
        path '/'      , :by_id  , %w{ GET PUT}
        path '/notify', :notify , 'POST'
        path '/repost', :repost , 'POST'
        path '/edit'  , :edit
        path '/log'   , :doc_log
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
      path '/{old_topics}'   , 'by_old_id'
      path '/follow/'         , 'follow'   , 'POST'
      
      map '/{filename}' do
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
        
        map '/follows' do
          path '/'
          path '/for_uni/{id}', 'follows_by_club'
          path '/for_life/{id}', 'follows_by_life'
        end
        
        map '/notifys' do
          path '/'
          path '/for_uni/{id}', 'notifys_by_club'
          path '/for_life/{id}', 'notifys_by_life'
        end

        path '/lifes' # List of usernames + account deletion option
        
        path '/create-account'
        path '/create-life'
        path '/today'
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
  end # === compile

  def to obj_class
    @control = obj_class
  end

  def path *args
    suffix, action, verbs = args
    action              ||= begin
                              last_piece = suffix == '/' ? 
                                              @prefix :
                                              suffix
                              last_piece.split('/').compact.last.gsub('-', '_')
                            end
    verbs                 = [verbs || 'GET'].flatten.compact.uniq
    filename              = suffix.split('/').last
    full_path             = if filename && filename['.']
                              File.join(prefix, suffix)
                            else
                              File.join(prefix, suffix, '/')
                            end
    @url_aliases << [full_path, control, action, verbs]
  end

  def map new_prefix, &blok
    @url_aliases += begin
                      new_map      = self.class.new(File.join(prefix, new_prefix))
                      orig_control = control
                      new_map.instance_eval {
                        to orig_control
                        instance_eval(&blok)
                        self.url_aliases
                      }
                    end
  end
  
  def top_slash &blok
    old_prefix = prefix
    @prefix = '/'
    instance_eval &blok
    @prefix = old_prefix
  end
  
end # === class
