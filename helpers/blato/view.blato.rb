
# ====================================================================================
# ====================================================================================

def get_skin_name_and_dir
  skin_name = ask('Skin name. (Default is "jinx"):' ) { |q| q.default =  'jinx' }
  skin_dir = Pow!("views/skins/#{skin_name}")
  raise "Skin dir does not exist: views/skins/#{skin_name}" unless skin_dir.exists?  
  [skin_name, skin_dir]
end

class View 

  include Blato

  bla( :update, "Change view name." ) do
    old_view_name = ask("Old view name:").strip
    new_view_name = ask("New view name:").strip
    skin_name , skin_dir = get_skin_name_and_dir
    
    old_files = []
    old_files << (skin_dir / "#{old_view_name}.mab")
    old_files << (skin_dir / 'css' / "#{old_view_name}.mab")
    old_files << Pow!("public/js/pages/#{old_view_name}.js")
    
    new_files = []
    old_files << (skin_dir / "#{new_view_name}.mab")
    old_files << (skin_dir / 'css' / "#{new_view_name}.mab")
    old_files << Pow!("public/js/pages/#{new_view_name}.js")
    
    old_files.each_index { |i|
      if old_files[i].exists?
        shout "Renaming #{old_files[i]} to #{new_files[i]}"
        `mv #{old_files[i]} #{new_files[i]}`
      end
    }
    
    shout "Done. Don't forget search for all SASS files and change\n#{old_view_name}  ==>  #{new_view_name}"
  end
  
	bla( :create , "Create a view file with SASS file (unless it is a partial)." ) do

    # Require Sequel in order to use :camelize method
    require 'sequel/extensions/inflector'
    void_actions = ['create', 'update', 'delete', 'destroy']
    skin_name , skin_dir = get_skin_name_and_dir
    
    controller_name = ask('Name of controller:').strip.underscore
    actions = ask('Separate each action with a space:').split.map { |action_name| action_name.gsub(/[^a-z0-9\-\_]/i, '-').underscore }
    actions.each { |action_name| 
      if void_actions.include?(action_name)
        shout "... Skipping: #{action_name} ..."
      else
        file_path = Pow!("views/skins/#{skin_name}/#{controller_name}_#{action_name}.mab")
        raise ArgumentError, "File: #{file_path} already exists." if File.exists?(file_path )

        txt = "p { 'Not implemented yet.'} "
        write_this_file(file_path, txt)
        
        # If not a partial, create a corressponding SASS file.
        if !action_name[/\A\_\_/]
          file_path = Pow!("views/skins/#{skin_name}/sas/#{controller_name}_#{action_name}.sass")
          raise ArgumentError, "File: #{file_path} already exists." if File.exists?(file_path )

          txt = "@import layout.sass"
          write_this_file(file_path, txt)
        end
      end # === if void_actions.include?(action_name)
    }



	end # === task :create 

end # === namespace :view
