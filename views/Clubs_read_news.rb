# MAB   ~/megauni/templates/en-us/mab/Clubs_read_news.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_news.sass
# NAME  Clubs_read_news

class Clubs_read_news < Base_View

  def title 
    "News: #{super}"
  end
  
  def news
    @cache['results.news'] ||= compile_messages(app.env['results.news'])
  end
  
end # === Clubs_read_news 
