


describe 'Member creation' do

  it( 'creates a username after save.' ) {
    u_name = 'da01' + Time.now.utc.to_i.to_s
    begin
    m = Member.editor_create(nil, { :password=>'test123test', 
                :confirm_password => 'test123test', 
                :username=>u_name}
                )
    rescue Sequel::ValidationFailed
      raise $!
    end
    
    u = Username.reverse_order(:id).first
    u[:owner_id].should.be == m[:id]
    u[:username].should.be == u_name
  }
 
  it( 'does not create itself + username if username is already taken.' ) {
    u_count = Username.order(:id).count
    m_count = Member.order(:id).count
    u_name = Username.reverse_order(:id).first[:username] 
    begin
    Member.editor_create(nil, { :password=>'test123test',
      :confirm_password => 'test123test',
      :username => u_name
    })
    rescue Sequel::ValidationFailed
      $!.message.to_s.should.be =~ /^Username is already taken/i
    end
    Username.order(:id).count.should.be == u_count
    Member.order(:id).count.should.be == m_count
  }
end # ===
