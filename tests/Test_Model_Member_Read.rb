

class Test_Model_Member_Read < Test::Unit::TestCase


  must 'return user if username/password pass authentication' do
    doc = Member.authenticate(:username=>regular_username_1, :password=>regular_password_1)
    assert_equal(
      regular_username_1,
      doc.data.lives[:friend][:username]
    )
  end

  must 'Couch_Doc::Not_Found is user is not found during authentication' do
    assert_raise(Couch_Doc::Not_Found) do
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

      assert_equal( i, Member.GET_failed_attempts_for_today(mem).size )
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

    assert_equal( 3, Member.GET_failed_attempts_for_today(mem).size )
  end

end # === class Member_Read
