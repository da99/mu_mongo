require '__rack__'

class Model_Member

  
  include FeFe_Test

context 'Member creation' 

  it( 'creates a username after save.' ) {
    u_name = 'da01' + Time.now.utc.to_i.to_s
    begin
    m = Member.creator(nil, { :password=>'test123test', 
                :confirm_password => 'test123test', 
                :username=>u_name}
                )
    rescue Sequel::ValidationFailed
      raise $!
    end
    
    u = Username.reverse_order(:id).first
    demand_equal u[:owner_id], m[:id]
    demand_equal u[:username], u_name
  }
 
  it( 'does not create itself + username if username is already taken.' ) {
    u_count = Username.order(:id).count
    m_count = Member.order(:id).count
    u_name = Username.reverse_order(:id).first[:username] 
    begin
    Member.creator(nil, { :password=>'test123test',
      :confirm_password => 'test123test',
      :username => u_name
    })
    rescue Sequel::ValidationFailed
      demand_regex_match /^Username is already taken/i, $!.message.to_s
    end
    demand_equal Username.order(:id).count, u_count
    demand_equal Member.order(:id).count, m_count
  }
end # ===
