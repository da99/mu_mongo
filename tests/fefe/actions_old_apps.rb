require '__rack__'

# 
#
# Note: when setting 'SERVER_NAME', the value 
# changes back to the default, 'example.org', 
# after a redirect. 
# 
# This means you won't be able to have multiple 
# redirects if settings a 'SERVER_NAME', because
# it would not reflect real-world conditions.
#
#
class Actions_Old_Apps

  
  include FeFe_Test

  context 'Old Apps' 

  it 'shows a moving message for www.myeggtimer.com' do
    domain = 'www.myeggtimer.com'
    get '/', {}, { 'HTTP_HOST'=> domain }
    demand_regex_match /over to the new address/, last_response.body
  end 

  it 'should redirect www.busynoise.com/ to /egg/' do
    domain = 'www.busynoise.com'
    get '/', {}, { 'HTTP_HOST' =>domain  }
    follow_redirect!
    demand_equal '/egg', last_request.fullpath
  end

  it 'shows a moving message for www.busynoise.com/egg/' do
    domain =  'www.busynoise.com/'
    get '/egg/', {}, { 'HTTP_HOST'=> domain }
    demand_equal domain, last_request.host
    demand_equal '/egg/', last_request.fullpath
    demand_regex_match /This website has moved/, last_response.body
  end

  it 'shows a moving message for www.busynoise.com/egg' do 
    domain =  'www.busynoise.com'
    get '/egg', {}, { 'HTTP_HOST'=> domain }
    demand_equal last_request.host, domain 
    demand_equal last_request.fullpath, '/egg'
    demand_regex_match /This website has moved/, last_response.body 
  end

  it 'renders /bigstopwatch' do
    get '/bigstopwatch'
    demand_equal 200, last_response.status
  end

  it 'renders /bigstopwatch/' do
    get '/bigstopwatch/'
    demand_equal 200, last_response.status
  end

end
