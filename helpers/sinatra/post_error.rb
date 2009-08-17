

require 'rest_client'

class IssueClient

    def self.required_cols
      @required_cols ||= [ :app_name, :title,
                      :body, 
                      :environment, 
                      :path_info,
                      :user_agent, 
                      :ip_address ]
    end 
    def self.data_template
      required_cols.inject({}) { |m, k|
        m[k] = ''
        m
      }
    end
    
    def self.create(env, environ, *args)
      case args.size
        when 1
          e, title, body = args
        else
          title, body, e = args
      end
      begin
        data = data_template.merge( 
         {:path_info => env['PATH_INFO'],
          :api_key    => 'luv.4all.29bal--w0l3mg930--3',
          :app_name   => 'Mega Uni', 
          :title      => (title || e.message),
          :body       => (body || e.backtrace.reject {|b| b['mnt/.gems/gems'] || b['lib/ruby/gems'] }.join("\n")), 
          :environment   => environ.to_s ,
          :user_agent => env['HTTP_USER_AGENT'],
          :ip_address => env['REMOTE_ADDR'] || 'MISSING'
        })
        # url = # environ.to_sym == :development ? 'https://localhost/error' : 
        url =  'https://miniuni.heroku.com/error'
        RestClient.post( url, data)
      rescue 
        environ.to_sym == :development ?
          raise  :
          "error"
      end  
    end    
end


__END__
my_app_root = File.expand_path( File.dirname(__FILE__) )


    
    
begin
  raise "show maintainence page"  if File.exists?(my_app_root + '/helpers/sinatra/maintain.rb')
  require( my_app_root + '/megauni.rb' )
rescue
  $KCODE = 'UTF8'
  require 'rubygems'
  require 'sinatra'
  require( my_app_root + '/helpers' + ['/maintain', '/sinatra/maintain'].detect { |f| File.exists?(my_app_root+'/helpers' + f + '.rb') })
  
  require 'net/http'
  require 'rack_hoptoad'
  rh = Rack::HoptoadNotifier.new 'nil'
 
  rh.send(:send_to_hoptoad, :notice=>{
    :api_key => '05d03bbc87077117598fd437ce0caaa1',
    :error_class => $!.class.name,
    :error_message => "#{$!.class.name}: #{$!.message}",
    :backtrace => $!.backtrace.reject {|f| f !~ /#{File.expand_path('.')}/},
    :request => {},
    :session => {},
    :environment => {'message'=>'App could not start.'}
  })

end

run Sinatra::Application

