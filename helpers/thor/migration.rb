
class Migration < Thor

  include CoreFuncs

	desc  :create, "Create a migration file. Tip: You can use model:create to automatically create migration." 
  def create

    # Require Sequel in order to use :camelize method
    require 'sequel/extensions/inflector'
    
    a = ask('Name of action: (e.g.: create, alter, drop, update)').strip.to_s.downcase
    raise "Unknown action: #{a}" if !%w{ create alter drop update insert }.include?(a)
    
    m = ask('Name of migration: (e.g.: folders)').strip.camelize.pluralize
    
    i = Dir.entries('./migrations').select {|f| f=~ /^\d\d\d\_\w{1,}/}.sort.last.to_i + 1
    padding = '0' * (3 - i.to_s.length)

    file_path = Pow("migrations/#{padding}#{i}_#{a}_#{m.underscore}.rb")
    raise "Migration file already exists: #{file_path}" if file_path.exists?

    template_file = Pow(File.expand_path('~/' + primary_app + '/migrations/template.txt'))
    raise "Template file does not exist: #{template_file}" if !template_file.file?

    txt = eval( %~"#{template_file.read}"~ )
    
    file_path.create { |f|
      f.puts txt
    }
    
    whisper "Done: #{file_path}"
    `gvim --remote-tab-silent #{file_path.inspect}`
	end # === task :create_migration => "__setup__:env"

end # === namespace :migration



