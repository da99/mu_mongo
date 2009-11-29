class News_Actions
  include FeFe_Test

  it 'implements :demand_string' do
    demand_string :string.to_s
  end


  context 'A set of first tests for FeFe tester.'

  it 'implements :demand_match' do
    demand_string :string # demand_match 1, 1
  end



  context 'A second set of test for FeFe tester.'

  it 'implements :demand_block' do
    demand_block( lambda {})
  end
end # ======== News_Actions
