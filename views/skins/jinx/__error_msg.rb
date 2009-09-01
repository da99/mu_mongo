div.error_msg {
  div.title( @error_msg["\n"] ? 'Errors:' : 'Error:' )
  div.msg { @error_msg.split("\n").map { |slice| Wash.html(slice) }.join("<br />") }
}
