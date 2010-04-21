
class Old_App_Redirect

  def initialize new_app
    @app = new_app
  end

  def call new_env

    # =========== BAD AGENTS ==============================
    if [
     %r!\A/MSOffice/cltreq.asp!,
     %r!\.(asp|php)\Z!,
     %r!\A/_vti_bin/owssvr.dll!
    ].detect { |str| new_env['PATH_INFO'] =~ str }
      return hearty_redirect("http://www.bing.com/")
    end

    # =====================================================

    if new_env['PATH_INFO'] === "/skins/jinx/css/main_show.css"
      return hearty_redirect("/stylesheets/en-us/Hellos_list.css")
    end

    if new_env['PATH_INFO'] === "/skins/jinx/css/news_show.css"
      return hearty_redirect("/stylesheets/en-us/Hellos_list.css")
    end

    if new_env['PATH_INFO'] === "/child_care/clubs/child_care/"
      return hearty_redirect("/clubs/child_care/")
    end

    if new_env['PATH_INFO'] === "/child_care/clubs/child_care/"
      return hearty_redirect("/clubs/child_care/")
    end

    if new_env['PATH_INFO'] === "/back_pain/clubs/back_pain/"
      return hearty_redirect("/clubs/back_pain/")
    end
    
    if new_env['PATH_INFO'] === "/help/"
      return hearty_redirect("/clubs/megauni/")
    end

    if ['/back-pain/', '/meno-osteo/'].include?(new_env['PATH_INFO'])
      return hearty_redirect("/clubs#{new_env['PATH_INFO']}".sub('-', '_'))
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
      return hearty_redirect("/clubs/child_care")
    end

    if new_env['PATH_INFO'] =~ %r!\A/(#{Find_The_Bunny::Old_Topics.join('|')})/\Z!
      return hearty_redirect("/clubs/#{$1}/")
    end

    if ['/about.html', '/about/'].include?(new_env['PATH_INFO'])
      return hearty_redirect('/help/')
    end

    if ['/blog/', '/blog.html', '/archives.html', '/archives/', 
        '/bubblegum/','/hearts/' ].include?(new_env['PATH_INFO'])
      return hearty_redirect('/clubs/hearts/')
    end

    if new_env['PATH_INFO'] =~ %r!/media/heart_links/images(.+)!
      return hearty_redirect( File.join('http://surferhearts.s3.amazonaws.com/heart_links', $1))
    end
    
    if new_env['PATH_INFO'] =~ %r!/blog/(\d+)/\Z!
      return hearty_redirect("/clubs/hearts/by_date/#{$1}/")
    end

    if new_env['PATH_INFO'] =~ %r!/blog/(\d+)/0/\Z! 
      return hearty_redirect("/clubs/hearts/by_date/#{$1}/1" )
    end

    if new_env['PATH_INFO'] =~ %r!\A/hearts/by_date/(\d+)/(\d+)/\Z! 
      return hearty_redirect("/clubs/hearts/by_date/#{$1}/#{$2}/")
    end # ===

    if new_env['PATH_INFO'] =~ %r!\A/hearts/m/\Z!
      return hearty_redirect("/clubs/hearts/")
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
        return hearty_redirect("/clubs/hearts/by_label/unknown-label/")
      else
        return hearty_redirect("/clubs/hearts/by_label/#{news_tag}/")
      end
    end

    if new_env['PATH_INFO'] =~ %r!\A/(heart_link|heart|new)s/by_tag/([a-zA-Z0-9\-]+)/\Z! 
      tag_name = $1
      return hearty_redirect("/clubs/hearts/by_label/#{tag_name}/")
    end

    if new_env['PATH_INFO'] =~ %r!\A/news/by_date/(\d+)/(\d+)! ||
       new_env['PATH_INFO'] =~ %r!\A/blog/(\d+)/(\d+)/\Z! 
      return hearty_redirect("/clubs/hearts/by_date/#{$1}/#{$2}/")
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

