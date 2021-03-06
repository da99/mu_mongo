
class Old_App_Redirect

  def initialize new_app
    @app = new_app
  end

  def call new_env

    path_info = new_env['PATH_INFO']
    bing_site = 'http://www.bing.com/'

    if path_info == '/timer/'
      return hearty_redirect( '/busy-noise/' )
    end

    if path_info['/myeggtimer%']
      return hearty_redirect( '/myeggtimer/' )
    end

    if path_info === '/meno-osteo/'
      return hearty_redirect( '/meno_osteo/' )
    end

    if path_info === '/' && new_env['HTTP_METHOD'] === 'POST'
      return hearty_redirect( new_env['HTTP_REFERER'] || '/my-egg-timer/' )
    end

    if path_info == '/member/' && %w{HEAD GET}.include?(new_env['HTTP_METHOD'])
      return hearty_redirect('/')
    end

    # =========== BAD AGENTS ==============================
    if [
     %r!\A/MSOffice/cltreq.asp!,
     %r!\.(asp|php)\Z!,
     %r!\A/_vti_bin/owssvr.dll!,
     %r!\A/sitemap.xml.gz!,
     %r!awstats.pl\Z!,
     %r!\A/my-egg-timer/stylesheets/\Z!
    ].detect { |str| new_env['PATH_INFO'] =~ str }
      return hearty_redirect("http://www.bing.com/")
    end

    wrong_path = %w{
      /SWF/main.swf
      /(null)/
    }.detect { |str| new_env['PATH_INFO'] == str }
    if wrong_path
      return hearty_redirect("http://www.bing.com#{wrong_path}")
    end

    ua = new_env['HTTP_USER_AGENT']
    if ua && [ 'libwww-perl', 'LinkWalker/', 'panscient', 'aiHitBot' , "WebSurfer text" , "Yandex/", 'YandexBot', "Sosospider"].detect { |ua_s|  
      ua[ua_s]
    }
      return hearty_redirect("http://www.bing.com/")
    end

    if ua 
      
      if ua['Yahoo! Slurp/'] && path_info['/SlurpConfirm404']
        return hearty_redirect( bing_site )
      end
      
      if ua['Googlebot/']
        wrong_paths = %w{ vb forum forums old vbulletin }.map { |dir| "/#{dir}/" }
        if wrong_paths.include?(path_info)
          return hearty_redirect( bing_site )
        end
      end
      
    end # if ua


    # =====================================================
    
    if new_env['PATH_INFO'] === "/skins/jinx/css/main_show.css"
      return hearty_redirect("/stylesheets/en-us/Hellos_list.css")
    end

    if new_env['PATH_INFO'] === "/skins/jinx/css/news_show.css"
      return hearty_redirect("/stylesheets/en-us/Hellos_list.css")
    end

    if new_env['PATH_INFO'] === "/child_care/clubs/child_care/"
      return hearty_redirect("/uni/child_care/")
    end

    if new_env['PATH_INFO'] === "/child_care/clubs/child_care/"
      return hearty_redirect("/uni/child_care/")
    end

    if new_env['PATH_INFO'] === "/back_pain/clubs/back_pain/"
      return hearty_redirect("/uni/back_pain/")
    end
    
    if new_env['PATH_INFO'] === "/help/"
      return hearty_redirect("/uni/megauni/")
    end

    if ['/back-pain/', '/meno-uni/'].include?(new_env['PATH_INFO'])
      return hearty_redirect("/uni#{new_env['PATH_INFO']}".sub('-', '_'))
    end
    
    if ['/salud/robots.txt'].include?(new_env['PATH_INFO'])
      return hearty_redirect("/robots.txt")
    end

    if (new_env['HTTP_HOST'] =~ /megahtml.com/ && new_env['PATH_INFO'] == '/')
      return hearty_redirect('/megahtml.html')
    end
    
    if (new_env['HTTP_HOST'] =~ /myeggtimer.com/ && new_env['PATH_INFO'] == '/')
      return hearty_redirect('/my-egg-timer/moving.html')
    end

    if (new_env['HTTP_HOST'] =~ /busynoise.com/ && new_env['PATH_INFO'] == '/') ||
       ['/egg', '/egg/'].include?(new_env['PATH_INFO'])
      return hearty_redirect('/busy-noise/moving.html')
    end

    if new_env['PATH_INFO'] == '/child-care/' 
      return hearty_redirect("/uni/child_care")
    end

    if new_env['PATH_INFO'] =~ %r!\A/(#{Find_The_Bunny::Old_Topics.join('|')})/\Z!
      return hearty_redirect("/uni/#{$1}/")
    end

    if ['/about.html', '/about/'].include?(new_env['PATH_INFO'])
      return hearty_redirect('/help/')
    end

    if ['/blog/', '/blog.html', '/archives.html', '/archives/', 
        '/bubblegum/','/hearts/' ].include?(new_env['PATH_INFO'])
      return hearty_redirect('/uni/hearts/')
    end

    if new_env['PATH_INFO'] =~ %r!/media/heart_links/images(.+)!
      return hearty_redirect( File.join('http://surferhearts.s3.amazonaws.com/heart_links', $1))
    end
    
    if new_env['PATH_INFO'] =~ %r!/blog/(\d+)/\Z!
      return hearty_redirect("/uni/hearts/by_date/#{$1}/")
    end

    if new_env['PATH_INFO'] =~ %r!/blog/(\d+)/0/\Z! 
      return hearty_redirect("/uni/hearts/by_date/#{$1}/1" )
    end

    if new_env['PATH_INFO'] =~ %r!\A/hearts/by_date/(\d+)/(\d+)/\Z! 
      return hearty_redirect("/uni/hearts/by_date/#{$1}/#{$2}/")
    end # ===

    if new_env['PATH_INFO'] =~ %r!\A/hearts/m/\Z!
      return hearty_redirect("/uni/hearts/")
    end

    if new_env['PATH_INFO'] === '/rss/'
      return hearty_redirect("/rss.xml")
    end

    if new_env['PATH_INFO'] =~ %r!\A/hearts?_links?/(\d+)/\Z! || #  /hearts_links/29/
       new_env['PATH_INFO'] =~ %r!\A/hearts?_links?/(\d+)\.html?!  # /hearts/20.html
      return hearty_redirect( "/mess/#{ $1 }/"  )
    end

    if new_env['PATH_INFO'] =~ %r!/(heart_link|new)s?/([A-Za-z0-9\-]+)/\Z!  #  /heart_link/29/
      return hearty_redirect("/mess/#{$2}/")
    end
    
    if new_env['PATH_INFO'] =~ %r!\A/(heart|new|heart_link)s?/by_(tag|category)/(\d+)/\Z! ||
       new_env['PATH_INFO'] =~ %r!\A/(heart_link|new)s?/by_(category|tag)/(\d+)\.html?!
      tags = { 167 => 'stuff_for_dudes', 
        168 => 'stuff_for_dudettes', 
        169 => 'stuff_for_pets', 
        170 => 'stuff_for_mommies_and_dads', 
        171 => 'edible_delicious', 
        172 => 'books_articles', 
        173 => 'techie_wonders', 
        174 => 'miscellaneous', 
        175 => 'art_design', 
        176 => 'surfer_hearts' 
      }
      news_tag = tags[ Integer($3) ]
      if !news_tag
        return hearty_redirect("/uni/hearts/by_label/unknown-label/")
      else
        return hearty_redirect("/uni/hearts/by_label/#{news_tag}/")
      end
    end

    if new_env['PATH_INFO'] =~ %r!\A/(heart_link|heart|new)s/by_tag/([a-zA-Z0-9\-]+)/\Z! 
      tag_name = $1
      return hearty_redirect("/uni/hearts/by_label/#{tag_name}/")
    end

    if new_env['PATH_INFO'] =~ %r!\A/news/by_date/(\d+)/(\d+)! ||
       new_env['PATH_INFO'] =~ %r!\A/blog/(\d+)/(\d+)/\Z! 
      return hearty_redirect("/uni/hearts/by_date/#{$1}/#{$2}/")
    end

    @app.call(new_env)

  end

  private

  def hearty_redirect new_url
    response = Rack::Response.new
    response.redirect( new_url, 301 ) # permanent
    response.finish
  end


end # === class

__END__

