require 'sequel'
require 'sequel/extensions/inflector'

class SecretCloset

    def self.connection
        @db_conn
    end
   
    def self.connect!
        return connection if connection
        @env ||= Object.const_defined?(:Sinatra) ?
                        Sinatra::Application.environment :
                        :development;
                        
        case @env
          when :test, :development
              # -----------------------------------------------------------------------------------------------
              # Setup logger.
              # -----------------------------------------------------------------------------------------------
              require 'logger'
              test_file_path = Pow!('../../sequel_log.txt')
              File.delete(test_file_path) if File.exists?(test_file_path)          
              new_logger =  Logger.new(test_file_path)
              # -----------------------------------------------------------------------------------------------
              @db_conn = Sequel.connect( db_connection_string  , {:loggers=> [new_logger]}  )
              
          when :production
              @db_conn = Sequel.connect( db_connection_string )         
          else
            raise ArgumentError, "#{new_env.inspect} - is not a valid environment for SurferDB"
        end
    end # === def self.connect!
    
    private # ===========================================
    
    # Put your production values here.
    def self.development
        [ 'localhost', 'newsprint-db', 'da01', 'xd19yzxkrp10']
    end
    
    def self.test
        [ 'localhost', 'newsprint-db-test', 'da01', 'xd19yzxkrp10' ]
    end
    
    def self.production
        [:test_host, :test_db, :test_user, :test_pass]
    end
    
    def self.db_connection_string
        host, db_name, user, pass = send(@env)

        # config.jruby? ?
        #  "jdbc:postgresql://%s/%s?user=%s&password=%s" % [host, db_name, user, pass ] : 
          "postgres://%s:%s@%s/%s" % [ user, pass, host, db_name ]
    end    
    
end # === SecretCloset

DB = SecretCloset.connect!
