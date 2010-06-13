# MAB   ~/megauni/templates/en-us/mab/Members_account.rb
# SASS  ~/megauni/templates/en-us/sass/Members_account.sass
# NAME  Members_account

class Members_account < Base_View

  def title 
    "Your Account on #{site_title}"
  end

  def clubs_owned
    []
  end
  
end # === Members_account 
