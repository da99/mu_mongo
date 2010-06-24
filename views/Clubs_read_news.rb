# MAB   ~/megauni/templates/en-us/mab/Clubs_read_news.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_news.sass
# NAME  Clubs_read_news

class Clubs_read_news < Base_View

  def title 
    return "News: #{club_title}" unless club.life_club?
    "#{club_filename}'s Important News"
  end
  
  def news
    @cache['results.news'] ||= compile_messages(app.env['results.news'])
  end
  
end # === Clubs_read_news 
