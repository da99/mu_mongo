require '__rack__'

class Model_Member

  include FeFe_Test

	context 'Member creation' 

  it( 'does not create itself + username if username is already taken.' ) {
		
		u_name = "da01-#{Time.now.to_i}"
    begin
			Member.create(nil, { 
					:password=>'test123test',
					:confirm_password => 'test123test',
					:add_life_username => u_name,
					:add_life => 'friend'
			})
    rescue Member::Invalid
      demand_regex_match( /^Username is already taken/i, $!.message.to_s )
    end
    
		err = begin
			Member.by_username(u_name)
		rescue Couch_Doc::No_Record_Found
			'not_found'
		end

		demand_equal err, 'not_found'
		
  }
end # ===
