save_to('title') { 'My Account' }
partial('__nav_bar')


div.content!  { 

  div.usernames {
    h4 'Usernames'
    a.new('Add Another Username.', :href=>'#add_username')
    the_app.current_member.data.lives.each { |life_cat, life|
      div.un(:id=>"life_#{life_cat}") {
        div.username life[:username]
        div.category life_cat
        div.email( life[:email] || "[No email address set.]" )
        a.edit("Edit", :href=>'#edit_username')
      }
    }
  }

  div.delete_account! {
    h4 'Delete Everything.'
    div.msg "Once you delete your account, all usernames,
      all data,
      will be lost permanently. 
      For your privacy, there is no going back. No undo.
      It will be as if you never existed on this website."
    a.delete('Delete Entire Account', :href=>'#delete')
  }

} # === div
