# MAB   ~/megauni/templates/en-us/mab/Members_life_predictions.rb
# SASS  ~/megauni/templates/en-us/sass/Members_life_predictions.sass
# NAME  Members_life_predictions

class Members_life_predictions < Base_View

  include Base_View_Member_Life

  def title 
    "Predict the Life of #{username}"
  end
  
end # === Members_life_predictions 
