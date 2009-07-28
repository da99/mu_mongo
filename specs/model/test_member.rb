require File.expand_path('test/base_spec')

describe 'Member has_permission_level?' do

  behaves_like 'member_fixture'

  it 'should raise UnknownPermissionLevel' do
    lambda { @user_1.has_permission_level?( :unknown ) }.
        should.raise(Member::UnknownPermissionLevel)
  end

  it 'should convert argument into Integer/Fixum' do
    perm_as_string = Member::STRANGER.to_s
    @user_1.has_permission_level?( perm_as_string ).should.be == true

    perm_as_string = Member::MEMBER.to_s
    @user_1.has_permission_level?( perm_as_string ).should.be == true
  end

end # === describe 'Member has_permission_level?'


describe 'Member#validate for :email' do

  before {
    @mem = Member.new
  }

  # ----------- :email 
  it "should strip :email." do
    test_email = " \t \t unique_address@diegoalban.com  \t \t "
    @mem.email= test_email
    begin
      @mem.validate
    rescue Sequel::ValidationFailed
    end
    @mem.email.should == test_email.strip
  end
  
  it "should allow :email to be nil" do
    begin
      @mem.validate
    rescue Sequel::ValidationFailed
    end
    @mem.errors[:email].should.be.empty
  end
  
  it "should allow :email to be an empty string" do
    m = Member.new(:email=>'')
    begin
      m.validate
    rescue Sequel::ValidationFailed
    end
    m.errors[:email].should.be.empty
  end
  
  it "should NOT allow :email without '@' and 1 dots." do
    8.times do |i|
      m = Member.new(:email=>('a'*(i+1)))
      m.find_validation_errors
      m.errors[:email].first.should.be.instance_of String
    end
  end
  
  it "should allow at least 7 characters when using an email with '@' and 1 dot" do
    m = Member.new(:email=>'a@i.cm')
    m.find_validation_errors
    m.errors[:email].first.should =~ /invalid/i
  
    m = Member.new(:email=>'a@it.cm')
    m.find_validation_errors
    m.errors[:email].should.be.empty?
    
    m = Member.new(:email=>'a@it.com')
    m.find_validation_errors
    m.errors[:email].should.be.empty?
  end
  
  
  it "should NOT allow any newlines" do
    test_email = "test@\nexample.com"
    m = Member.new
    m.email = test_email
    m.find_validation_errors
    m.errors[:email].first.should.be.instance_of String
  end 

  it 'should allow a valid email' do
    @mem.email = 'd@a.us.it'
    begin
      @mem.validate
    rescue Sequel::ValidationFailed
    end
    @mem.errors[:email].should.be.empty
  end
  #--------------- end :email ----------------------------------------------------------


end  # ==== describe 'Member#validate :email'


describe "Member#validate for :timezone "do

  before {
    @mem = Member.new
  }
  
  it "should strip :timezone" do
    @mem.timezone = "  \t\t America/New_York \t\t"
    begin
      @mem.validate
    rescue Sequel::ValidationFailed
    end
    @mem.timezone.should == "America/New_York"
  end
  
  it "should allow a valid timezone" do
    @mem.timezone = 'America/New_York'
    begin
      @mem.validate
    rescue Sequel::ValidationFailed
    end
    @mem.errors[:timezone].should.be.empty
  end
  
  it "should NOT allow an invalid timezone" do
    @mem.timezone = 'Mars/Midway_Station'
    begin
      @mem.validate
    rescue Sequel::ValidationFailed
    end
    @mem.errors[:timezone].first.should =~ /Invalid/i
  end
  
end # === describe  "Member#validate for :timezone "


describe 'Member#validate for minimal valid records' do

  before {
    @mem = Member.new
  }

  it 'should require only a :username, :password, and :confirm_password to save properly.' do
    @mem.username = "da#{rand(100000)}"
    @mem.password = "something#{rand(110000)}"
    @mem.confirm_password = @mem.password
    @mem.save
    @mem.should.be.valid
  end
  
end # ==== describe 


