require 'specs/start_test'

describe 'Login (session new)' do

    it_renders_ok_on "/login"
    it_has_assets( "/login", :css )
    
end # === describe

describe 'Logout (session destroy)'  do

    it "redirects to Homepage" do
        get( "/logout" )
        follow!
        response.body.should.be == get("/").body
    end
    
    it "should flash a :success_msg only once" do

        get( "/logout" )
        response.original_headers.should.be == 1
        follow!
        scan_results = response.body.scan(/You have been logged out/i).flatten
        scan_results.size.should.be == 1

    end
    
end


