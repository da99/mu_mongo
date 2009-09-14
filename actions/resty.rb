
get '/:model/:id/' do
  n, props = validate_as_resty!
  eval("@#{clean_room[:model]} = n")
  render_mab
end

get '/:model/new/' do
  validate_as_resty!
  render_mab
end

post '/:model/' do 
  
  n, props = validate_as_resty! 
    
  begin
    flash.success_msg = ( " %s was saved." % english_name( n ).capitalize )
    redirect( "/#{n.class.to_s.underscore}/#{n[:id]}/")
  rescue Sequel::ValidationFailed => e
    flash.error_msg = to_html_list(e.message)
    redirect("/#{n.class.to_s.underscore}/new/")
  end

end # === post

put '/:model/:id/' do

  n = validate_as_resty!

  begin
    flash.success_msg = ( " %s was save. " % english_name(n).capitalize )
    redirect( "/#{n.class.to_s.underscore}/#{clean_room[:id]}" )
  rescue Sequel::ValidationFailed => e
    flash.error_msg = to_html_list(e.message)
    redirect("/#{n.class.to_s.underscore}/#{clean_room[:id]}/edit/")
  end
end

delete '/:model/:id/' do
  i = validate_as_resty!
  i.delete
  flash.success_msg = "Deletion was successful."
end
