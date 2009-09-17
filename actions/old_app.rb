get '/eggs?/' do
  show_old_site :busy_noise
end

get '/busynoise/' do
  redirect '/busy-noise/'
end

get '/busy-noise/' do
  show_old_site :busy_noise
end

get '/myeggtimer/' do
  redirect '/my-egg-timer/'
end

get '/my-egg-timer/' do
  show_old_site :my_egg_timer
end

get '/javascripts/mootools.js' do
  redirect('/my-egg-timer/javascripts/mootools.js', 301)
end
get '/javascripts/pages/index.js' do
  redirect('/my-egg-timer/javascripts/pages/index.js', 301)
end
get '/javascripts/persist-js/persist-min.js' do
  redirect('/my-egg-timer/javascripts/persist-js/persist-min.js', 301)
end

