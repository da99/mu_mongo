require 'sequel'
require 'sequel/extensions/inflector'

DB = begin
        env ||= Object.const_defined?(:Sinatra) ?
                        Sinatra::Application.environment :
                        :development;
        case env
          when :test
              Sequel.connect 'postgres://da01:xd19yzxkrp10@localhost/newsprint-db-test'
          when :development
              # === Setup logger
              require 'logger'  
              new_file = Pow( File.expand_path('~/sequel_log.txt') )
              new_file.delete if new_file.file?
              new_logger = {:loggers=> [ Logger.new(new_file) ]}
              
              # Finally...
              Sequel.connect( 'postgres://da01:xd19yzxkrp10@localhost/newsprint-db'  ,  new_logger )
              
          when :production
              Sequel.connect( ENV['DATABASE_URL'] )         
          else
            raise ArgumentError, "#{env.inspect} - is not a valid environment for database connection."
        end
end # === SecretCloset
