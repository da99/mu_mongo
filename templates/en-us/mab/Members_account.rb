# VIEW views/Members_account.rb
# SASS ~/megauni/templates/en-us/sass/Members_account.sass
# NAME Members_account


div.clubs_owned! {
  show_if 'no_clubs_owned' do
    p "You don't own any clubs at the moment."
  end
  div.create_club {
    a("Create a fan club.", :href=>'/club-create/')
  }
  loop 'clubs_owned'
} # clubs_owned!

partial('__nav_bar')

