require 'models/Path_Map'

class Mu_Router

  def self.map prefix, &blok
    @maps ||= []
    @maps = @maps + Path_Map.new(prefix, &blok).url_aliases
  end

  def self.maps
    @maps ||= []
    if @maps.empty?
      compile
    end
    @maps
  end

  def self.compile
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
  end # === compile
  
end # === class
