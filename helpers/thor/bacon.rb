

# ====================================================================================
# ====================================================================================
class Bacon < Thor

  include Thor::Sandbox::CoreFuncs
  
  desc :db_reset!, "Reset the :test database" 
  def db_reset!
    invoke('db:reset!')

    ENV['RACK_ENV'] = 'test'
    require File.expand_path('megauni')

    DesignDoc.create_or_update
    whisper 'Created: design doc.'

    # === Create News ==========================
    
    n = News.new
    n.raw_data.update({:title=>'Longevinex', 
      :teaser=>'teaser', 
      :body=>'Test body.', 
      :tags=>['surfer_hearts', 'hearts', 'pets']
    })
    n.save_create

    # === Create Members ==========================
    
    Member.create( nil, {
      :password          =>'regular-password-1',
      :confirm_password  =>'regular-password-1',
      :add_life_username =>'regular-member-1',
      :add_life          =>Member::LIVES.first
    })
    
    Member.create( nil, {
      :password          =>'admin-password-1',
      :confirm_password  =>'admin-password-1',
      :add_life_username =>'admin-member',
      :add_life          =>Member::LIVES.first
    })

    admin_mem = Member.by_username( 'admin-member' )
    admin_mem.new_data[:security_level] = :ADMIN
    admin_mem.save_update

  end

  desc :file, "Run a single file"
  method_options :file=> :string, :testcase => :string
  def file
    append = options[:testcase] ? " -t #{options[:testcase]} " : nil
    output, errors = run_specs(true, options[:file], append )
    
    if !errors.empty?
      say( errors, :red )
      exit(1)
    end

    say( colorize(output) + "\n\n" )
    output
  end

  desc :all, "Run all specs for this app."
  method_options :summary => :boolean
  def all
    output, errors = run_specs(!options[:summary])
    
    if !errors.empty?
      say( errors, :red )
      return errors
    end

    if options[:summary]
      output = output.split("\n").last.strip
    end
    
    say( colorize(output) + "\n\n" )
    output
  end

  desc "all_pass?", 'Return true or false if all pass.'
  def all_pass?
    results, errors = run_specs(false)
    return false if !errors.empty?

    pieces =  results.strip.split("\n").last.split(",")
    return false if pieces.size != 3
    
    return true if pieces[1].to_i.zero? && pieces[2].to_i.zero?
    false
  end  

  private # =========================================================

  def run_specs(print_wait=true, filename = '*', append='')
    spec_helper = Pow('~', "#{PRIMARY_APP}/helpers/specs/spec.rb" )
    cmd = "bacon -r #{spec_helper} #{append} specs/#{filename.sub('.rb', '')}.rb "
    please_wait(cmd) if print_wait
    shell_capture(cmd)
  end
  
  def colorize( raw_output )
    pieces = raw_output.split("\n")
    output = pieces.pop.split(',').map { |s|
          if s[/(failures|errors)/] 
            if s.to_i.zero?
              shell.set_color( s, :white)
            else
              shell.set_color( s, :red)
            end
          else
            s
          end
        }.join(',')   
    [ pieces, output ].flatten.join("\n")
  end 
end # ==== namespace :spec

