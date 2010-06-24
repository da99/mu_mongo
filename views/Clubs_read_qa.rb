# MAB   ~/megauni/templates/en-us/mab/Clubs_read_qa.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_qa.sass
# NAME  Clubs_read_qa

class Clubs_read_qa < Base_View
 
  def title 
    return "Q & A: #{club_title}" if not club.life_club?
    "Q & A with #{club_filename}"
  end

  def questions
    @cache['results.questions'] ||= compile_messages(app.env['results.questions'])
  end
  
end # === Clubs_read_qa 
