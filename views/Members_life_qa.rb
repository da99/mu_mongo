# MAB   ~/megauni/templates/en-us/mab/Members_life_qa.rb
# SASS  ~/megauni/templates/en-us/sass/Members_life_qa.sass
# NAME  Members_life_qa

require 'views/__Base_View_Member_Life'

class Members_life_qa < Base_View

  include Base_View_Member_Life

	def title 
    "Q&A for #{username}"
  end

	def questions
	  compiled_owner_messages 'question'
  end
  
end # === Members_life_qa 
