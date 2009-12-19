

mustache 'success_msg' do

	div.flash_msg!( :class=>'success_msg' ) {
		h4 'Success'
		div.msg '{{success_msg}}'
	}

end


mustache 'error_msg' do

	div.flash_msg!( :class=>'error_msg' ) {
		h4 '{{error_or_errors}}' 
		div.msg  { '{{error_msg_li}}' }
	}

end






