
helpers {

  # === Use the following actions in your views. ===============================


  # === The following actions are used only by Resty actions. ============================
  # === They are not meant to be used by regular actions. ================================

  def model_class_required
    pass if !clean_room[:model]
    begin
      model_class
    rescue NameError
      pass
    end
  end

  def model_instance_required
    model_class_required
    pass if !model_instance
  end

  def model_class
    @model_class ||= Object.const_get(clean_room[:model].underscore.camelize)
  end

  def model_instance 
    @model_instance ||= begin
      clean_room[:id] && model_class[:id=>Integer(clean_room[:id])]
    rescue ArgumentError
      nil
    end
  end

} # === helpers

get '/:model/new/' do
  model_class_required
  require_log_in! if !model_class.creator?(:STRANGER)
  pass if !model_class.creator?(current_member)

  describe clean_room[:model], :new
  render_mab
end

post '/:model/' do 
  model_class_required

  begin
    n = model_class.creator current_member, clean_room
    flash.success_msg = ( " %s was saved." % english_name( n ).capitalize )
    redirect( "/#{clean_room[:model]}/#{n[:id]}/" )
  rescue model_class::UnauthorizedEditor
    pass
  rescue Sequel::ValidationFailed => e
    flash.error_msg = to_html_list(e.message)
    redirect("/#{clean_room[:model]}/new/")
  end

end # === post


get '/:model/:id/' do
  model_instance_required
  require_log_in! if !model_instance.viewer? :STRANGER
  pass if !model_instance.viewer?(current_member)

  describe clean_room[:model], :show
  render_mab
end

get '/:model/:id/:edit/' do
  require_log_in!
  model_instance_required
  pass if !model_instance.updator?(current_member)

  describe clean_room[:model], :edit
  render_mab
end

put '/:model/:id/' do
  require_log_in!
  model_instance_required

  begin
    n = model_instance.updator current_member, clean_room
    flash.success_msg = ( "%s was save. " % english_name(n).capitalize )
    redirect( request.path_info )
  rescue model_class::UnauthorizedEditor
    pass
  rescue Sequel::ValidationFailed => e
    flash.error_msg = to_html_list(e.message)
    redirect( request.path_info + "edit/" )
  end

end # === put

delete '/:model/:id/' do
  require_log_in!
  model_instance_required
  
  begin
    n = model_instance.deletor current_member, clean_room 
    flash.success_msg = "Deletion was successful."
    redirect( "/" )
  rescue model_class::UnauthorizedEditor
    pass
  end

end # === delete




__END__
get '/:model/:id/' do
  validate_as_resty!
  eval("@#{clean_room[:model]} = current_resty[:instance]")
  render_mab
end

get '/:model/new/' do
  validate_as_resty!
  render_mab
end

post '/:model/' do 
  
  validate_as_resty! 
  n = current_resty[:instance]  
  begin
    flash.success_msg = ( " %s was saved." % english_name( n ).capitalize )
    redirect( "/#{n.class.to_s.underscore}/#{n[:id]}/")
  rescue Sequel::ValidationFailed => e
    flash.error_msg = to_html_list(e.message)
    redirect("/#{n.class.to_s.underscore}/new/")
  end

end # === post

put '/:model/:id/' do

  validate_as_resty!
  n = current_resty[:instance]
  begin
    flash.success_msg = ( " %s was save. " % english_name(n).capitalize )
    redirect( "/#{n.class.to_s.underscore}/#{clean_room[:id]}" )
  rescue Sequel::ValidationFailed => e
    flash.error_msg = to_html_list(e.message)
    redirect("/#{n.class.to_s.underscore}/#{clean_room[:id]}/edit/")
  end
end

delete '/:model/:id/' do
  validate_as_resty!
  current_resty[:instance].destroy
  flash.success_msg = "Deletion was successful."
end
