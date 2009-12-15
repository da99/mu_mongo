div.error_msg {
  div.title( app_vars[:error_msg]["\n"] ? 'Errors:' : 'Error:' )
  div.msg { app_vars[:error_msg].split("\n").join("<br />") }
}
