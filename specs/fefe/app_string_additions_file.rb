
class App_String_Additions_File
	
	include FeFe_Test

	context 'Test File properties of String Additions.'

	before {
		@path = '~/megauni/config.ru'
	}

	it 'lets you ask: file?' do
		demand_equal true, @path.file? 
	end
	
	it 'lets you ask: file.exists?' do
		demand_equal true, @path.file.exists? 
	end
	
	it 'expands name of file' do
		demand_equal(
			File.expand_path(@path),
			@path.file.expand_path
		)
	end

	it 'gives the file name without path' do
		demand_equal(
			File.basename(@path),
			@path.file.name
		)
	end

	it 'gives the expanded path of file' do
		demand_equal(
			File.expand_path(@path),
			@path.file.path
		)
	end
	
	it 'reads the file' do
		demand_equal(
			File.read(File.expand_path(@path)),
			@path.file.read
		)
	end
	
	it 'renames file' do
    old_file = File.expand_path( '~/Desktop/s123456'+Time.now.utc.to_i.to_s+'.rb' )
    new_file = File.expand_path('~/Desktop/s_new_123456' + Time.now.utc.to_i.to_s + '.rb')
    system("cat 'test 123' > #{old_file}")
    old_file.rename_to(new_file)
    demand_equal(
      true,
      File.file?(new_file)
    )
    system("rm #{new_file}")
  end

  it 'raises an error if new file name already exists.' do
    old_file = File.expand_path( '~/Desktop/s123456'+Time.now.utc.to_i.to_s+'.rb' )
    new_file = File.expand_path('~/Desktop/s_new_123456' + Time.now.utc.to_i.to_s + '.rb')
    system("touch #{old_file}")
    system("touch #{new_file}")
    begin
      old_file.rename_to(new_file)
    rescue ArgumentError => e
      demand_regex_match( /existing file/, e.message )
    end
  end

end
