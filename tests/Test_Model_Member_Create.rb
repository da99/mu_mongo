# models/Member.rb

class Test_Model_Member_Create < Test::Unit::TestCase

  RAND_NUMS = (1..100).to_a.map {|a| rand(10000)}.uniq
  def random_username
    "da01_#{RAND_NUMS.pop}"
  end

  must 'raise Perfection_Required if :add_life is invalid' do
    assert_raise Couch_Plastic_Validator::Perfection_Required do
      Member.create( nil, {:password => 'pass123', :add_life=>'secret_agent'})
    end
  end

  must 'raise Unauthorized_Creator if editor is not nil' do
    assert_raise( Member::Unauthorized_Creator ) do
      Member.create( 
        Member.new, 
        {:password=>'pass12pass', :confirm_password=>'pass12pass', 
         :add_life=>'friend', :add_life_username=>random_username}
      )
    end
  end

  must 'require a password' do
    doc = begin
            Member.create( nil, {
              :password => nil,
              :add_life => 'friend',
              :add_life_username => random_username
            })
          rescue Member::Invalid => e
            e.doc
          end
    assert_equal "Password is required.", doc.errors.first
  end

  must 'require :add_life_username' do
    doc = begin
            Member.create(nil, {:password => 'pass123pass', 
                                :confirm_password => 'pass123pass',
                                :add_life => 'friend', 
                                :add_life_username => nil })
          rescue Member::Invalid => e
            e.doc
          end
    assert_equal "Username is required.", doc.errors.first
  end

  must 'require a unique username' do
    username = Member.db_collection.find_one!()['_id']
    doc = begin
            Member.create(nil, {:password => 'pass132pass',
                                :confirm_password=>'pass132pass',
                                :add_life => 'friend', 
                                :add_life_username => username })
          rescue Member::Invalid => e
            e.doc
          end
    assert_equal "Username already taken: #{username}", doc.errors.detect { |msg| msg =~ /Username/ }
  end

  must 'add a UUID to data._id' do
    doc = Member.create(nil, {
      :password => "pass123pass", 
      :confirm_password => "pass123pass",
      :add_life => 'friend', 
      :add_life_username=>random_username
     }
    )
    assert_match( /\A[a-z0-9\-]{10,}\Z/i, doc.data._id )
  end

  must 'return false for new?' do
    doc = Member.create(nil, {
      :password => "pass123pass", 
      :confirm_password => "pass123pass",
      :add_life => 'friend', 
      :add_life_username=>random_username
     }
    )
    assert_equal( false, doc.new? )
  end

  must 'set security level to "MEMBER"' do
    doc = Member.create(nil, {
      :password => "pass123pass", 
      :confirm_password => "pass123pass",
      :add_life => 'friend', 
      :add_life_username=>random_username
     }
    )
    assert_equal( "MEMBER", doc.data.security_level )
  end

  must 'have power of "MEMBER"' do
    doc = Member.create(nil, {
      :password => "pass123pass", 
      :confirm_password => "pass123pass",
      :add_life => 'friend', 
      :add_life_username=>random_username
     }
    )
    assert_equal( true, doc.has_power_of?("MEMBER") )
  end

  must 'not have power of "Admin"' do
    doc = Member.create(nil, {
      :password => "pass123pass", 
      :confirm_password => "pass123pass",
      :add_life => 'friend', 
      :add_life_username=>random_username
     }
    )
    assert_equal( false, doc.has_power_of?("ADMIN") )
  end

end # === class _create
