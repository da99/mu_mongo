# VIEW ~/megauni/views/Members_notifys.rb
# SASS ~/megauni/templates/en-us/sass/Members_notifys.sass
# NAME Members_notifys
# CONTROL models/Member.rb
# MODEL   controls/Member.rb

if_empty 'notifys' do
	div 'You have no notifys.'
end

loop_messages 'notifys'

filter_options 'notifys'

partial('__nav_bar')

