
# ====================================================================================
# ====================================================================================
class Controller < Thor

  include Thor::Sandbox::CoreFuncs

  desc  :create , "Create a controller file. Tip: You can use model:create to automatically create controller."

  def create

    # Require Sequel in order to use :camelize method
    m =  if ENV['__new_controller__'] 
      'Create' + ENV['__new_controller__'].strip.camelize
    else
      ask('Name of controller:').strip.camelize
    end

    file_path = Pow!("actions/#{m.underscore}.rb")
    raise ArgumentError, "File: #{file_path} already exists." if File.exists?(file_path )

    txt = <<-EOF
set :#{m}_actions, [ :show,
                     :new,
                     :create,
                     :edit,
                     :update ]
    
EOF
    return Pow(file_path) { |f| f.puts txt }
  end # === task :create 

end # === namespace :controller


