# VIEW views/Members_account.rb
# SASS ~/megauni/templates/en-us/sass/Members_account.sass
# NAME Members_account

div.col.kill_me! {
  
  p %@
    Would you like to delete your {{site_name}} account? 
  @
  
  p %@
    When I say "delete", I mean it. It will be as if you never existed.
  @

  p %@ Your usernames will also be deleted. ALL of them.@

  p {
    strong 'Remember:'
    span 'Delete ALL your clubs first. All else they will remain.'
  }

  form.delete_account_form!(:method=>'POST', :action=>"/delete-account-forever-and-ever/") {
    _method_delete
    p { strong "Are you really, really sure? (There is no undo.)" }
    div.buttons {
      button("Yes!", :onclick=>"if(confirm('Are you really, really sure?')) { document.getElementById('delete_account_form').submit(); }; return false;")
    }
  } # form

} # div.kill_me!

partial('__nav_bar')

