# MAB   ~/megauni/templates/en-us/mab/Clubs_by_id.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_by_id.sass
# MODEL ~/megauni/models/Club.rb
# CONTROL ~/megauni/controls/Clubs.rb
# NAME  Clubs_by_id

require 'views/__Base_View_Club'

class Clubs_by_id < Base_View
 
  include Base_View_Club

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
    @cache['results.messages_latest'] ||= begin
                                              @app.env['results.messages_latest'].map { |doc|
                                                doc['compiled_body'] = from_surfer_hearts?(doc) ? doc['body'] : auto_link(doc['body'])
                                                doc['href'] = "/mess/#{doc['_id']}/"
                                                doc
                                              }
                                            end
  end
  
end # === Clubs_by_id 
