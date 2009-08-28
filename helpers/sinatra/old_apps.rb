before {

    moving_date = Time.utc(2009, 8, 31, 0, 1, 1).to_i # Aug. 31, 2009
    right_now = Time.now.utc.to_i
    
    if request.host =~ /busynoise/i && request.path_info == '/'
      redirect('/egg')
    end
    
    [:busynoise, :myeggtimer, :megahtml, :newsprint, :bigdeadline, :bigstopwatch].each { |name|
      if request.host =~ /#{name}/i && ['/', '/egg', '/eggs'].include?(request.path_info)
        halt show_old_site( name, moving_date < right_now )
      end
    }

}



helpers {

  def show_old_site(name, show_moving = false)
  
    page_name = show_moving ? 'moving' : 'index'
  
    case name
    
      when :busynoise, :busy_noise
        Pow("public/busy-noise/#{page_name}.html").read
      
      when :myeggtimer, :my_egg_timer
        Pow("public/my-egg-timer/#{page_name}.html").read
      
      when :megahtml, :newsprint, :bigdeadline, :bigstopwatch
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
      else
        not_found
    end
    
    
    
  end # === show_old_site
} # === 


get '/eggs?' do
  show_old_site :busy_noise
end

get '/busy-noise' do
  show_old_site :busy_noise
end

get '/my-egg-timer' do
  show_old_site :my_egg_timer
end


