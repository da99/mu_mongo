

class Test_Model_Member_Read < Test::Unit::TestCase


  must 'return user if username/password pass authentication' do
    doc = Member.authenticate(:username=>regular_username_1, :password=>regular_password_1)
    assert_equal(
      regular_username_1,
      doc.usernames.detect { |un| un == regular_username_1 }
    )
  end

  must 'Couch_Plastic::Not_Found is user is not found during authentication' do
    assert_raise(Couch_Plastic::Not_Found) do
      Member.authenticate(:username=>'billy_west', :password=>'my-name-is-my-password')
    end
  end

  must 'raise Member::Wrong_Password if username is correct, password is incorrect' do
    mem, un, pass = generate_random_member
    assert_raise(Member::Wrong_Password) do
      Member.authenticate(:username=>un, :password=>'yoyo-homeslice')
    end
  end

  must 'return user if authentication passes, despite previous failed attempts' do
    mem, un, pass = generate_random_member
    begin
      Member.authenticate(:username=>un, :password=>'yoyo-again')
    rescue Member::Wrong_Password
    end
    
    doc = Member.authenticate(:username=>un, :password=>pass)
    assert_equal(doc.data._id, mem.data._id)
  end


  must 'raise Member::Password_Reset after 3 failed authentication attempts, no matter if correct password' do
    mem, username, pass = generate_random_member
    3.times do 
      begin
        Member.authenticate :username=>username, :password=>'yoyo-i-want-vitamins' 
      rescue Member::Wrong_Password
      rescue Member::Password_Reset
      end
    end

    assert_raise(Member::Password_Reset) do
      Member.authenticate :username=>username, :password=>pass
    end
  end

  must 'return failed attempts for current day' do
    mem, username, pass = generate_random_member
    [1,2,3].each do |i|
      begin
        Member.authenticate :username=>username, :password=>'yoyo-i-want-vitamins' 
      rescue Member::Wrong_Password
      rescue Member::Password_Reset
      end
      assert_equal( i, Member.failed_attempts_for_today(mem).count )
    end
  end

  must 'stop inserting failed attempts after the 3rd attempt' do
    mem, username, pass = generate_random_member
    5.times do
      begin
        Member.authenticate :username=>username, :password=>'yoyo-i-want-vitamins' 
      rescue Member::Wrong_Password
      rescue Member::Password_Reset
      end
    end

    assert_equal( 3, Member.failed_attempts_for_today(mem).size )
  end

  must 'add username info of owner for an Enumerable of databasse records.' do
    mem          = regular_member_3
    messages     = (1..3).to_a.map { |i| create_message(mem).data.as_hash }
    results      = Member.add_owner_usernames_to_collection(messages)
    mem_by_un    = Member.by_username(results.first['owner_username'])
    mem_by_un_id = Member.by_username_id(results.first['owner_id'])
    assert_equal mem_by_un, mem_by_un_id
  end

  must 'raise Member::Invalid_Security_Level if :has_power_of? given invalid parameter.' do
    mem = regular_member_2
    assert_raise Member::Invalid_Security_Level do
      mem.has_power_of?(nil)
    end
  end

end # === class Member_Read
