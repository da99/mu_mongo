require 'rubygems'
require 'sinatra'
require 'markaby'


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
  dot_domain = request.host.sub('www.', '').sub('.', ' [dot] ')
  main_domain = request.host.sub('www.', '')
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
        <!--
        <p>All books listed have 3 or more stars.</p>
        <ul>
          <li>Learn HTML ==&gt; <a href="http://www.amazon.com/gp/product/0321430840?ie=UTF8&tag=busnoi-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0321430840">HTML, XHTML, and CSS, Sixth Edition (Visual Quickstart Guide) </a></li>
          <li>Learn JS ==&gt; <a href="http://www.amazon.com/gp/product/0596101996?ie=UTF8&tag=busnoi-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0596101996">JavaScript: The Definitive Guide</a></li>
          <li>Learn CSS ==&gt; <a href="http://www.amazon.com/gp/product/0596527330?ie=UTF8&tag=busnoi-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0596527330">CSS: The Definitive Guide</a></li>
        </ul>
        //-->
        <p>This domain for sale. Contact <span id="email">sales [at] #{dot_domain}</span>
        <script type="text/javascript">
        <!--
          document.getElementById('email').innerHTML = '<a hr' + 'ef="mai' + 'lto:s' + 'ales' + '@' + '#{main_domain}">' + 'sales' + '@' + '#{main_domain}</a>'
        //-->
        </script>
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

