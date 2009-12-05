
class App_String_Additions_File
	
	include FeFe_Test

	context 'Test File properties of String Additions.'

	before {
		@path = '~/megauni/config.ru'
	}

  after {
    if @delete_files
      @delete_files.each { |file|
        file_path = File.expand_path(file.to_s)
        if File.file?(file_path) || File.symlink?(file_path)
          File.delete(file_path)
        end
      }
    end
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
    system("echo 'test 123' > #{old_file}")
    old_file.file.rename_to(new_file)
    demand_equal(
      true,
      File.file?(new_file)
    )
    @delete_files = [old_file, new_file]
  end

  it 'raises an error if new file name already exists.' do
    old_file = File.expand_path( '~/Desktop/s123456'+Time.now.utc.to_i.to_s+'.rb' )
    new_file = File.expand_path('~/Desktop/s_new_123456' + Time.now.utc.to_i.to_s + '.rb')
    system("touch #{old_file}")
    system("touch #{new_file}")
    begin
      old_file.file.rename_to(new_file)
    rescue ArgumentError => e
      demand_regex_match( /existing file/, e.message )
    end
    
    @delete_files = [old_file, new_file]
  end

  context 'Creating symbolic links with :create_alias'

  it 'uses relative paths' do
    old_file = '~/Desktop/old_file.rb.rb.rb'
    new_file = './new_file.rb.txt.rb'
    
    system(%! echo "test 12345" > #{old_file}!)
    old_file.file.create_alias(new_file)
    demand_true( File.exists?(new_file.expand_path) )
    
    @delete_files = [old_file, new_file]
  end
  
  it 'uses expanded paths' do
    old_file = '~/Desktop/old_file.1.rb.rb.rb'
    new_file = '~/Desktop/new_file.2.rb.txt.rb'.expand_path
    
    system(%! echo "test 135" > #{old_file}!)
    old_file.file.create_alias(new_file)
    demand_true( File.exists?(new_file.expand_path) )
    
    @delete_files = [old_file, new_file]
  end
  
  it 'raises ArgumentError if new alias is a non-identical file.' do
    old_file = '~/Desktop/old_file.300.rb.sass'
    existing_file = '~/Desktop/existing.file.300.rb.sass'
    
    system(%! echo "test 135" > #{old_file}!)
    system(%! echo "test 456" > #{existing_file}!)
    
    begin
      old_file.file.create_alias(existing_file)
    rescue ArgumentError=>e
      demand_equal(
        "File already exists: #{existing_file.expand_path.inspect}", 
        e.message
      )
    end

    @delete_files = [old_file, existing_file]
  end

end
