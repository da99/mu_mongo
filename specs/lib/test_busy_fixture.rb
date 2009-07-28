unless defined? Ramaze
  require 'bacon'
  require 'sequel' # for the :undescore String method.
  require File.expand_path('lib/busy_fixture')
end

class TestBusyFixtureRobot

  attr_accessor :name, :owner, :newly_added_spare_part

  def self.existing_instances
    @existing_instances ||= []
  end

  def self.search_history
    @search_history ||= []
  end

  def self.[]( search_hash )
    search_history << search_hash
    search_history.uniq!
    unless search_hash.has_key?(:name)
      raise ArgumentError, "Something went wrong while searching for records: #{search_hash.inspect}"
    end
  end

  def accessories
    if self.name == 'R2D2'
      new_rocket_pack = TestBusyFixtureRobotSparePart.new
      new_rocket_pack.weight = '256 lbs.'
      new_rocket_pack.model = 'Hover-o-Matic 1234'
      return [new_rocket_pack]
    end

    []
  end

  def add_test_busy_fixture_robot_spare_part( new_spare_part )
    @newly_added_spare_part ||= []
    @newly_added_spare_part << new_spare_part
    new_spare_part
  end

  def save
    self.class.existing_instances << self
    self
  end
end # === TestBusyFixtureRobot


class TestBusyFixtureRobotSparePart

  attr_accessor :weight, :model

  def self.existing_instances
    @existing_instances ||= []
  end

  def save
    self.class.existing_instances << self

    self
  end
end # == TestBusyFixtureRobotSparePart


