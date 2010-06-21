# VIEW views/Clubs_edit.rb
# SASS ~/megauni/templates/en-us/sass/Clubs_edit.sass
# NAME Clubs_edit

div.col.the_form! {

  form.edit_form!(:action=>'{{club_href}}', :method=>'post') {
  
    _fieldset_method_put

    fieldset_input_text 'Filename:', nil, '{{club_filename}}'
    
    fieldset_input_text 'Title:', nil, '{{club_title}}'

    fieldset_textarea 'Teaser:', nil, '{{club_teaser}}'

    div.buttons {
      button.update 'Update', :onclick=>'document.getElementById(\'edit_form\').submit(); return false;'
    }

  } # === form

} # === div.form!

partial('__nav_bar')

