require 'sequel'
require 'sequel/extensions/inflector'

class SecretCloset
    def self.connect
        return @db_conn if @db_conn
        @env ||= Object.const_defined?(:Sinatra) ?
                        Sinatra::Application.environment :
                        :development;
        
               
        @db_conn = case @env
          when :test, :development

              db_connection_string = ( @env == :development ) ?
                                      'postgres://da01:xd19yzxkrp10@localhost/newsprint-db' :
                                      'postgres://da01:xd19yzxkrp10@localhost/newsprint-db-test' ;
              # === Setup logger
              require 'logger'  
              new_file = Pow( File.expand_path('~/sequel_log.txt') )
              new_file.delete if new_file.file?
              new_logger = {:loggers=> [ Logger.new(new_file) ]}
              
              # Finally...
              Sequel.connect( db_connection_string  ,  new_logger )
              
          when :production
              Sequel.connect( ENV['DATABASE_URL'] )         
          else
            raise ArgumentError, "#{$env.inspect} - is not a valid environment for database connection."
        end
        
    end # === def self.connect
          
    
end # === SecretCloset

DB = SecretCloset.connect
