

# ====================================================================================
# ====================================================================================
class Bacon < Thor

  include Thor::Sandbox::CoreFuncs
  
  desc :db_reset!, "Reset the :test database" 
  def db_reset!
    ENV['RACK_ENV'] = 'test'
    invoke('db:reset!')
    DB[:news].insert( 
      :title=>'Buy Longevinex', 
      :teaser=>'teaser', 
      :body=>'body', 
      :created_at=>Time.now.utc, 
      :published_at=>Time.now.utc)
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
    
    output = colorize(output) 
    say( output + "\n\n" )
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

  def run_specs(print_wait=true)
    spec_helper = Pow('~', "#{PRIMARY_APP}/helpers/specs/spec.rb" )
    cmd = "bacon specs/*.rb -r #{spec_helper}"
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

