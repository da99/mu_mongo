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
  %~
    <html>
      <head>
        <title>Learn HTML</title>
        <meta name="verify-v1" content="Blj1lh0s7UYhIw92PuNfg6EJzZOrUGSZ3Zj4G+GWOlg=" />
        <style type="text/css">


		    p { margin: 0 ; }
		    body {
		      font-family: helvetica, sans-serif;
		    }
		    a:link, a:visited, a:hover, a:active {
          font-weight: bold;
          padding: 0 4px;
		    }
		    a:hover {
		      background: #D50015;
		      color: #fff;
		    }
        
        
        li {
          padding-bottom: 10px
        }
        </style>
      </head>
      <body>
        <p>megaUni.com - More info. this week.</p>
        <p>Status:
        <br />
        I'm working on the database schema.
        
        <br />
        - <a href="http://www.da01.tv">diego</a>
        <br />
        - (<a href="http://www.twitter.com/da01tv">on twitter</a>)
        </p>
      </body>
    </html>
  ~
end

get '/torr' do
  redirect "http://ec2-67-202-14-164.compute-1.amazonaws.com/index.php"
end

get '/aws' do
  redirect "https://console.aws.amazon.com/ec2/home"
end

