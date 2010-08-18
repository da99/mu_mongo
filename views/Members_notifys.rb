# MAB   ~/megauni/templates/en-us/mab/Members_notifys.rb
# SASS  ~/megauni/templates/en-us/sass/Members_notifys.sass
# NAME  notifys
# CONTROL models/Member.rb
# MODEL   controls/Member.rb

class Members_notifys < Base_View

  def title 
    'Notifys'
  end
  
  def notifys
    []
  end

  def usernames
    []
  end

  def clubs_not_owned
    []
  end

end # === notifys 
