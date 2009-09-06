
instruct!
declare!(:DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.0 Strict//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd")
tag!(:html, :xmlns => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", :lang => "en" ) {

  @the_content = capture { partial(content_file_path)  }

  head {
    meta( :'http-equiv'=>"Content-Script-Type" , :content=>"text/javascript" )
    meta( :'http-equiv'=>"Content-Style-Type"  , :content=>"text/css" )
    meta( :'http-equiv'=>"Content-Language"    , :content=>"en-US" )
    meta( :'http-equiv'=>"Content-Type"    , :content=>"text/html; charset=utf-8" )
    meta( :'http-equiv'=>"Content-Language"    , :content=>"en-US" )
    
    unless @allow_browser_cache
      meta( :'http-equiv'=>'expires' , :content=>'Thu, 12 Mar 2004 12:34:12 GMT' )
      meta( :'http-equiv'=>'pragma'  , :content=>'no-cache' )
    else
      meta( :'http-equiv'=>'expires' , :value=>(Time.now.utc + (60 * 60) ).strftime('%a, %d-%b-%Y %H:%M:%S GMT') )
    end

    if @meta_description
      meta( :name=>'description', :content=>@meta_description)
    end

    if @meta_keywords
      meta( :name=>'keywords'   , :content=>@meta_keywords)
    end

    title( @title || ' ---- ' )

    link( :rel=>"shortcut icon", :href=>"#{ the_app.socket_and_host}/favicon.ico", :type=>"image/x-icon")
    if !the_app.mobile_request?
      link( :rel=>"stylesheet",    :href=>"/skins/#{the_app.skin_name}/css/#{the_app.page_name}.css?v=#{Time.now.to_i}", :media=>"screen", :type=>"text/css" )
    end
    
    if @head_content
      self << @head_content
    end
  } # head

  body.the_body! {
    div.container! { 
    
      div.timestamp! the_app.to_js_epoch_time(Time.now.utc.to_i).to_s

      if @loading
        div.loading! 'Loading...'
      end

      # ================= the_content ================================
      self << @the_content

      # ================= the_footer ================================
      div.footer! {
        span "(c) #{[2009,Time.now.utc.year].uniq.join('-')} #{the_app.options.site_domain}. Some rights reserved."
      } # the_footer
      
    
      if @javascripts
        if @javascripts.eql?( 'default' )
          text [ the_app.script_tag('/js/vendor/jquery.1.3.2.min.js'),
                    the_app.script_tag('/js/vendor/jquery.cookie.js') ,
                    the_app.script_tag('/js/swiss.js'),
                  ''
                ].join("\n")
         
          self << "\n"      
          self <<  the_app.script_tag("#{page_name}.js")
        else
          self << @javascripts
        end

      end
    } # === container
  } # the_body
}


 


