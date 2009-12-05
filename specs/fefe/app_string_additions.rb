
class App_String_Additions

  include FeFe_Test

  context ':has_extension?' 

  it 'returns true if extension is at the end' do
    demand_true '~/megauni/megauni.rb'.has_extension?('.rb')
  end

  it 'returns false if extension is in the middle' do
    demand_false '/home/yakka/.rb/file.sass'.has_extension?('.rb')
  end

  it "returns true with an extension lacking beginning period" do
    demand_true '/home/yakka/yakka.sass'.has_extension?('sass')
  end

  it "returns true if asked for extension with a symbol" do
    demand_true '/home/yakka/wat.yaml'.has_extension?(:yaml)
  end

  it 'raises ArgumentError if asked with empty string.' do
    begin
      ''.has_extension?('')
    rescue ArgumentError=>e
      demand_equal "String can't be empty.", e.message
    end
  end
  
  context ':replace_extension' 

  before {
    base_path = '/home/yakka/yakka'
    @file      = base_path + '.sass'
    @new_file  = base_path + '.css'
  }

  it 'returns new String with new extension' do
    demand_equal @new_file, @file.replace_extension('.css')
  end

  it 'returns new String with new extension from Symbol' do
    demand_equal @new_file, @file.replace_extension(:css)
  end

  it 'returns new String with new extension lacking beginning dot.' do
    demand_equal @new_file, @file.replace_extension('css')
  end
  
  it 'raises ArgumentError if new extension is an empty String.' do
    begin
      @file.replace_extension '  '
    rescue ArgumentError => e
      demand_equal "String can't be empty.", e.message
    end
  end

end # ======== App_String_Additions
