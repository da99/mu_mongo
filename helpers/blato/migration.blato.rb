
class Migration 

  include Blato

	bla( :create, "Create a migration file. Tip: You can use model:create to automatically create migration."  ) do

    # Require Sequel in order to use :camelize method
    require 'sequel/extensions/inflector'
    m = (ENV['__new_migration__'] || ask('Name of migration:')).strip.camelize.pluralize
    i = Dir.entries('./migrations').select {|f| f=~ /^\d\d\d\_\w{1,}/}.sort.last.to_i + 1
    padding = '0' * (3 - i.to_s.length)
    file_path = Pow!("migrations/#{padding}#{i}_#{m.underscore}.rb")
    raise ArgumentError, "File: #{file_path} already exists." if File.exists?(file_path )

    txt = eval( %~ "
        #{Pow('~' + MEGA_APP_NAME + 'migrations/template.txt').read}
    " ~ )
    write_this_file(file_path, txt)
	end # === task :create_migration => "__setup__:env"

end # === namespace :migration

__END__


# ====================================================================================
# ====================================================================================
namespace :migration do

	desc "Create a migration file. Tip: You can use model:create to automatically create migration."
	task( :create ) do

    # Require Sequel in order to use :camelize method
    require 'sequel/extensions/inflector'
    m = ask('Name of migration:').strip.camelize.pluralize
    i = Dir.entries('./migrations').select {|f| f=~ /^\d\d\d\_\w{1,}/}.sort.last.to_i + 1
    padding = '0' * (3 - i.to_s.length)
    file_path = Pow("migrations/#{padding}#{i}_#{m.underscore}.rb")
    raise ArgumentError, "File: #{file_path} already exists." if File.exists?(file_path )

    txt = <<-EOF
class #{m}_#{i} < Sequel::Migration

  def up  
    create_table( :#{m.underscore} ) {
      # === Associations
      primary_key :id
      
      
      # === Attributes
      
      
      # === Date Times
      timestamp   :created_at
      timestamp   :modified_at, :null=>true
      
      # === Aggregate Statistics
      # None so far.    
    }
  end

  def down
    drop_table(:#{m.underscore}) if table_exists?(:#{m.underscore})
  end

end # === end Create#{m}
EOF

    file_path.create { |f|
      f.puts txt
    }
	end # === task :create_migration => "__setup__:env"

end # === namespace :migration

