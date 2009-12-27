

mustache 'flash_msg?' do

	div.flash_msg!( :class=>'{{class_name}}' ) {
		h4 '{{title}}'
		div.msg '{{msg}}'
	}

end



