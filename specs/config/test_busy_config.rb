# ======================================================================
require File.expand_path('test/base_spec')
# ======================================================================

describe BusyConfig do

  it 'should return true for :test?' do
    BusyConfig.should.be.test
  end

  it 'should return false for :production? and :development?' do
    BusyConfig.should.not.be.development
    BusyConfig.should.not.be.production
  end

  it 'should raise BusyConfig::EnvironmentAlreadySet' do
    lambda {
      BusyConfig.use_env!( BusyConfig::ENV_PROD )
    }.should.raise(BusyConfig::EnvironmentAlreadySet).
     message.should.match(/already set to/)
  end

  it 'should raise BusyConfig::AppSetNotToRun if :ramaze_options is called' do
    lambda { BusyConfig.ramaze_options }.should.raise(BusyConfig::AppSetNotToRun)
  end
  
end # ==== describe


# ======================================================================
# All other stuff that is hard to test
# using the regular BusyConfig in the test environment.
# ======================================================================
class ProdBusyConfig < BusyConfig; end
ProdBusyConfig.use_env!(BusyConfig::ENV_PROD)

describe ProdBusyConfig do 

  it 'should return true for :production?' do
    ProdBusyConfig.production?.should.be == true
  end

  it 'should return false if :test? and :development?' do
    ProdBusyConfig.test?.should === false
    ProdBusyConfig.development?.should === false
  end

  it 'should return {:adapter => :thin, :port => 9123, :sourcereload => false} for :production' do
    ProdBusyConfig.ramaze_options.should == {:adapter => :thin, :port => 9123, :sourcereload => false, :boring => [/\.css$/, /\.js$/, /\.img$/]}
  end

  it 'should return a database connection string in the format of: postgres://usr:pswd@host/db' do
    ProdBusyConfig.db_connection_string.should == "postgres://test_user:test_pass@test_host/test_db"
  end


end # ==== end describe ProdBusyConfig
