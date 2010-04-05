# VIEW views/Members_lives.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/English/sass/Members_lives.sass
# NAME Members_lives

div.content! { 
  
	partial '__flash_msg' 
	
	h4 'Post message'

	form :id=>'form_lives_create', :action=>'/messages/', :method=>'POST' do
	
		input :type=>'hidden', :name=>'category', :value=>'tweet'
		input :type=>'hidden', :name=>'username', :value=>'{{current_member_username}}'

		fieldset {
			textarea '', :name=>'body'
		}

		fieldset {
			label 'Privacy'
			select :name=> 'privacy' do
				option 'Friends Only.', :value=>'friends', :selected=>'selected'
				option 'Public.', :value=>'public'
				option 'Just for me.', :value=>'private'
			end
		}

		# fieldset {
		# 	label 'Emotions'

		# }

		# fieldset {
		# 	label 'Private Labels'
		# 	textarea :name=>'private_labels'
		# }

		fieldset {
			label 'Labels'
			input.text :name=>'public_labels', :value=>'', :type=>'text'
		}

		div.buttons {
			button 'Save'
		}

	end
  
} # === div.content!

partial('__nav_bar')

