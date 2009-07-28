# ======================================================================
# require File.expand_path('test/base_spec')
require 'ramaze'
require 'ramaze/spec'

require __DIR__('../../start')
# Ramaze.options.roots = __DIR__('../../')
# ======================================================================


describe MainController do
  behaves_like 'http', 'xpath'
  ramaze :error_page => true

  it 'should show start page' do
    got = get('/')
    # BusyConfig.test_log_it got.body # .split("\n") .slice(100,20).join("\n")
    got.status.should == 200
    got.at('//title').text.strip.should == MainController.new.index
  end

  it 'should send a 404 status code for a missing action.' do
  
    got = get('/123')    
    got.status.should == 404
    
    #got.at('//div').text.strip.should == MainController.new.notemplate
  end
end
