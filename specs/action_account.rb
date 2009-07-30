require 'specs/start_test'

describe 'Create Account' do

    it_renders_ok_on '/sign-up'
    
    it_has_assets('/sign-up', :css)

end # === describe
