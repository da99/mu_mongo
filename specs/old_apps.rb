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
describe 'Old Apps' do

  it 'shows a moving message for www.myeggtimer.com' do
    domain = 'www.myeggtimer.com'
    get '/', {}, { 'HTTP_HOST'=> domain }
    last_response.body.should =~ /over to the new address/
  end 

  it 'should redirect www.busynoise.com/ to /egg' do
    domain = 'www.busynoise.com'
    get '/', {}, { 'HTTP_HOST' =>domain  }
    follow_redirect!
    last_request.fullpath.should.be == '/egg'
  end

  it 'shows a moving message for www.busynoise.com/egg' do 
    domain =  'www.busynoise.com'
    get '/egg', {}, { 'HTTP_HOST'=> domain }
    last_request.host.should == domain 
    last_request.fullpath.should == '/egg'
    last_response.body.should =~ /This website has moved/
  end

  it 'renders /bigstopwatch' do
    get '/bigstopwatch'
    follow_redirect!
    last_response.should.be.ok
  end

  it 'renders /bigstopwatch/' do
    get '/bigstopwatch/'
    last_response.should.be.ok
  end

end