describe 'Member#validate for :username' do

  before {
    @mem = Member.order(:id).last
  }

  it 'should only allow a new Member with a UNIQUE username'  do
    # Let's fail first.
    new_mem = Member.new
    new_mem.username = @mem.username
    new_mem.password = "something 1244"
    begin
      new_mem.validate
    rescue Sequel::ValidationFailed
    end
    new_mem.errors[:username].first.should.be.instance_of String

    # Now let's pass.
    new_mem.username = "da_unique_#{rand(10000)}"

    begin
      new_mem.validate
    rescue Sequel::ValidationFailed
    end
    
    new_mem.errors[:username].should.be.empty
  end

  it 'should NOT allow a really long username (30 or more characters)' do
    # Let's try it with 32 characters.
    new_mem = Member.new
    new_mem.username = "da" * 16
    begin
      new_mem.validate
    rescue Sequel::ValidationFailed
    end
    new_mem.errors[:username].first.should.be.instance_of String

    # Let's try it now with just 24 characters.
    new_mem.username = "da" * 12
    begin
      new_mem.validate
    rescue Sequel::ValidationFailed
    end
    new_mem.errors[:username].should.be.empty    
  end

  it 'should not allow any characters beyond: letters, numbers, underscores, dashes' do
    ['****', 'da*', "da\/"].each { |bad_username|
      @mem.username = bad_username
      begin
        @mem.validate
      rescue Sequel::ValidationFailed
      end
      @mem.errors[:username].first.should.be.instance_of String
    }

    ["da01_#{rand(1000)}", "---da01_#{rand(1000)}", "___#{rand(1000)}__"].each { |good_username|
      @mem.username = good_username
      begin
        @mem.validate
      rescue Sequel::ValidationFailed
      end
      @mem.errors[:username].should.be.empty
    }
    
  end

end


describe 'Member :validate for :password' do

  before { @mem = Member.new }

  it 'should require :password' do
    @mem.username = 'da01_password'
    lambda { @mem.validate }.should.raise(Sequel::ValidationFailed)
    @mem.errors[:password].first.should.match(/Password is required/)
  end

  it 'should set :hashed_password' do
    @mem.username = 'da01_hashed_password'
    @mem.password = 'some_password'
    lambda { @mem.validate }.should.raise(Sequel::ValidationFailed)
    @mem.hashed_password.should.be.instance_of String
    @mem.hashed_password.size.should.be > 30
  end
  
end # === describe 'Member :validate for :password'


describe 'Member :validate for :confirm_password' do

  before { @mem = Member.new }

  it 'should require that :confirm_password match with :password' do
    @mem.username = "da01_confirm_password_#{rand(1000)}"
    @mem.password = 'my_password_1234'
    @mem.confirm_password = 'my_passworD_1234'
    lambda { @mem.validate }.should.raise(Sequel::ValidationFailed)
    @mem.errors[:password].first.should.match(/Password confirmation does not match password/)
  end
  
end # === describe 'Member :validate for :confirm_password'

describe 'Member :after_create' do

  before {
    @mem = Member.all.last

  }

  it 'should create just 1 PaperTrail for :action "CREATE".' do
    @mem = Member.new
    @mem.username = "da0#{rand(100000)}"
    @mem.password = "secret#{rand(100000)}"
    @mem.confirm_password = @mem.password
    @mem.save

    trails_for_member = PaperTrail.where(:owner_id=> @mem.id, :model_class_name=>'Member', :action=>'CREATE').all
    trails_for_member.size.should == 1
    # trails_for_member.first.body.should =~ /#{m.expires_at.strftime(SWISS.time_string_format)}/
    # trails_for_member.first.body.should =~ /#{SWISS.utc_to_local(m.timezone, m.expires_at).strftime(SWISS.time_string_format)}/
  end
  
  it 'should create a PaperTrail with: :action=> "CREATE",  :owner_id => Member\'s id, and :model_id => 0.' do    
    trails_for_member = PaperTrail.where(:owner_id=>@mem.id, :model_class_name=>'Member', :action=>'CREATE').all
    trails_for_member.size.should == 1
  end
  


end # ==== describe 'Member :after_create'


describe 'Member :after_update' do

  before {
    @mem = Member.order(:id).last
  }

  it 'should create a new PaperTrail noting the change of a username.' do
    orig_trail_count = @mem.paper_trails_dataset.count
    orig_username    = @mem.username
    @mem.username = "da02#{rand(10000)}"
    @mem.save

    latest_trail = @mem.paper_trails_dataset.order(:id).last
    new_trail_count = @mem.paper_trails_dataset.count
    new_trail_count.should.be === (orig_trail_count + 1)
    latest_trail.body.should =~ /#{@mem.username}/
    latest_trail.body.should =~ /#{orig_username}/
  end

  it 'should NOT create a PaperTrail if no values have changed.' do
    orig_trail_count = @mem.paper_trails_dataset.count
    @mem.save
    orig_trail_count.should.be  === @mem.paper_trails_dataset.count
  end

end # === describe 'Member :after_update'


__END__

SCRAPS ===>


describe 'Member#check_lists' do
  it 'should NOT return any CheckList clones.' do
    new_member = Member.new
    new_member.username = 'da01_no_clones'
    new_member.password = 'da01password'
    new_member.confirm_password = new_member.password
    new_member.save

    new_check_list = CheckList.new
    new_check_list.title = 'Something'
    new_member.add_check_list(new_check_list)

    new_check_list.clone_it!
    new_check_list.clone_it!

    new_member.refresh.check_lists.size.should.be == 1
  end
end  # === describe
