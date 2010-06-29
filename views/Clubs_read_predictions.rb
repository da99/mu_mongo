# MAB   ~/megauni/templates/en-us/mab/Clubs_read_predictions.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_predictions.sass
# NAME  Clubs_read_predictions

class Clubs_read_predictions < Base_View

  def title 
    return "Predictions: #{club_title}" unless club.life_club?
    "Predictions for #{club_filename}"
  end

  def predictions
    []
  end
  
end # === Clubs_read_predictions 
