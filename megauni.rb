$KCODE = 'UTF8'

require 'rubygems'
require 'sinatra'
require 'markaby'
require 'pow'


configure do

  # Markaby::Builder.set(:indent, 2) 

  error do
    File.read( Pow('public/error.html')  ) 
  end 

  not_found do
    File.read( Pow('public/not_found.html' ) )
  end 
  
end



get '/' do
  
  mab  = Markaby::Builder.new( {} )
  mab.instance_eval(  Pow(  'views/index.mab' ).read  ).to_s

end


