require 'specs/start_test'

describe 'Create Account' do

    it_renders_ok_on '/signup'
    
    it_has_assets('/signup', :css)

end # === describe
