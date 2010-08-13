# MAB   ~/megauni/templates/en-us/mab/Members_lives.rb
# SASS  ~/megauni/templates/en-us/sass/Members_lives.sass
# NAME  Members_lives

class Members_lives < Base_View

  def title 
    current_member_username
  end

  def current_member_username
    app.env['results.username']
  end

  def stream
    @cache_messages_stream ||= compile_messages(app.current_member.stream(current_member_username))
  end

end # === Members_lives 
