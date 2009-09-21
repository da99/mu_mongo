

# ====================================================================================
# ====================================================================================
class Bacon < Thor

  include Thor::Sandbox::CoreFuncs
  
  desc :db_reset!, "Reset the :test database" 
  def db_reset!
    ENV['RACK_ENV'] = 'test'
    invoke('db:reset!')
    news_id = DB[:news].insert( 
      :title        => 'Buy Longevinex',
      :teaser       => 'teaser',
      :body         => 'body',
      :created_at   => Time.now.utc,
      :published_at => Time.now.utc)
    news_tag_id  = DB[:news_tags].insert(:filename=>'surfer_hearts')
    news_tagging = DB[:news_taggings].insert(:news_id=>news_id, :tag_id=>news_tag_id)
    admin_id = DB[:members].insert(:hashed_password=>'$2a$10$q4bnQIrv7FO.SoATM3XKPOVDEp74iey2qMJ8VWxm5x1o0vd6rfjmi', 
                        :salt=>'0N3OjeVmlw', 
                        :permission_level=>1000, 
                        :created_at=>Time.now.utc)
    DB[:usernames].insert(:owner_id=>admin_id, :username=>'da01tv', :category=>'Personal', :created_at=>Time.now.utc)

    member_id = DB[:members].insert(:hashed_password=>'$2a$10$q4bnQIrv7FO.SoATM3XKPOVDEp74iey2qMJ8VWxm5x1o0vd6rfjmi',
                        :salt=>'0N3OjeVmlw',
                        :permission_level=>1,
                        :created_at=>Time.now.utc)
    DB[:usernames].insert(:owner_id=>member_id, :username=>'da01', :category=>'Business', :created_at=>Time.now.utc)
  end

  desc :file, "Run a single file"
  method_options :file=> :string, :testcase => :string
  def file
    append = options[:testcase] ? " -t #{options[:testcase]} " : nil
    output, errors = run_specs(true, options[:file], append )
    
    if !errors.empty?
      say( errors, :red )
      return errors
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

