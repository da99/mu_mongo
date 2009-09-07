

# ====================================================================================
# ====================================================================================
class Spec

  include Blato
  
  def please_wait
    shout "Running tests.", :yellow
  end
  
  def color_say( raw_output )
    pieces = raw_output.split("\n")
    results = pieces.pop
    output = results.split(',').map { |s|
          if s[/(failures|errors)/] 
            if s.to_i.zero?
              Blato.colorize_text( s, :white)
            else
              Blato.colorize_text( s, :red)
            end
          else
            s
          end
        }.join(',')   
    HighLine.new.say [ pieces, output ].flatten.join("\n")
  end
  
  bla :db_reset!, "Reset the :test database" do
    ENV['RACK_ENV'] = 'test'
    invoke('db:reset!')
    DB[:news].insert( 
      :title=>'Buy Longevinex', 
      :teaser=>'teaser', 
      :body=>'body', 
      :created_at=>Time.now.utc, 
      :published_at=>Time.now.utc)
  end

  bla :run, {:with_color=>true}, "Run all specs for this app." do |*args|
    
    ENV['RACK_ENV'] = 'test'

    with_color = args.empty? ? true : args.first
    please_wait
    
    spec_helper = Pow('~', "#{MEGA_APP_NAME}/helpers/specs/spec.rb" )
    cmd = "bacon specs/* -r #{spec_helper}"
    whisper( cmd )
    output = capture(cmd)
    
    if Blato.mute? || !with_color
      whisper( output  )
    else
      color_say(output)
    end
  end
  
  bla :summary, {:with_color=>true}, "Show only the summary. (Last line of spec:run)" do |with_color|
    with_color ||= true

    please_wait if with_color
    output = capture_task( :run ).split("\n").last
    
    if !with_color
      return( whisper( output ) ) 
    end
    
    color_say(output)
    
  end # === def __summary

end # ==== namespace :spec

