
namespace :models do 
  
  desc 'Creates a model file using name='
  task :create do
    model_name = ENV['name'].to_s.strip.split('_').map { |str| str.downcase.capitalize }.join('_')
    raise ArgumentError, "Model name required." if model_name.empty?
    
    new_file_name = File.expand_path("./models/#{model_name}.rb")
    raise ArgumentError, "File already exists: #{new_file_name} " if File.exists?(new_file_name)
    
    require 'mustache'
    content = File.read(File.expand_path('./models/template.txt'))
    compiled = Mustache.render(content, :model_name=>model_name)
    File.open(new_file_name, 'w') do |file|
      file.write(compiled)
    end

    puts_white "Finished writing:"
    puts_white new_file_name
  end
  
end
