# =========================================================
# This file is separate because sometimes we just need
# a connection, and not all the models. 
# Example: Rake tasks to migrate up/down database.
# =========================================================

require 'sequel'


DB = begin
        case (Object.const_defined?(:Sinatra) ?  Sinatra::Application.environment : :development)

          when :production
            Sequel.connect ENV['DATABASE_URL']
          when  :test
            require Pow("~/.megauni")
            Sequel.connect ENV['TEST_DATABASE_URL']
          when :development
            require Pow("~/.megauni")
            # === Setup logger
            require 'logger'  
            new_file = Pow( File.expand_path('~/sequel_log.txt') )
            new_file.delete if new_file.file?
            new_logger = {:loggers=> [ Logger.new(new_file) ]}
            
            # Finally...
            Sequel.connect ENV['DATABASE_URL'] ,  new_logger
      
          else
            raise ArgumentError, "#{env.inspect} - is not a valid environment for database connection."
        end
end # === begin
