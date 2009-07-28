require 'specs/start_test'

describe 'Homepage' do

    it_renders_ok_on( '/' )
    
    it_has_assets( '/' )

end # === describe

