$KCODE = 'UTF8'

require 'rubygems'
require 'sinatra'

require 'pow'


configure do

  # Markaby::Builder.set(:indent, 2) 

  error do
    File.read( Pow!('public/error.html')  ) 
  end 

  not_found do
    File.read( Pow!('public/not_found.html' ) )
  end 
  
end



get '/' do
  "test is done"
  # mab  = Markaby::Builder.new( {} )
  # mab.instance_eval(  File.read( Pow!(  'views/index.mab' ) )  ).to_s

end


