require 'rubygems'
require 'sinatra'


configure do
  
  error do
    %~
    <html>
        <head>
          <title>Error</title>
        </head>
        <body>
          <h1>:{</h1>
          <p>Something went wrong. Come back later when it gets fixed.</p>
        </body>
    </html>
    ~
  end # error -------------------------------------------------------------------

  not_found do
    %~
        <html>
          <head>
            <title>Error</title>
          </head>
          <body>
            <h1>:P</h1>
            <p>Sorry, the page you are looking for does not exist.</p>
          </body>
        </html>
    ~  
  end # not_found ----------------------------------------------------------------
  
end


# get '/' do
#  File.read( File.expand_path( File.join(File.dirname(__FILE__), 'public/index.html' ) ) ) 
# end

get '/' do
  File.read( File.expand_path('./public/main_index.html') )
end



