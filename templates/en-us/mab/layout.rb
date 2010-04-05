# instruct!
text(%~<?xml version="1.0" encoding="UTF-8"?>~)
declare!(:DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.0 Strict//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd")
tag!(:html, :xmlns => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", :lang => "en" ) {

  head {
	
    meta( :'http-equiv'=>"Content-Script-Type" , :content=>"text/javascript" )
    meta( :'http-equiv'=>"Content-Style-Type"  , :content=>"text/css" )
    meta( :'http-equiv'=>"Content-Language"    , :content=>"en-US" )
    meta( :'http-equiv'=>"Content-Type"        , :content=>"text/html; charset=utf-8" )
    meta( :'http-equiv'=>"Content-Language"    , :content=>"en-US" )
    
		mustache 'no_meta_cache' do
      meta( :'http-equiv'=>'expires' , :content=>'Thu, 12 Mar 2004 12:34:12 GMT' )
      meta( :'http-equiv'=>'pragma'  , :content=>'no-cache' )
    end

		meta( :name=>'description', :content=>"{{meta_description}}")

    meta( :name=>'keywords'   , :content=>"{{meta_keywords}}")

    title( "{{title}}" )

    link( :rel=>"shortcut icon", :href=>"/favicon.ico", :type=>"image/x-icon")
		
    mustache("not_mobile_request?") {
      link( :rel=>"stylesheet",    :href=>"{{css_file}}", :media=>"screen", :type=>"text/css" )
      # link( :rel=>"stylesheet",    :href=>"/skins/{{skin_name}}/css/{{page_name}}.css?v=#{Time.now.to_i}", :media=>"screen", :type=>"text/css" )
		}
    
		mustache "head_content"
   
  } # head

  body.the_body! {
    div.container! { 
    
      div.timestamp! '{{js_epoch_time}}'

      mustache 'loading' do
        div.loading! 'Loading...'
			end

      # ================= the_content ================================


			partial( "{{content_file}}" )

 

      # ================= the_footer ================================
      div.footer! {
				span "(c) {{copyright_year}} {{site_domain}}. Some rights reserved."
      } # the_footer
      
    
			
			# NOTE: 
			# Add the following to external scripts
			#     charset="UTF-8"
			# Don't use: "language" attribute, since that is deprecated for more than
			# 10 years.

      mustache 'javascripts' do
        script '', :src=>'{{src}}?{{time_i}}', :type=>'text/javascript'
      # if @javascripts
      #   if @javascripts.eql?( 'default' )
      #     text [ the_app.script_tag('/js/vendor/jquery.1.3.2.min.js'),
      #               the_app.script_tag('/js/vendor/jquery.cookie.js') ,
      #               the_app.script_tag('/js/swiss.js'),
      #             ''
      #           ].join("\n")
      #    
      #     self << "\n"      
      #     self <<  the_app.script_tag("#{page_name}.js")
      #   else
      #     self << @javascripts
      #   end

      end
    } # === container
  } # the_body
}


 


