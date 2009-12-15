



if !!the_app.flash.success_msg

  div.flash_msg!( :class=>'success_msg' ) {
      h4 'Success'
      div.msg the_app.flash.success_msg
      
  }

end


if !!the_app.flash.error_msg

  div.flash_msg!( :class=>'error_msg' ) {
      h4( the_app.flash.error_msg.split('</li>').size > 2 ? 'Errors' : 'Error' )
      div.msg {
        the_app.flash.error_msg
      }
  }

end






