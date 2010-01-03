require 'tests/__helper__'


class Member_Read < Test::Unit::TestCase


	must 'return user if username/password pass authentication' do
    doc = Member.authenticate(regular_username_1, regular_password_1)
    assert_equal(
      regular_username_1,
      doc.data.lives[:friend][:username]
    )
  end

  must 'Couch_Doc::Not_Found is user is not found during authentication' do
    assert_raise(Couch_Doc::Not_Found) do
      Member.authenticate('billy_west', 'my-name-is-my-password')
    end
  end

  must 'raise Member::Wrong_Password if username is correct, password is incorrect' do
    assert_raise(Member::Wrong_Password) do
      Member.authenticate(regular_username_1, 'yoyo-homeslice')
    end
  end

  must 'return user if authentication passes, despite previous failed attempts' do
    begin
      Member.authenticate(regular_username_1, 'yoyo-again')
    rescue Member::Wrong_Password
    end
    
    doc = Member.authenticate(regular_username_1, regular_password_1)
    assert_equal(doc.data._id, regular_mem_1.data._id)
  end


  must 'raise Member::Account_Reset after 3 failed authentication attempts, no matter if correct password' do
    3.times do 
      begin
        Member.authenticate(admin_username, 'yoyo-i-want-vitamins')
      rescue Member::Wrong_Password
      end
    end

    assert_raise( Member::Account_Reset ) do
      Member.authenticate(admin_username, admin_password)
    end
  end

end # === class Member_Read
