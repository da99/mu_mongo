# VIEW ~/megauni/views/Members_follows.rb
# SASS ~/megauni/templates/en-us/sass/Members_follows.sass
# NAME Members_follows
# CONTROL models/Member.rb
# MODEL   controls/Member.rb

div.newspaper! {
	show_if('no_stream?') {
		div('You have not subscribed to anyone\'s life.')
	}
	show_if 'stream?' do  
		h4 'The latest from your subscriptions:'
		show_if 'stream' do
			div.message do
				div.body( '{{{compiled_body}}}' )
				div.permalink {
					a('Permalink', :href=>"{{href}}")
				}
			end
		end
	end
} # === div.stream!
  
filter_options 'follows'

partial('__nav_bar')
