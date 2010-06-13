# VIEW ~/megauni/views/Members_reset_password.rb
# SASS ~/megauni/templates/en-us/sass/Members_reset_password.sass
# NAME Members_reset_password

div.content! { 
  
	show_if("reset?") {
		p "Your password has been reset. Check your email: {{email}}"
	}

	show_if("no_reset?") {
		p "No account found with email: {{email}}"
		p { 
			span "Check for typos and "
			a("go back", :href=>"/log-in/")
		}
	}
  
} # === div.content!

partial('__nav_bar')
