# MAB   ~/megauni/templates/en-us/mab/Members_lifes.rb
# SASS  ~/megauni/templates/en-us/sass/Members_lifes.sass
# NAME  lifes
# CONTROL models/Member.rb
# MODEL   controls/Member.rb

class Members_lifes < Base_View

  def title 
    'Your Lifes'
  end

	def lifes
		# [{'username'=>'Not done', 'href'=>'/no-where'}]
		current_member.username_menu
	end
  
end # === lifes 
