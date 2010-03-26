
class Old_App_Redirect

  def initialize new_app
    @app = new_app
  end

  def call new_env
    if new_env['PATH_INFO'] === '/about/'
      return hearty_redirect('/help/')
    end

    if new_env['PATH_INFO'] =~ %r!/media/heart_links/images(.+)!
      return hearty_redirect( File.join('http://surferhearts.s3.amazonaws.com/heart_links', $1))
    end
    
    if new_env['PATH_INFO'] === '/hearts/'
      return hearty_redirect('/clubs/hearts/')
    end
    
    if new_env['PATH_INFO'] === '/blog/'
      return hearty_redirect('/clubs/hearts/')
    end

    if new_env['PATH_INFO'] =~ %r!/blog/(\d+)/\Z!
      return hearty_redirect("/clubs/hearts/by_date/#{$1}/")
    end

    if new_env['PATH_INFO'] =~ %r!/blog/(\d+)/0/\Z! 
      return hearty_redirect("/clubs/hearts/by_date/#{$1}/1" )
    end

    if new_env['PATH_INFO'] =~ %r!/blog/(\d+)/(\d+)/\Z! 
      return hearty_redirect("/clubs/hearts/by_date/#{$1}/#{$2}/" )
    end

    if new_env['PATH_INFO'] =~ %r!/hearts/by_date/(\d+)/(\d+)/\Z! 
      return hearty_redirect("/clubs/hearts/by_date/#{$1}/#{$2}/")
    end # ===

    if new_env['PATH_INFO'] =~ %r{/heart_links?/by_category/(\d+)\.html?} 
      return hearty_redirect("/clubs/hearts/by_label/#{$1}/")
    end

    if new_env['PATH_INFO'] =~ %r{/heart_links/by_category/(\d+)/\Z} 
      return hearty_redirect("/clubs/hearts/by_label/#{$1}/")
    end

    if new_env['PATH_INFO'] =~ %r{/hearts/by_tag/(\d+)/\Z} 
      return hearty_redirect("/clubs/hearts/by_label/#{$1}/")
    end

    if new_env['PATH_INFO'] =~ %r{/hearts?_links?/(\d+)\.html?}  # /hearts/20.html
      return hearty_redirect( "/mess/#{ $1  }/"  )
    end

    if new_env['PATH_INFO'] =~ %r{/hearts?_links/(\d+)/\Z}   #  /hearts_links/29/
      return hearty_redirect( "/mess/#{ $1 }/"  )
    end

    if new_env['PATH_INFO'] =~ %r{/heart_link/([A-Za-z0-9\-]+)/\Z}  #  /heart_link/29/
      return hearty_redirect("/mess/#{$1}/")
    end

    if new_env['PATH_INFO'] =~ %r{\A/hearts/m/\Z}
      return hearty_redirect("/clubs/hearts/")
    end

    if new_env['PATH_INFO'] === '/rss/'
      return hearty_redirect("/rss.xml")
    end
    
    if new_env['PATH_INFO'] =~ %r{/news/by_tag/([0-9]+)/\Z} 
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
      news_tag = tags[ Integer($1) ]
      if !@news_tag
        return hearty_redirect("/clubs/hearts/by_label/unknown-tag/")
      else
        return hearty_redirect("/clubs/hearts/by_label/#{news_tag}/")
      end
    end

    if new_env['PATH_INFO'] =~ %r{/news/by_tag/([a-zA-Z0-9\-]+)\Z/} 
      tag_name = $1
      return hearty_redirect("/clubs/hearts/by_label/#{tag_name}/")
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

