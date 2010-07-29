# MAB   ~/megauni/templates/en-us/mab/Clubs_read_e.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_read_e.sass
# NAME  Clubs_read_e

class Clubs_read_e < Base_View
 
  def title 
    return "Encyclopedia: #{club_title}" unless club.life_club?
    "The Encyclopedia of #{club_filename}"
  end

  def quotes
    @cache['messages.quotes'] ||= begin
                                    filter_and_compile_facts( 'e_quote' )
                                  end
  end

  def chapters
    @cache['messages.chapters'] ||= begin
                                      filter_and_compile_facts( 'e_chapter' )
                                    end
  end

  def quotes_or_chapters?
    !quotes.empty? && !chapters.empty?
  end

  def no_quotes_or_chapters?
    !quotes_or_chapters?
  end

  def facts
    @cache['messages.facts'] ||= compile_messages( app.env['results.facts'] )
  end

  private

  def filter_and_compile_facts model
    facts.select { |mess| mess['message_model'] == model }
  end
  
end # === Clubs_read_e 
