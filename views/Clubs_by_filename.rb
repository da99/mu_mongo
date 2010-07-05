# MAB   ~/megauni/templates/en-us/mab/Clubs_by_filename.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_by_filename.sass
# MODEL ~/megauni/models/Club.rb
# CONTROL ~/megauni/controls/Clubs.rb
# NAME  Clubs_by_filename

class Clubs_by_filename < Base_View
 
  def mini_nav_bar?
    true
  end
  
  def months
    %w{ 8 4 3 2 1 }.map { |month|
      { :text => Time.local(2007, month).strftime('%B %Y'),
        :href=>"/clubs/hearts/by_date/2007/#{month}/" 
      }
    }
  end

  def public_labels
    @public_labels ||= Message.public_labels.map {|label| {:filename => label} }
  end

  def messages_latest
    compile_and_cache( 'messages.latest' , app.env['results.messages_latest'] )
  end

  def club_teaser
    if club.life_club? && !club.data.teaser
      "Post stuff to this universe."
    else
      super
    end
  end

  
end # === Clubs_by_filename
