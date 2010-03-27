# MAB   /home/da01tv/MyLife/apps/megauni/templates/English/mab/Clubs_by_id.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/English/sass/Clubs_by_id.sass
# NAME  Clubs_by_id

class Clubs_by_id < Base_View

  def title 
    @app.env['results.club'].data.title
  end

  def club
    @app.env['results.club']
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
  
end # === Clubs_by_id 
