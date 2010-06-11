# models/Member.rb

class Test_Model_Member_Update < Test::Unit::TestCase

  must 'allow password to be reset' do
    mem = create_member
    mem.reset_password
    assert_equal true, mem.password_in_reset?
  end

  must 'raise Member::Password_Reset during authentication if password is in reset' do
    pwrd   = 'test12345'
    mem    = create_member(:password => pwrd, :confirm_password => pwrd)
    mem.reset_password
    assert_raise Member::Password_Reset do
      Member.authenticate(:username => mem.usernames.first, :password=>pwrd)
    end
  end

  must 'set code for password reset' do
    mem = create_member
    code = mem.reset_password
    assert_equal true, (code.size > 6)
  end

  must 'allow multiple password resets' do
    mem = create_member
    old_code = nil
    6.times { |i|
      code = mem.reset_password
      assert_not_equal code, old_code
      old_code = code
    }
  end

  must 'allow allow authentication with new password after reset' do
    pwrd = 'test12345t6'
    new_pwrd = "12345test"
    mem = create_member :password=>pwrd, :confirm_password=>pwrd
    code = mem.reset_password
    target = Member.by_id(mem.data._id)
    target.change_password_through_reset(:code=>code, :password=>new_pwrd, :confirm_password=>new_pwrd)

    final = Member.by_id(mem.data._id)
    assert Member.authenticate(:username=>mem.usernames.first, :password=>new_pwrd)
  end

  must 'raise Member::Invalid if new password/confirmation do not match' do
    new_pwrd="1235test"
    mem = create_member
    code = mem.reset_password

    target = Member.by_id(mem.data._id)
    assert_raise(Member::Invalid) {
      target.change_password_through_reset(:code=>code, :password=>new_pwrd, :confirm_password=>'somethig')
    }
  end

  must 'raise Invalid_Password_Reset_Code if code does not match for new password.' do
    new_pwrd="1235test"
    mem = create_member
    mem.reset_password

    target = Member.by_id(mem.data._id)
    assert_raise(Member::Invalid_Password_Reset_Code) {
      target.change_password_through_reset(:code=>'something', :password=>new_pwrd, :confirm_password=>new_pwrd)
    }
  end


end # === class Test_Model_Member_Update
