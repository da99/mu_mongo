

namespace :models do 
  
  desc 'Creates a model file using name='
  task :create do
    model_name = ENV['name'].to_s.strip.split('_').map { |str| str.downcase.capitalize }.join('_')
    raise ArgumentError, "Model name required." if model_name.empty?
    
    require 'mustache'
    template = FiDi.file('./models/template.txt').read
    file     = FiDi.file("./models/#{model_name}.rb")
    file.write Mustache.render(template, :model_name=>model_name)

    puts_white "Finished writing model file:"
    puts_white file.path
  end
  
end
