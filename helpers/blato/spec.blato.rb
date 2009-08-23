

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
  
  bla :run, {:with_color=>true}, "Run all specs for this app." do |*args|
    with_color = args.empty? ? true : args.first
    please_wait
    output = capture("bacon specs/* -r /home/da01/#{Blato.app_name}/helpers/specs/spec.rb")
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