describe BusyFixture do

  before {
    data = [["@three_pio",
  {:name=>"3-PO",
   :meta=>{:class=>"TestBusyFixtureRobot", :search_by=>:name},
   :owner=>"Republic"}],
 ["@r2d2",
  {:name=>"R2D2",
   :meta=>{:class=>"TestBusyFixtureRobot", :search_by=>:name},
   :owner=>"Naboo Senator"}],
 ["@universal_dictionary",
  {:weight=>"3 lbs.",
   :model=>"Translator",
   :meta=>
    {:class=>"TestBusyFixtureRobotSparePart",
     :search_by=>"@three_pio.accessories.first",
     :add_to=>"@three_pio"}}],
 ["@rocket_pack",
  {:weight=>"45 lbs.",
   :model=>"Repair Droid",
   :meta=>
    {:class=>"TestBusyFixtureRobotSparePart",
     :search_by=>"@r2d2.accessories.first",
     :alias => '@another_rocket_pack'
     }
  }]
]

    
    BusyFixture.eval_this(data, binding) 
  }

  it 'should use the first key in an Array as a variable of the current context' do
    @three_pio.should.not.be.nil
    @r2d2.should.not.be.nil
  end

  it 'should create objects based on :meta[:class]' do
    @three_pio.should.be.instance_of TestBusyFixtureRobot
    @r2d2.should.be.instance_of TestBusyFixtureRobot
  end

  it 'should set attributes of the new object.' do
    @three_pio.name.should.be == '3-PO'
    @three_pio.owner.should.be == 'Republic'
    
    @r2d2.name.should.be == 'R2D2'
    @r2d2.owner.should.be == 'Naboo Senator'
  end

  it 'should search for previous records by the given Hash[:meta][:search_by] Symbol' do
    TestBusyFixtureRobot.search_history.should.include( {:name=>'3-PO'} )
    TestBusyFixtureRobot.search_history.should.include( {:name=>'R2D2'} )
  end

  it 'should search for previous records by the given Hash[:meta][:search_by] String.' do
    @rocket_pack.weight.to_i.should.not.be == 45
    @rocket_pack.weight.to_i.should.be === 256
    @rocket_pack.model.should.not.be == 'Repair Droid'
    @rocket_pack.model.should.be === 'Hover-o-Matic 1234'
  end

  it 'should add new object as part of an Association using Hash[:meta][:add_to]' do
    @three_pio.newly_added_spare_part.size.should.be === 1
    @three_pio.newly_added_spare_part.first.weight.should.be === '3 lbs.'
    @three_pio.newly_added_spare_part.first.model.should.be === 'Translator'
  end

  it 'should alias instance variable after creating it (using Hash[:meta][:alias])' do
    robot_num  = rand(1000)
    new_robot = [
      "@new_robot_#{robot_num}",
        {:name=>"Robot #{robot_num}",
         :owner=>'Republic',
         :meta=>{:class=>"TestBusyFixtureRobot",
                  :search_by=>:name,
                  :alias => "@robot_#{robot_num}"
                }
        }
    ]
    BusyFixture.eval_this( [ new_robot ], binding)
    instance_variable_get("@robot_#{robot_num}").should.be.same_as( instance_variable_get("@new_robot_#{robot_num}") )
  end

  it 'should alias instance variable after searching for it (using Hash[:meta][:alias])' do
    @another_rocket_pack.should.be.instance_of TestBusyFixtureRobotSparePart
    @another_rocket_pack.should.be.same_as @rocket_pack
  end

  it 'should raise InstanceVariableNameAlreadyUsed if instance variable name is used more than once.' do
    broken_robot = [
        "@broken_robot_#{rand(1000)}",
        {:name=>"Rusty",
         :owner=>'Republic',
         :meta=>{:class=>"TestBusyFixtureRobot",
                  :search_by=>:name}
        }
    ]
    test_data =  [broken_robot, broken_robot]

    lambda { BusyFixture.eval_this(test_data, binding) }.
      should.raise(BusyFixture::InstanceVariableNameAlreadyUsed).
        message.should.match(/Key already used once\: \@broken\_robot/)
  end

  it 'should raise InstanceVariableNameInUse if instance variable is of a different class than target.' do
    @broken_robot = :is_full

    test_data = [["@broken_robot",
                  {:name=>"Rusty",
                   :owner=>'Republic',
                   :meta=>{:class=>"TestBusyFixtureRobot",
                            :search_by=>:name}
                  }]]

    lambda { BusyFixture.eval_this(test_data, binding) }.
      should.raise(BusyFixture::InstanceVariableNameInUse).
        message.should.match(/Instance variable name is already in use\: \@broken\_robot/)
  end

  it 'should override instance variable if the same class as :meta[:class]' do
    @broken_robot = TestBusyFixtureRobot.new
    test_data = [["@broken_robot",
                  {:name=>"Rusty",
                   :owner=>'Republic',
                   :meta=>{:class=>"TestBusyFixtureRobot",
                            :search_by=>:name}
                  }]]
    BusyFixture.eval_this(test_data, binding)
    @broken_robot.name.should.be == test_data.first.last[:name]
  end

  it 'should raise UnknownMetaData if an unknown :meta key is used.' do
    test_data = [["@broken_robot_#{rand(1000)}",
                  {:name=>"Rusty",
                   :meta=>{:class=>"TestBusyFixtureRobot",
                            :search_by=>:name,
                            :some_key=>"5"}
                  }]]
    lambda { BusyFixture.eval_this(test_data, binding) }.
      should.raise(BusyFixture::UnknownMetaData).
      message.should.match( /Unknown keys in meta data\: \:some\_key/)
  end

  it 'should raise MissingMetaData if :meta key is missing' do
    test_data = [["@broken_robot_#{rand(1000)}",
                  {:name=>"Rusty"}
                 ]]
    lambda { BusyFixture.eval_this(test_data, binding) }.
      should.raise(BusyFixture::MissingMetaData).
      message.should.match( /\:meta key missing for \@broken\_robot/)
  end

  it 'should raise MissingMetaData if :class key for :meta is missing' do
    test_data = [["@broken_robot_#{rand(1000)}",
                  {:name=>"Rusty", :meta=>{:search_by=>:name}}
                 ]]
    lambda { BusyFixture.eval_this(test_data, binding) }.
      should.raise(BusyFixture::MissingMetaData).
      message.should.match( /\:meta\[\:class\] missing for/)
  end

  it 'should raise MissingMetaData if both :search_by and :create_if key is missing for :meta' do
    test_data = [["@broken_robot_#{rand(1000)}",
                  {:name=>"Rusty", :meta=>{:class=>"TestBusyFixtureRobot"}}
                 ]]
    lambda { BusyFixture.eval_this(test_data, binding) }.
      should.raise(BusyFixture::MissingMetaData).
      message.should.match( /\:meta\[\:search_by\] and \:meta\[\:create_if\] are missing for/)
  end
  
end # === describe
