get '/:model/new/' do
  restafarize!
  render_mab
end

post '/:model/' do 
  
  level, model_class = restafarize! 
    
  begin
    n = model_class.creator current_member, clean_room
    flash.success_msg = ( " %s was saved." % english_name( n ).capitalize )
    redirect( "/#{model_class.to_s.underscore}/#{n[:id]}/")
  rescue Sequel::ValidationFailed => e
    flash.error_msg = to_html_list(e.message)
    redirect("/#{model_class.to_s.underscore}/new/")
  end

end # === post

put '/:model/:id/' do

  level, model_class = restafarize!

  begin
    n = model_class.updator current_member, clean_room
    flash.success_msg = ( " %s was save. " % english_name(n).capitalize )
    redirect( "/#{model_class.to_s.underscore}/#{clean_room[:id]}" )
  rescue Sequel::ValidationFailed => e
    flash.error_msg = to_html_list(e.message)
    redirect("/#{model_class.to_s.underscore}/#{clean_room[:id]}/edit/")
  end
end
